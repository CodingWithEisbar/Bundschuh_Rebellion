#!/usr/bin/env python3
"""Validate JSON or run the actual Godot combat backend from Python, no pip deps."""
from __future__ import annotations

import argparse
import csv
import json
from pathlib import Path
import re
import shutil
import subprocess
import sys

from unit_db import BalanceError, DEFAULT_DB, ROOT, load


def export_csv(report: dict, target: Path) -> None:
    """One row per army, preserving Food/Wood/Gold/Stone as distinct costs."""
    fields = ['seed', 'database_sha256', 'outcome', 'winner_team', 'simulation_seconds',
              'team', 'unit_id', 'count', 'survivors', 'casualties', 'survival_rate',
              'initial_hp', 'remaining_hp', 'hp_retention_rate', 'mean_survivor_hp',
              'food', 'wood', 'gold', 'stone']
    with target.open('w', encoding='utf-8', newline='') as stream:
        writer = csv.DictWriter(stream, fieldnames=fields)
        writer.writeheader()
        for team in report['teams']:
            row = {key: report[key] for key in fields[:5]}
            row.update({key: team[key] for key in fields[5:-4]})
            row.update(team['base_army_cost'])
            writer.writerow(row)


def engine_path(argument: str) -> str:
    executable = shutil.which(argument)
    if executable is None:
        candidate = Path(argument).expanduser().resolve()
        if not candidate.is_file():
            raise BalanceError('Godot not found; supply --godot /path/to/Godot_4.5.2')
        executable = str(candidate)
    version = subprocess.check_output([executable, '--version'], text=True).strip()
    if not version.startswith('4.5.2.'):
        raise BalanceError(f'Expected pinned Godot 4.5.2, got {version}')
    return executable


def prepare_output(folder: Path) -> None:
    """Reports are raw data, not Godot CSV translation tables. Prevent the editor
    from importing generated CSVs, without masking any existing source folder.
    """
    resolved = folder.resolve()
    if resolved == ROOT or resolved in ROOT.parents:
        raise BalanceError('Choose a dedicated report directory, not the project root or its parent')
    if resolved.is_relative_to(ROOT):
        if any(resolved.rglob('*.gd')) or any(resolved.rglob('*.tscn')) or any(resolved.rglob('*.tres')):
            raise BalanceError('Report directory contains game source/assets; choose a separate folder')
        resolved.mkdir(parents=True, exist_ok=True)
        (resolved / '.gdignore').touch()
    else:
        resolved.mkdir(parents=True, exist_ok=True)


def command(args: argparse.Namespace, executable: str, output: Path, seed: int) -> list[str]:
    result = [executable, '--headless', '--max-fps', '60', '--path', str(ROOT),
              '--script', 'tools/balance_headless.gd', '--', f'--database={args.database.resolve()}',
              f'--output={output.resolve()}', f'--seed={seed}', f'--left={args.left}',
              f'--right={args.right}', f'--left-count={args.left_count}', f'--right-count={args.right_count}',
              f'--speed={args.speed}', f'--seconds={args.seconds}']
    if args.unpaced:
        result.append('--unpaced')
    if args.swap_sides:
        result.append('--swap-sides')
    return result


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('action', choices=['validate', 'simulate', 'watch'])
    parser.add_argument('--database', type=Path, default=DEFAULT_DB)
    parser.add_argument('--godot', default='godot')
    parser.add_argument('--output', type=Path, default=ROOT / 'balance-results')
    parser.add_argument('--left', default='peasant_flailman')
    parser.add_argument('--right', default='heavy_gendarme')
    parser.add_argument('--left-count', type=int, default=100)
    parser.add_argument('--right-count', type=int, default=20)
    parser.add_argument('--seed', type=int, default=1524)
    parser.add_argument('--runs', type=int, default=1)
    parser.add_argument('--speed', type=float, default=10)
    parser.add_argument('--seconds', type=float, default=300)
    parser.add_argument('--unpaced', action='store_true', help='Run as fast as CPU allows; same fixed ticks, not a 10x wall-time claim')
    parser.add_argument('--swap-sides', action='store_true')
    args = parser.parse_args()
    try:
        snapshot = load(args.database)
        if args.action == 'validate':
            print(f'VALID: {snapshot.balance_id}; {len(snapshot.document()["units"])} units; SHA-256 {snapshot.sha256}')
            return 0
        if not 1 <= args.runs <= 100 or not 0.1 <= args.speed <= 100 or not .05 <= args.seconds <= 3600:
            raise BalanceError('Require runs 1..100, speed 0.1..100 and seconds 0.05..3600')
        if min(args.left_count, args.right_count) < 1 or args.left_count + args.right_count > 200:
            raise BalanceError('Require 2..200 total units and at least one per army')
        if not -(2**31) <= args.seed < 2**31 - args.runs:
            raise BalanceError('Seed/runs must fit the supported signed 32-bit seed interval')
        snapshot.unit(args.left)
        snapshot.unit(args.right)
        executable = engine_path(args.godot)
        prepare_output(args.output)
        # A fresh checkout needs Godot's class cache. Explicit import is outside
        # measured fight time; an already-running watch session does not restart.
        imported = subprocess.run([executable, '--headless', '--path', str(ROOT), '--editor', '--import', '--quit'],
                                  capture_output=True, text=True, timeout=120)
        log = imported.stdout + imported.stderr
        if imported.returncode or re.search(r'(?m)^(SCRIPT ERROR|ERROR):', log):
            raise BalanceError('Godot import failed:\n' + log)
        if args.action == 'watch':
            if args.runs != 1:
                raise BalanceError('watch uses one seed; --runs is for independent simulate trials')
            print('Watching in one Godot process. Save JSON to queue a new fight; Ctrl+C stops.', flush=True)
            return subprocess.call(command(args, executable, args.output / 'watch.json', args.seed) + ['--watch'])
        for index in range(args.runs):
            seed = args.seed + index
            output = args.output / f'arena-{seed}.json'
            csv_path = output.with_suffix('.csv')
            output.unlink(missing_ok=True)
            csv_path.unlink(missing_ok=True)
            process = subprocess.run(command(args, executable, output, seed), capture_output=True, text=True,
                                     timeout=max(120, args.seconds / args.speed + 60))
            log = process.stdout + process.stderr
            print(log, end='')
            if process.returncode or re.search(r'(?m)^(SCRIPT ERROR|ERROR|BALANCE_ERROR):?', log) or not output.is_file():
                raise BalanceError('Simulation failed; no valid fresh report')
            report = json.loads(output.read_text(encoding='utf-8'))
            if report['outcome'] not in ('elimination', 'draw', 'timeout') or report['database_sha256'] != snapshot.sha256:
                raise BalanceError('Report is incomplete or input changed during the batch; rerun the batch')
            export_csv(report, csv_path)
            print(f'JSON: {output}\nCSV:  {csv_path}')
        return 0
    except (BalanceError, OSError, ValueError, subprocess.SubprocessError) as error:
        print(f'BALANCE_ERROR: {error}', file=sys.stderr)
        return 2
    except KeyboardInterrupt:
        return 130


if __name__ == '__main__':
    raise SystemExit(main())
