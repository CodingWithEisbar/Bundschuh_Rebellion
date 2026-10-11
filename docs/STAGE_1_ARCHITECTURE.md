# Stage 1 architecture

## Decision: Godot 4.5.2 Standard + typed GDScript

A small 2D RTS foundation benefits from Godot's editor, native AStarGrid2D,
signals and command-line runner without requiring a separate .NET toolchain.
The simulation stays in RefCounted model classes; presentation is replaceable.
This is a project-specific engineering choice, not a claim that another engine
cannot support 200 units.

We pin 4.5.2 for reproducibility, not because it is necessarily the newest release.
The current scene is a top-down greybox. Stage 4's isometric projection and sprite
pipeline can replace RtsWorldView without changing integer grid coordinates.

## Ownership

~~~mermaid
flowchart TB
    Input["Input and commands"] --> Sim["RtsSimulation"]
    Sim --> AI["VillagerAI"]
    AI --> Paths["PathService"]
    Paths --> Traffic["TrafficController"]
    Sim --> Build["Placement and construction"]
    Build --> Grid["WorldGrid"]
    Grid --> Paths
    AI --> Bank["ResourceBank"]
    Bank --> HUD["HUD"]
    Traffic --> View["World view"]
~~~

| Class | Owns | Does not own |
|---|---|---|
| WorldGrid | Bounds, terrain/foundation solidity, geometry revision, connectivity | Moving agents |
| PathService | Request generations, capped native queries, routes/cache | Physical occupancy or economy |
| TrafficController | Movement intents, exclusive cells, compatible simultaneous moves | Jobs, stockpile, building costs |
| VillagerAgent | Job/navigation/cargo data | Scene nodes and input |
| VillagerAI | Job transitions and arrival/work checks | Rendering |
| GatherableResource | Remaining finite quantity; atomic take | Global bank |
| ResourceBank | Integer stockpile; all-or-nothing spending; changed signal | Worker cargo |
| RtsBuilding | Construction work, HP, completion and accepted resource types | Pathfinding |
| RtsSimulation | Composition, commands, fixed clock, interactions and placement transaction | GPU presentation |
| RtsWorldView / main | Camera, input, visual sampling, HUD | Authoritative balances |

## Time and movement

Simulation step: **0.05 seconds**. All Stage 1 villagers use **0.80 tiles/second**,
so an adjacent-cell movement takes **1.25 seconds**. A central movement round
selects compatible steps; presentation samples their continuous trajectories.

During a movement segment, agent.cell is the reserved destination and
agent.from_cell is the origin. Both cells remain unavailable to new building
foundations until the motion finishes. VillagerAI checks in_transit before work:
a worker cannot gather, deposit or build before its body arrives.

The renderer interpolates these explicit endpoints. Opposite pairs use symmetric
side arcs of amplitude 0.25 cells and body radius 0.18 cells. This leaves clearance
inside a one-cell-wide corridor. It is visible coordinated passing, not stacked
units or instant teleportation.

A future combat system must sample the movement trajectory for physical distance,
rather than interpreting the reservation endpoint as an already-arrived body.

## Pathfinding pipeline

1. A group command chooses distinct accessible arrival cells near the click.
   The far side of the formation is filled first to reduce entrance congestion.
2. Static connected-component labels reject truly disconnected targets early.
3. A request carries a unit ID and generation. New orders invalidate older results
   and overwrite that unit's pending queue slot, keeping command spam bounded.
4. At most **12 native A* queries per fixed tick** are issued; scanning obsolete
   queue entries is separately capped at 64.
5. Native AStarGrid2D uses Manhattan cost and four orthogonal neighbors. Diagonal
   corner cutting is impossible. Units never re-run A* every rendered frame.
6. Static routes are cached, capped at 256 entries, keyed by geometry revision,
   start and destination.
7. After sustained waiting, a throttled replan uses occupied cells as soft cost 4.
   Actual harvesting/building workers can be temporarily excluded. These temporary
   values are restored immediately and never change static geometry revision.
8. Failure with dynamic exclusions retries the static route through the same
   bounded queue. Congestion is not declared permanently unreachable.
9. A foundation or depleted resource updates only affected solid cells, increments
   revision and causes stale routes to be rescheduled. Do not call AStarGrid2D.update
   after every obstacle: that API clears solid/weight data.

A query budget bounds the number of calls, not the worst-case execution time of
one search. The verified fixture is 60×30; much larger maps need profiling, sector
navigation and/or hierarchical routing before scaling this system.

## Traffic arbitration

A* produces a preferred next cell. TrafficController resolves the crowd:

- Build one occupancy map for the movement round.
- Protect mutual head-on pairs before normal destination arbitration.
- Rank remaining proposals by waiting age, remaining route length and stable ID.
- Grant at most one intent per destination.
- Trace dependency chains: a chain ending in free space can move; a compatible
  closed cycle can rotate; a chain ending at an anchored blocker waits.
- Let idle/waiting friendlies yield after a short wait. Pause a following claimant
  for that round when necessary to make room for the yielding pair.
- Commit approved moves together. Opposite pairs use separated curved trajectories.
- A settled formation member returns to its assigned slot after yielding.
- Replan sustained congestion at a controlled frequency; retain waiting priority.

This handles the tested one-way 200-unit corridor and opposing traffic cases.
It is not a mathematical completeness proof for all multi-agent puzzles.
Two adjacent agents of radius 0.4, a cannon, or an enemy blocking combat cannot
reuse the friendly passing rule. Add clearance classes/portal policies first.

