# Stage 1 validation record

**Date:** 2026-10-11
**Runtime:** Godot 4.5.2 Standard, official Linux x86_64 build
**Method:** real Godot import/compiler, model integration tests, actual Control
layout/input checks in headless mode, and main-scene startup.

## Result

- **18/18 integration cases passed; 111 assertions/checks; zero reported errors.**
- Main scene initializes with 16 actual model workers; the stress control creates 200.
- HUD layout passed at **1280×720, 1440×900 and 1920×1080** (32 controls checked).
- Space pauses correctly while a button has focus.
- Releasing selection drag over the HUD ends the drag.
- The verification wrapper rejects script/runtime errors even if Godot exits 0.

Run locally or in CI:

    python3 tools/verify.py --godot /path/to/Godot-4.5.2

The fresh machine-readable report is generated in test-results/stage1.json.
Generated reports are ignored by Git; the values here document one measured run.

## Covered behaviors

| Area | Cases |
|---|---|
| Grid | Obstacles, removal/revision, map boundaries, orthogonal steps |
| Queue | Per-tick query cap, coalescing repeated commands, stale-order cancellation |
| Movement | Static disconnection, opposing units, opposing 24-unit groups, occupied four-unit cycles, idle-blocker yielding |
| Economy | All four resource kinds, last partial loads, concurrent depletion, conservation on every sampled tick |
| Retasking | Cargo retained across resource changes; old type delivered before new type |
| Drop-offs | Missing/unfinished camp waits; resumed delivery after completion; removed camp retargets |
| Placement | Bounds, resource/unit obstruction, builder requirement, free preview, single debit, duplicate rejection, transit reservation |
| Construction | Multiple workers contribute; HP is monotonic and capped; completion/housing fire once |
| Dynamic terrain | Existing path reroutes around a new foundation |
| Claims | Stop releases interaction slots and prevents obsolete path results restarting a job |
| Scale | 200 units traverse a one-cell-wide, five-cell-long bottleneck and reach assigned distinct destination cells |

## Measured 200-unit fixture

Map: **60×30**. All 200 villagers start on one side of a terrain barrier with one
walkable corridor. The test requires all workers to cross and settle at their
assigned cells within 600 simulated seconds.

| Metric | Observed |
|---|---:|
| Completion | 200/200 |
| Simulated completion time | 356.3 seconds |
| Maximum A* queries in one tick | 12 |
| Median simulation step | 0.196 ms |
| 95th percentile simulation step | 1.822 ms |
| Maximum simulation step | 13.472 ms |
| CPU reported by test environment | AMD EPYC 9V74 80-Core Processor |

Simulation timings exclude rendering and the extra collision-audit work.
They are one container run, not a desktop FPS claim or a hardware requirement.
The test also samples interpolated body positions at 0%, 25%, 50%, 75% and 100%
of movement segments and checks separation and walkable terrain.

## Regression findings addressed during implementation

- Temporary congestion no longer becomes a permanently unreachable route.
- Queued moving units are not classified as stationary workers.
- A yielding idle unit can displace a following intent for one movement round.
- Settled formation members reform instead of being pushed back across the map.
- Head-on pairs are protected from competing follower claims before arbitration.
- Soft congestion costs and far-side formation fill reduce entrance blockage.
- Repeated group commands coalesce instead of growing the request queue indefinitely.

## Remaining validation before production release

- **GPU rendering and visual quality were not verified in this headless environment.**
  Control geometry and behavior were tested; run F5 on the target desktop to inspect
  drawing, input feel, readability and renderer-specific issues.
- CPU numbers above do not certify 60 FPS with finished sprites, particles or audio.
- Current collision/passing rules apply to uniform friendly foot units. Test
  clearance, enemy blocking and combat separately when adding different unit types.
- Save/load, networking, combat, fog of war and final faction content are outside
  this Stage 1 implementation.
- Passing these fixtures is evidence for the tested cases, not proof of global
  deadlock freedom for every adversarial multi-agent map.

A short manual playtest should exercise F6 gathering, all four building previews,
multiple builders, right-click retasking, pause/speed, F7 and opposing orders.
