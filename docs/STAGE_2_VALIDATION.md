# Stage 2 validation

Local run: **2026-10-12, UTC+7**. Engine: **Godot 4.5.2 stable official**.
Command:

```sh
python3 tools/verify.py --godot /absolute/path/to/Godot_v4.5.2-stable_linux.x86_64
```

## Result

**40/40 integration cases, 249 checks, zero failed assertions.**

| Gate | Observed result |
|---|---|
| Godot editor import / script compilation | Passed; no parser/runtime errors |
| Stage 1 regressions | 18/18 cases, 111 checks |
| Stage 2 regressions | 22/22 cases, 138 checks |
| Runnable backend demo | `BACKEND DEMO: PASS` |
| Existing HUD geometry / input | Passed at 1280×720, 1440×900, 1920×1080 |
| Main-scene startup | Passed headless smoke test |

The verifier rejects Godot `SCRIPT ERROR` / `ERROR` messages even if the process
returns exit code 0. It deletes old reports before running and requires fresh
results for both stages. CI uses this same command and the existing pinned engine
download/checksum; GitHub Actions remains the source of truth for remote runs.

## Observable cases covered

- Correct normal armor channel, minimum one normal damage, additive Cavalry
  counter, independent class resistance, no negative counter or support attack.
- Duplicate classes and individual-unit stat mutation cannot duplicate or leak
  counter values into other units.
- Ownership, allied-owner rejection, minimum/maximum range, actual HP loss.
- Both same-tick lethal swings land; deaths and registry cleanup happen once;
  entity IDs are never reused.
- Attack rate affects real hit count; Stop/reissue cannot reset recovery.
- Exact six-tile circular aura boundary, negative coordinates, allied different
  owners, enemies and wrong-faction sources.
- Ten overlapping sources over twenty seconds remain one buff; removal of one
  source preserves others; removing Zeal preserves another modifier.
- Moving out/back, garrison/deployment, death and ownership changes remove or
  restore buffs without permanently changing base stats.
- Pause and delta subdivision (0.01 / 0.05 / 0.25s) preserve 1s/30s deadlines.
- Timely/full/partial/exact-to-zero/zero-start payroll, configurable wages,
  observable shared-bank updates, no negative Gold, no empty-army desertion.
- Disabled scenario payroll, dead/despawned/garrisoned soldiers, separate owner
  banks, owner transfers, late player registration and post-mutiny reinforcements.
- Mutiny changes team/ownership, invalidates old orders, refuses former owner
  commands and automatically damages a nearby former ally.
- Garrisoned mutineers lose ownership but wait for a valid host-provided exit;
  the backend does not invent an overlapping field position.
- Once-only desertion for an affected roster; later deposits do not auto-rehire it.
- RtsSimulation bridge advances Stage 2 once and uses the original ResourceBank.
- Forty spatial queries agree with a brute-force reference over 200 spread-out
  units, including negative positions; candidate work is below a full scan.

## Dense 200-unit backend benchmark

CPU reported by the runtime: **AMD EPYC 9V74 80-Core Processor**. One local run,
debug/standard executable, headless, 60 simulated seconds at 20Hz.

| Measurement | Observed |
|---|---:|
| Live units | 200 |
| Preachers / attack orders | 20 / 180 |
| Resolved hits | 4,770 |
| Aura scans / spatial rebuilds | 60 / 60 |
| Dense candidate checks per aura scan | 4,000 |
| Simulation step p50 | 0.238 ms |
| Simulation step p95 | 1.973 ms |
| Maximum observed step | 3.871 ms |
| Payroll | Two bills for 90 Landsknechts each |

This is a deliberately **synthetic overlapping cluster**, with endurance HP,
to exercise worst-case aura overlap plus active combat. It does not demonstrate
military collision, cavalry pathfinding, rendering, frame rate, win rate or
performance on the user's PC. Timing numbers are observations, not CI thresholds.
The existing separate Stage 1 200-villager corridor regression also passed.

## Backend demo output checked

- Two Preachers: Pike movement approximately 1.15 tiles/s and period 3/1.15 ≈ 2.609s.
- Pike → unupgraded Ritter: 2 normal + 25 counter = 27 damage, leaving 98 HP.
- Two Landsknechts with initial 5 Gold: balance 3 at 30s, 1 at 60s, 0 at 90s.
- At 90s, one DesertionEvent contains both IDs and they have hostile ownership.

## Remaining integration scope

Stage 2 is the requested backend slice. Military navigation with variable speeds,
rendered military units/selection, combat UX, projectile/LOS logic, garrison exit
placement, population/recruitment binding and save/load are not implemented by
these tests. The movement getter/budget is verified; it is not wired into Stage
1's uniform-speed villager traffic. See the adapter contract and explicit GDD
overrides in [STAGE_2_COMBAT.md](STAGE_2_COMBAT.md).