## Resource loop

~~~mermaid
stateDiagram-v2
    Idle --> MoveToResource: Gather order and slot
    MoveToResource --> Gather: Physical arrival
    Gather --> ReturnToDropoff: Full cargo or depleted node
    ReturnToDropoff --> MoveToResource: Deposit and resume
    MoveToResource --> Waiting: No accessible slot
    ReturnToDropoff --> Waiting: No completed drop-off
    Waiting --> MoveToResource: Resource access restored
    Waiting --> ReturnToDropoff: Drop-off available
    Gather --> Idle: Stop
~~~

Each node has a kind, finite remaining quantity and blocked footprint. Workers
claim distinct orthogonal perimeter cells. Extra workers wait and retry; they
do not gather from across walls or stack in one interaction point.

Gathering accumulates fractional work but removes **integer resource units**.
Only GatherableResource.take may remove them. The last two workers cannot both
consume the final unit.

A full or final partial load is delivered to a completed compatible drop-off.
Candidates are ordered by Manhattan proximity, then checked for connected
interaction cells. This is not an expensive shortest-path-distance comparison
across every possible depot.

The invariant per resource kind, before construction spending, is:

    initial resource quantity
      = remaining on nodes + carried by workers + deposited into the bank

Depositing clears cargo and credits the bank once. Changing resource kind first
returns existing cargo; Stop/Move/Build orders preserve it. A missing/destroyed/
unfinished drop-off makes workers retain cargo and retry, not discard it.

ResourceBank emits a copied snapshot for the HUD. Rendering cannot modify stock.

## Placement and construction

Preview is a read-only call to validate_placement:

- Check the building is in Stage 1's placeable catalog.
- Check the entire cost can be paid.
- Check every footprint cell lies in bounds and is clear of terrain/resources/
  buildings, current/transit unit occupancy, interaction claims and reserved goals.
- Temporarily consider the proposed footprint blocked when flood-filling from
  selected builders. At least one must reach a valid edge cell.
- Return an explicit reason used by the green BUILD/red BLOCKED preview.

Confirmation repeats validation because resources and occupants may have changed.
Only then is the cost debited and the foundation registered. A duplicate click
cannot charge twice because the footprint is already blocked.

A foundation starts at **0 HP** and contributes no drop-off/housing functionality.
Each arrived builder contributes one work-second per simulation second.
Multiple builders add linearly in this prototype. HP rises proportionally to work,
clamped to MaxHP. The completion signal and housing increment happen once.

There is no combat/damage in Stage 1. When adding it, keep construction work and
current HP separate; progress must not accidentally heal previous damage.

## GDD mapping and explicit tuning

| Parameter | Value / status |
|---|---|
| Villager carry | Base 10; League A3 adds 3 in model |
| Villager movement | 0.80 tiles/second |
| Bundschuh gathering | Food/Wood ×1.10, applied once to work rate |
| House | 25W, 25 work-seconds, +5 housing on completion |
| Mill / Lumber / Mining Camp | 100W, 35 work-seconds; resource acceptance follows GDD |
| Additional Town Center | Not offered by Stage 1 placement UI; avoids bypassing Age 3 unlock |
| Base gather rates F/W/G/S | 0.40 / 0.39 / 0.38 / 0.36 units/sec — prototype tuning |
| House / camps / Town Center HP | 550 / 600 / 2400 — prototype tuning |
| Footprints | 2×2 for House/camps, 3×3 TC — prototype tuning |
| Multiple builders | Linear work contribution — explicit Stage 1 rule |
| Population | 200 test cap; scenario grants are separate from normal housing checks |
| Normal demo | 16 villagers; scenario stockpile/housing, not standard ranked opening |
| Stress demo | 200 villagers; same real simulation code |

The full GDD's Ages, higher Bundschuh caps, recruitment, combat, campaigns and
presentation remain future scope. Stage 1 does not change their design decisions.

## Extension points

- **Combat:** typed unit definitions, real position sampling, hit/armor/counter
  system, ownership and enemy collision rules; maintain the resource tests.
- **Different sizes:** clearance-aware static navigation and portal arbitration;
  do not enlarge VillagerAgent.RADIUS while retaining the same passing math.
- **Isometric assets:** replace projection in RtsWorldView, keep simulation cells.
- **Save/load:** serialize IDs, job state, cargo, claims, bank, timers and movement
  phase. Rebuild native A* and invalidate request generations on load.
- **Multiplayer:** define command ordering, deterministic state representation,
  synchronization/replay and desync checks. This project does not claim lockstep.
- **Larger populations/maps:** profile first, then hierarchical/sector paths or
  shared integration fields; the current bounded A* service is sufficient only
  for the measured slice.

## Primary technical references

- [Godot 4.5 AStarGrid2D](https://docs.godotengine.org/en/4.5/classes/class_astargrid2d.html):
  orthogonal modes, Manhattan heuristic, solid/weight updates and update() behavior.
- [Godot 4.5 command-line tutorial](https://docs.godotengine.org/en/4.5/tutorials/editor/command_line_tutorial.html):
  headless execution, scripts, editor import and project selection.
- [Godot 4.5.2 archive](https://godotengine.org/download/archive/4.5.2-stable/):
  pinned standard engine distribution.

All traffic rules, simulation architecture and tuning above are project code/design,
not behavior guaranteed by the engine's A* API alone.
