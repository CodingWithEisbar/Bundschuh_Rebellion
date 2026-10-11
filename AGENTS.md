# Repository guidance

This is the Godot 4.5.2 Standard / typed GDScript RTS prototype: Stage 1 playable
economy/navigation and Stage 2 combat backend.

## Before changing gameplay

- Read README.md and docs/STAGE_1_ARCHITECTURE.md.
- For combat also read docs/STAGE_2_COMBAT.md. Its explicit Stage 2 rules supersede
  the older GDD's aura/payroll tuning for this opt-in backend only.
- Consult the relevant docs/gdd phase for costs, faction rules and future scope.
- Keep simulation models independent from Node/UI APIs. Inject the world/services;
  do not introduce global scene-tree lookups inside workers.
- Static terrain belongs to WorldGrid. Dynamic bodies belong to TrafficController.
  Do not bake every moving unit into static A* solidity.
- Preserve integer resource conservation, exclusive interaction claims, bounded
  path requests and one-shot building completion.
- Keep the distinction between a movement reservation endpoint and the sampled
  continuous position. Work occurs only after arrival.
- Changes to unit radius, movement cadence, path arbitration or interaction slots
  require the crowd/resource regression cases. Uniform foot-unit passing is not
  a clearance system for cavalry/siege.
- Do not label new prototype tuning as a historical fact or a verified GDD balance.
- Do not introduce campaign-only Zeal/Fear, payroll or printing buffs into the
  default sandbox as faction passives.
- The user explicitly requested Stage 2's 6-tile / 15% speed aura and 30-second
  mercenary payroll with mutiny at zero Gold. Do not silently restore the older
  damage aura or 120-second campaign grace rules. Payroll remains scenario opt-in.
- Use the existing player ResourceBank and simulation clock. Keep modifier keys
  idempotent, same-tick lethal trades simultaneous, and desertion ownership real.
- Combat positions are physical centers, never Stage 1 reservation endpoints.
  Do not claim varied-speed enemy/cavalry traffic is solved by the friendly
  villager controller. The Stage 2 host/navigation adapter contract is explicit.

## Validation and delivery

Run:
    python3 tools/verify.py --godot /absolute/path/to/godot

Use the pinned 4.5.2 executable. Update meaningful tests when behavior changes.
Godot can exit 0 on some script errors; use the wrapper, which checks its output
and requires the fresh JSON report.

Commit .gd.uid sidecars with their scripts. Do not commit .godot, test-results,
engine binaries, temporary screenshots or build output. Avoid adding dependencies
without an actual requirement. Keep Vietnamese onboarding instructions usable.

This project is already backed by Git; source and its docs belong in this repo.
