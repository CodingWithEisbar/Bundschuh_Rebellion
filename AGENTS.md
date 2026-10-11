# Repository guidance

This is the Godot 4.5.2 Standard / typed GDScript Stage 1 RTS prototype.

## Before changing gameplay

- Read README.md and docs/STAGE_1_ARCHITECTURE.md.
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
