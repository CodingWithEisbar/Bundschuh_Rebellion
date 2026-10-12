# Stage 3 validation

Validated on **2026-10-12** with **Godot 4.5.2 Standard**, Linux headless, using:

```sh
python3 tools/verify.py --godot /absolute/path/to/Godot_v4.5.2-stable_linux.x86_64
```

The wrapper deletes previous JSON reports, imports/compiles the project, checks
engine output for script errors even when exit code is 0, and requires a fresh
passing report from every suite. CI runs the same wrapper with the pinned engine
archive and SHA-256 verification.

## Results

| Gate | Result |
|---|---|
| Project import / script compilation | PASS |
| Stage 1 economy/navigation/construction | 18 cases, 111 checks, 0 failures |
| Stage 2 combat/aura/payroll | 22 cases, 138 checks, 0 failures |
| Stage 3 maps/height/stealth | 21 cases, 177 checks, 0 failures |
| Total model/integration suites | **61 cases, 426 checks, 0 failures** |
| Stage 2 CLI backend demo | `BACKEND DEMO: PASS` |
| Stage 3 CLI backend demo | `STAGE 3 DEMO: PASS` |
| HUD geometry/input | PASS; 34 controls inventoried at 1280×720, 1440×900, 1920×1080 |
| Main scene headless startup | PASS |

Reports are generated locally as `test-results/stage1.json`, `stage2.json` and
`stage3.json`; these transient outputs are intentionally not committed.

## New behavior exercised

- Same seed/recipe reproduces terrain, elevations, spawns and mineral veins;
  different seeds differ; no mutation of the global gameplay RNG.
- Ten default seeds: 0, 1, 2, 17, 42, 1524, 1525, -17, 991, 999999. Each has
  connected ground/spawns, protected corridors, six gold/four stone veins, and
  every ore cell has a reachable orthogonal interaction edge. Forest clustering
  is checked, not just total tree count.
- Width 1/3/5 on the minimum 48×32 map: exactly three initial spine openings of
  that width. Invalid sizes/parameters reject before allocation; an over-demanded
  recipe exhausts its configured two attempts and returns errors.
- 160×160 generation validates connectivity/resource access. This verifies
  supported dimensions, not the full ranked RMS fairness specification.
- Runtime factory preserves tree/ore budgets; depletion opens collision cells.
  Workers gather and deliver Wood through the actual economy loop; all 16 cross
  a generated passage and settle at distinct destinations.
- Damage resolves armor/counter before the height multiplier. Pike 27→34;
  minimum channel, rounding ties, equal/lower ground, large height difference,
  support units, explicit negative height and invalid coordinates are checked.
- Terrain-bound combat samples the actual physical tile at spawn/move/hit,
  refreshes both sides after terrain edits, and rejects competing manual height.
  Uneven building footprints reject without making a traversable terrace solid.
- Mission ignores friendly guards, unknown IDs and non-hero actors. Partial
  exposure decays; overlapping/duplicate sightings do not multiply fill rate;
  prolonged visibility remains one episode; premature reentry cannot add counts.
- Third rearmed detection emits failure once; completion/failure are terminal;
  disabled/deleted guards release sightings; pause freezes game-time progress;
  root clock integration and config snapshot behavior are checked.
- **Real Godot 2D physics**: a two-shape hero enters/exits two guard Areas, a decoy
  overlaps without detection, disabled/re-enabled guards update the visible
  union, guard deletion cleans up, and hero deletion cannot leave ghost exposure.
  Tests wait for physics frames; they do not manually invoke adapter callbacks.
- Actual F8 keyboard input with seed focus creates seed 1525; reset clears drag
  and selection; invalid seed preserves the current world; Ctrl+A in the text
  field does not select villagers; returning to F6 restores its old fixture.

## Reproducible default map

| Property | Seed 1524, generator version 1 |
|---|---|
| Dimensions / attempt | 64×40 / 0 |
| Final forest | 60.8984375%, 1,559 tree tiles |
| Minerals | 15 Gold tiles, 11 Stone tiles in 10 veins |
| Runtime resource nodes | 1,588 including three starter Food nodes |
| Finite ore budgets | 12,000G and 3,850S, excluding starting bank grants |
| Initial passages | Three, each 3 tiles wide through a 5-tile forest spine |

Pinned-engine fingerprint:

```text
09b54894c0bf28c16aeb94d23bdff881d2e0c4acf75054e1aa84b5b1ebed6022
```

Logging later changes navigation; this fingerprint describes initial generation.
The recipe's 0.63 forest probability is not a final density quota.

## Timing sample and limits

One local run on **AMD EPYC 9V74 80-Core Processor**:

| Measurement | Observed |
|---|---|
| 64×40 generation, ten listed seeds | Median 124.217 ms; maximum 133.468 ms |
| 160×160 generation, seed 1525 | 832.965 ms; attempt 0 |

These are single-machine **generator** measurements, excluding runtime factory,
rendering and GPU. They are recorded as observations, not pass/fail thresholds or
FPS promises. The large map has 77.984375% forest; it does not meet the old GDD's
ranked 45–55% forest target and is not presented as doing so.

The 200-unit crowd regression remains the Stage 1 friendly uniform-radius
fixture. Stage 3 generated-map integration uses 16 villagers; it does not certify
mixed-size military navigation on every possible procedural seed. Combat and
stealth are backend systems, not a complete playable campaign.

HUD validation uses real Godot Control/font geometry in headless mode. It is not
a screenshot, GPU rendering review, art approval, audio review or desktop FPS
benchmark. The LOS test verifies authored collider volumes, not occlusion through
walls/forest. Ranked fairness, fog of war, patrol AI, a campaign scene, multiplayer
and save/load remain outside this stage.
