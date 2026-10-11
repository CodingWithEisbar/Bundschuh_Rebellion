#!/usr/bin/env python3
"""Run the pinned Godot compiler/import, real model tests, and scene smoke test.

No Python dependencies. Invoke from any directory:
    python tools/verify.py --godot /path/to/godot
"""
from __future__ import annotations

import argparse
import json
from pathlib import Path
import re
import shutil
import subprocess
import sys

ROOT = Path(__file__).resolve().parents[1]


def run(command: list[str], timeout: int = 180) -> None:
    result = subprocess.run(command, cwd=ROOT, text=True, capture_output=True, timeout=timeout)
    combined = result.stdout + result.stderr
    print(combined, end="")
    # Godot can exit 0 after some import/parse errors. Do not trust exit code alone.
    if result.returncode or re.search(r"(?m)^(?:SCRIPT ERROR|ERROR):", combined):
        raise RuntimeError(f"Godot validation failed (exit {result.returncode}).")


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--godot", default="godot", help="Godot 4.5.2 standard executable")
    args = parser.parse_args()
    executable = shutil.which(args.godot)
    if executable is None:
        candidate = Path(args.godot).expanduser().resolve()
        if not candidate.is_file():
            parser.error("Godot not found. Pass --godot with the executable's full path.")
        executable = str(candidate)
    version = subprocess.check_output([executable, "--version"], text=True).strip()
    if not version.startswith("4.5.2."):
        parser.error(f"Expected the pinned Godot 4.5.2 runtime, received {version}.")
    report_path = ROOT / "test-results" / "stage1.json"
    report_path.unlink(missing_ok=True)
    common = [executable, "--headless", "--path", str(ROOT)]
    try:
        run(common + ["--editor", "--import", "--quit"])
        run(common + ["--script", "tests/run_tests.gd"])
        if not report_path.is_file():
            raise RuntimeError("Test runner exited without creating its report.")
        report = json.loads(report_path.read_text())
        if report["failed_assertions"] or report["passed"] < 18:
            raise RuntimeError("Test report is incomplete or contains failures.")
        run(common + ["--script", "tests/layout_smoke.gd"])
        run(common + ["--quit-after", "10"])
        print(f"VERIFIED: {report['passed']} integration cases. Report: {report_path}")
    except (RuntimeError, subprocess.SubprocessError, OSError, ValueError) as error:
        print(str(error), file=sys.stderr)
        return 1
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
