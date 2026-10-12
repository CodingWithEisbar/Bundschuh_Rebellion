"""Python parser/CSV and a real in-process Godot reload session, stdlib only."""
from __future__ import annotations

import csv
import hashlib
import json
import os
from pathlib import Path
import queue
import subprocess
import sys
import tempfile
import threading
import time
import unittest

ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT / 'tools'))
from unit_db import BalanceError, DEFAULT_DB, UnitDatabase, load, loads, validate
from balance import export_csv, prepare_output


class BalanceToolsTests(unittest.TestCase):
    def test_base_values_and_alias(self):
        data = load()
        self.assertEqual(data.sha256, hashlib.sha256(DEFAULT_DB.read_bytes()).hexdigest())
        self.assertEqual(data.unit('peasant_flailman')['combat']['hp'], 45)
        self.assertEqual(data.unit('radical_preacher')['combat']['attack'], 0)
        self.assertEqual(data.unit('landsknecht_pikeman')['combat']['bonus_damage'], {'cavalry': 24})
        self.assertEqual(data.unit('heavy_gendarme'), data.unit('armoured_ritter'))
        self.assertEqual(data.unit('heavy_gendarme')['economy']['cost'], {'food': 90, 'wood': 0, 'gold': 100, 'stone': 0})

    def test_schema_and_semantic_errors(self):
        for value in [0, -1, True, 1.5, '45', float('nan'), float('inf')]:
            with self.subTest(hp=value):
                doc = load().document()
                doc['units'][0]['combat']['hp'] = value
                with self.assertRaises(BalanceError):
                    validate(doc)
        for mutate in [lambda d: d.update(schema_version=2),
                       lambda d: d['units'][0]['combat'].update(attak=10),
                       lambda d: d['units'][1].update(id='peasant_flailman'),
                       lambda d: d['units'][0].update(aliases=['heavy_gendarme']),
                       lambda d: d['units'][0]['combat'].update(minimum_range_tiles=3),
                       lambda d: d['units'][1]['combat'].update(attack_period=3),
                       lambda d: d['units'][0]['combat'].update(bonus_damage={'dragons': 9})]:
            doc = load().document()
            mutate(doc)
            with self.assertRaises(BalanceError):
                validate(doc)

    def test_syntax_and_input_limits(self):
        for bad in [b'{broken', b'{"a":1,"a":2}', b'{"a":1,}', b'[1,]', b'NaN', b'01', b'"\\ud800"',
                    b'[' * 34 + b'1' + b']' * 34, b' ' * (1_048_576 + 1), b'\xff']:
            with self.subTest(data=bad[:40]), self.assertRaises(BalanceError):
                loads(bad)

    def test_defensive_copies(self):
        data = load()
        copy = data.unit('peasant_flailman')
        copy['combat']['hp'] = 999
        copy['economy']['cost']['food'] = 0
        self.assertEqual(data.unit('peasant_flailman')['combat']['hp'], 45)
        self.assertEqual(data.unit('peasant_flailman')['economy']['cost']['food'], 45)
        with self.assertRaises(BalanceError):
            data.unit('unknown')

    def test_atomic_reload(self):
        with tempfile.TemporaryDirectory() as directory:
            path = Path(directory) / 'units.json'
            path.write_bytes(DEFAULT_DB.read_bytes())
            data = UnitDatabase(path)
            original = data.snapshot
            self.assertFalse(data.reload())
            path.write_text('{bad', encoding='utf-8')
            with self.assertRaises(BalanceError):
                data.reload()
            self.assertIs(data.snapshot, original)
            self.assertEqual(data.generation, 1)
            doc = original.document()
            doc['units'][0]['combat']['hp'] = 90
            path.write_text(json.dumps(doc), encoding='utf-8')
            self.assertTrue(data.reload())
            self.assertEqual(data.generation, 2)
            self.assertEqual(original.unit('peasant_flailman')['combat']['hp'], 45)
            self.assertEqual(data.snapshot.unit('peasant_flailman')['combat']['hp'], 90)

    def test_report_directory_exclusion(self):
        with self.assertRaises(BalanceError):
            prepare_output(ROOT)
        with tempfile.TemporaryDirectory(dir=ROOT / 'test-results') as directory:
            folder = Path(directory)
            source = folder / 'source'
            source.mkdir()
            (source / 'example.gd').write_text('extends RefCounted\n', encoding='utf-8')
            with self.assertRaises(BalanceError):
                prepare_output(source)
            self.assertFalse((source / '.gdignore').exists())
            reports = folder / 'reports'
            prepare_output(reports)
            self.assertTrue((reports / '.gdignore').is_file())

    def test_live_engine_reload_and_csv(self):
        engine = os.environ['BUNDSCHUH_TEST_GODOT']
        with tempfile.TemporaryDirectory() as directory:
            folder = Path(directory)
            source = folder / 'units.json'
            source.write_bytes(DEFAULT_DB.read_bytes())
            args = [engine, '--headless', '--max-fps', '60', '--path', str(ROOT), '--script',
                    'tools/balance_headless.gd', '--', f'--database={source}',
                    f'--output={folder / "watch.json"}', '--watch', '--max-runs=2', '--unpaced',
                    '--left-count=1', '--right-count=1', '--seconds=0.1']
            process = subprocess.Popen(args, stdout=subprocess.PIPE, stderr=subprocess.STDOUT, text=True,
                                       encoding='utf-8', errors='replace', bufsize=1)
            messages: queue.Queue[str] = queue.Queue()
            lines: list[str] = []
            def read_output():
                for line in process.stdout:
                    messages.put(line)
            reader = threading.Thread(target=read_output, daemon=True)
            reader.start()
            def wait_for(marker: str):
                deadline = time.monotonic() + 15
                while time.monotonic() < deadline:
                    try:
                        line = messages.get(timeout=.2)
                    except queue.Empty:
                        if process.poll() is not None:
                            self.fail('Engine ended before ' + marker + '\n' + ''.join(lines))
                        continue
                    lines.append(line)
                    self.assertNotIn('SCRIPT ERROR:', line)
                    self.assertFalse(line.startswith('ERROR:'), line)
                    if marker in line:
                        return line
                self.fail('Timeout waiting for ' + marker + '\n' + ''.join(lines))
            try:
                wait_for('BALANCE_RESULT')
                first = json.loads((folder / 'watch.r001.json').read_text(encoding='utf-8'))
                source.write_text('{bad', encoding='utf-8')
                wait_for('BALANCE_RELOAD_REJECTED')
                self.assertFalse((folder / 'watch.r002.json').exists())
                self.assertIsNone(process.poll())
                changed = load().document()
                changed['units'][0]['combat']['hp'] = 90
                source.write_text(json.dumps(changed), encoding='utf-8')
                wait_for('BALANCE_RELOAD_ACCEPTED')
                wait_for('BALANCE_RESULT')
                self.assertEqual(process.wait(timeout=10), 0)
                second = json.loads((folder / 'watch.r002.json').read_text(encoding='utf-8'))
                self.assertEqual(first['database_generation'], 1)
                self.assertEqual(second['database_generation'], 2)
                self.assertEqual(first['teams'][0]['initial_hp'], 45)
                self.assertEqual(second['teams'][0]['initial_hp'], 90)
                self.assertNotEqual(first['database_sha256'], second['database_sha256'])
                self.assertEqual(second['database_sha256'], load(source).sha256)
                export_csv(second, folder / 'watch.csv')
                with (folder / 'watch.csv').open(encoding='utf-8', newline='') as stream:
                    rows = list(csv.DictReader(stream))
                self.assertEqual(len(rows), 2)
                self.assertEqual(rows[0]['remaining_hp'], '90')
                self.assertEqual(rows[1]['gold'], '100')
            finally:
                if process.poll() is None:
                    process.terminate()
                    try:
                        process.wait(timeout=5)
                    except subprocess.TimeoutExpired:
                        process.kill()
                        process.wait(timeout=5)
                reader.join(timeout=2)
                process.stdout.close()


if __name__ == '__main__':
    suite = unittest.defaultTestLoader.loadTestsFromTestCase(BalanceToolsTests)
    result = unittest.TextTestRunner(verbosity=2).run(suite)
    report = {'passed': result.testsRun - len(result.errors) - len(result.failures) - len(result.skipped),
              'total': result.testsRun, 'failed_assertions': [str(x) for x in result.errors + result.failures],
              'skipped': len(result.skipped)}
    target = ROOT / 'test-results/stage5_python.json'
    target.parent.mkdir(exist_ok=True)
    target.write_text(json.dumps(report, indent=2) + '\n', encoding='utf-8')
    sys.exit(0 if result.wasSuccessful() and not result.skipped else 1)
