# Recorded Stage 5 examples

These are reviewable observations from Godot 4.5.2, not target win-rate fixtures.

- `baseline-1524.json`: complete 100 Flailmen vs 20 base Gendarmes report, paced
  at requested 10x; includes both unit snapshots, database hash and HP timeline.
- `baseline-1524.csv`: the same report as two army rows.
- `seed-sweep.csv`: five deployment seeds using the same data, run unpaced.

Reproduce from repo root:

```sh
python tools/balance.py simulate --godot /path/to/godot --seed 1524
python tools/balance.py simulate --godot /path/to/godot --seed 1524 --runs 5 --unpaced --output balance-results/sweep
```

Wall timings vary. Logical results are reproducible with the pinned engine/data
and arena version on the tested platform. See `docs/STAGE_5_VALIDATION.md` for
conditions and limits. Preserve these files as baseline observations; put new
experiments in their own output directory.
