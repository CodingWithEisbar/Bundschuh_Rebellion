# Stage 5 validation

Validated **2026-10-12**, Godot **4.5.2 Standard**, Linux headless, using:

```sh
python3 tools/verify.py --godot /absolute/path/to/Godot_v4.5.2-stable_linux.x86_64
```

The wrapper deletes stale reports, imports/compiles, checks engine output as well
as exit codes, and requires fresh passing reports. CI runs this same command with
the pinned, SHA-256-verified engine archive. Python tooling uses only the standard
library (Python 3.10+).

## Gates

| Suite / gate | Result |
|---|---|
| Import / compilation | PASS |
| Stage 1 | 18 cases, 111 checks |
| Stage 2 | 22 cases, 138 checks |
| Stage 3 | 21 cases, 177 checks |
| Stage 4 | 23 cases, 144 checks |
| Stage 5 Godot | 16 cases, 84 checks |
| Godot suites total | **100 cases, 654 checks, 0 failures** |
| Python parser/report/live reload | **7 cases**, no failures or skips |
| All suites | **107 cases** |
| Paced 100-vs-20 CLI + JSON/CSV output | PASS |
| Stage 2/3/4 demos | PASS |
| Existing HUD layout/input and main scene smoke | PASS |

The Python assertion total is not instrumented; it is not included in the 654
Godot checks. Reports are generated in `test-results/stage1.json` through
`stage5.json`, plus `stage5_python.json` and `stage5_cli/arena-1524.json`/CSV.

## Meaningful behavior covered

- Exact Phase 2 HP/attack/armor/speed/period/cost for all four core units; base
  Gendarme maps to Armoured Ritter. All ten existing enum kinds resolve from JSON.
  Flailman +4 Spear, Landsknecht +24 Cavalry and Stage 2 Pike +25 remain separate.
- Syntax rejects malformed JSON, trailing commas, duplicate keys, invalid escapes,
  non-JSON numbers and control characters; valid Unicode surrogate pairs pass.
  Input size/depth bounds, unsupported versions, missing/unknown keys, bad numeric
  types/ranges and unknown armor classes are exercised.
- Duplicate IDs/aliases, inverted range, inconsistent support attack fields and
  invalid Zeal sources reject. Bad reloads do not change data/hash/generation.
  Identical data is a no-op; a valid revision emits once and clears prior errors.
- Exported definitions/documents are defensive copies. A fork pins its revision.
  An existing wounded unit retains HP, max HP, attack, recovery and old hash; a
  new spawn receives the edited HP/attack and revision.
- Editing attack, period, impact marker and movement speed changes real
  CombatWorld damage timing and movement budget. JSON Zeal radius/rates alter
  membership and stats without stacking duplicate sources.
- Default setup produces 120 separate bodies and correct initial HP/base cost
  vectors. Unknown units and roster overflow reject. A larger-body, high-speed
  fixture checks non-overlap and closed boundaries throughout actual movement.
- Same seed reproduces deployment and a complete 100-vs-20 report. Different
  seeds alter deployment without touching global gameplay RNG. Geometry and
  roster/HP conservation are checked during/after the baseline fight.
- 1x and 10x clock pumping produces the same logical fight. Catch-up budgets
  retain debt; support-only fights time out without an invented winner; mutually
  lethal attacks draw; a running arena pins even later spawns to its revision.
- **Real live reload:** Python launches one Godot process in watch mode, waits
  for its first report, writes invalid JSON, observes rejection and no new fight,
  then writes valid 90 HP Flailman data. The same process produces generation 2
  with the new HP/hash. The first result remains at 45 HP; CSV preserves team
  values and individual resource costs.
- Generated report folders are excluded from Godot's asset importer; source
  folders/project root cannot be accidentally hidden by the output helper.

## Reproducible 100-vs-20 baseline

Source SHA-256:

```text
a003cc27a4343aeb8be1a1250420c9f3450c1618b7ff42fa539e6427783a0641
```

Arena version 1; 40×32 flat closed tiles; seed 1524; 20 Hz; no upgrades, faction
bonuses, payroll or economy; default base radii 0.18. All combat uses the actual
CombatWorld, with local swept-circle movement and nearest-target AI.

| Metric | Flailmen | Gendarmes (base Ritter) |
|---|---:|---:|
| Initial count | 100 | 20 |
| Initial total HP | 4,500 | 2,500 |
| Survivors | 0 | 6 |
| Casualties | 100 | 14 |
| Survival rate | 0% | 30% |
| Remaining HP | 0 | 190 |
| HP retained | 0% | 7.6% |
| Mean HP per survivor | 0 | 31.67 |
| Base Food / Wood / Gold / Stone | 4,500 / 1,500 / 0 / 0 | 1,800 / 0 / 2,000 / 0 |

Elimination at **1,849 ticks / 92.45 simulated seconds**; first contact damage at
6.35s; 862 resolved attacks. One paced local run took **9.251168 real seconds**,
measuring **9.9933x** against the requested 10x. Startup/import and report writing
are outside that wall-time interval. See the committed [JSON](balance_samples/baseline-1524.json)
and [CSV](balance_samples/baseline-1524.csv) for the source snapshots and timeline.

## Deployment sensitivity sample

Same data, counts and arena; five consecutive seeds, run unpaced. These are five
geometry variants of one AI test, not independent samples of human skirmish play.

| Seed | Game seconds | Flailmen left | Gendarmes left | Gendarme HP left |
|---|---:|---:|---:|---:|
| 1524 | 92.45 | 0 | 6 | 190 |
| 1525 | 82.85 | 0 | 8 | 405 |
| 1526 | 80.75 | 0 | 8 | 455 |
| 1527 | 82.50 | 0 | 7 | 425 |
| 1528 | 91.75 | 0 | 6 | 365 |

Machine: AMD EPYC 9V74 80-Core Processor. The unpaced logical result for seed 1524
matches the paced result. Timings are observations, not performance gates or FPS
claims. [Seed sweep CSV](balance_samples/seed-sweep.csv) records the configuration hash.

## Interpretation limits

Flailmen are Spear counters, not Cavalry counters. In this base matchup they hit
for 5, Gendarmes for 12. The result is sensitive to frontage, target selection,
body radius and movement arbitration. The two armies are not equal in resources
or population, and no universal Gold-to-Wood value is assumed.

This does not certify faction balance, a ranked win rate, full military
pathfinding through terrain, healing, charge behavior, recruitment economics,
multiplayer determinism, GPU performance or asset/audio quality. Runtime reload
is a developer workflow; existing units keep their revision, and resetting the
fight is the supported way to apply an edit to a whole army. Final balancing still
requires mixed-army, map/economy and human playtests.
