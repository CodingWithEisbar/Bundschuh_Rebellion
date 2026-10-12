# Stage 4 validation

Validated on **2026-10-12** with **Godot 4.5.2 Standard**, Linux headless:

```sh
python3 tools/verify.py --godot /absolute/path/to/Godot_v4.5.2-stable_linux.x86_64
```

The wrapper removes stale reports, imports/compiles the project, checks engine
output as well as exit status, then requires fresh passing reports. GitHub
Actions runs the same wrapper with the pinned, SHA-256-verified engine archive.

## Results

| Gate | Result |
|---|---|
| Project import / script compilation | PASS |
| Stage 1 economy/navigation/construction | 18 cases, 111 checks, 0 failures |
| Stage 2 combat/aura/payroll | 22 cases, 138 checks, 0 failures |
| Stage 3 maps/height/stealth | 21 cases, 177 checks, 0 failures |
| Stage 4 animation/audio/assets | 23 cases, 144 checks, 0 failures |
| Total suites | **84 cases, 570 checks, 0 failures** |
| Stage 2, Stage 3 and Stage 4 CLI demos | PASS |
| Existing HUD geometry/input | PASS; 34 controls at three resolutions |
| Stage 4 lab geometry and F9/F6 scene handoff | PASS |
| Main scene headless startup | PASS |

The complete local gate emitted no `WARNING:`, `ERROR:` or `SCRIPT ERROR:` lines.
Fresh reports are generated in `test-results/stage1.json` through `stage4.json`;
reports, imported caches and engine binaries are not committed.

## Animation and combat checks

- A swing starts before damage. The authored contact marker resolves once at
  the first eligible 20 Hz tick and carries the same attack serial as its start.
  The fixture's marker 3/8 on a 3s period starts at tick 1 and hits at tick 24.
- Wind-up does not extend the existing attack period: the next cycle starts
  60 ticks after the first. Changing the marker during a swing is rejected.
- A rate modifier changes remaining cycle work without granting an early hit;
  pause stops work. Stop/Attack spam cannot skip recovery. Retargeting, leaving
  range, garrison, owner change or despawn cancels pending damage.
- Lethal impacts on the same tick still trade simultaneously. Stage 2 and Stage
  3 suites verify that the default zero-marker path preserves previous behavior.
- Actual movement scales Run cadence; no movement returns to Idle. The attack
  visual follows the simulation marker, and Die overrides all other states.
  Blend weights, non-looping death and corpse expiry use the central host clock.
- Missing clips, invalid contact frames and mismatched markers across eight
  directions fail during loading. Direction lookup uses authored clips.
- A bounded view pool reuses the same Nodes, clears old entity/asset references,
  rejects overflow of living units and reclaims a dying corpse for a new unit.

## Audio, voice and asset checks

- Hundreds of hit events between two soldiers count as two participants.
  Exactly ten does not enter Combat; eleven does. Camera bounds, permitted IDs,
  death, despawn and garrison filter the count. Events hidden when they occur
  cannot be replayed as recent fighting after visibility expands.
- Recent activity expires; a continuous five-second quiet hold returns to Eco.
  Polling occurs at 4 Hz, and a new match clears old sightings.
- Tests exercise real `AudioStreamSynchronized` gains, fade reversal and pause,
  with a fixed pair of stems. Rebinding disconnects the previous combat world.
  Shutdown clears streams; preparing again reuses the same player Nodes.
- Group feedback chooses one living, deployed, player-owned representative.
  Enemy/mutinous units cannot acknowledge the old player's command. Stage 1
  villagers support selection/move feedback without treating gathering as Attack.
- All six faction/action groups have three variants. Selection avoids the last
  two takes and does not perturb the simulation's global RNG.
- A prepared clip is played by an actual pooled `AudioStreamPlayer`. Duplicate
  sequence IDs and 200 spam requests do not create a chorus or a delayed queue.
  Cooldown permits a later faction-specific response.
- Missing VO produces subtitle-only feedback; mute retains captions; pause
  rejects new gameplay acknowledgements. Invalid music pairs, nonlooping stems
  and duplicate line IDs fail bank validation.
- The asset scope rejects missing paths, runs an engine threaded request, gets
  the resource only after LOADED, and releases its retained reference. It does
  not pretend an in-flight request has been cancelled.

## Integrated scene and sample budget

The real Stage 4 lab runs six duels with twelve combatants, resolves weapon
contacts and reaches a full Combat mix. Run preview uses the same animator.
Godot Control/font geometry fits **1280×720, 1440×900 and 1920×1080**. Simulated
keyboard input opens F9 from the sandbox's focused seed field, returns using F6,
and restores normal window-close behavior.

The CLI demo reports 18 impacts without premature damage, 12 visible fighters,
Combat mix 1.0, 200 prewarmed views, two VO players and a return to Eco. It yields
real engine frames around playback and drains audio before normal shutdown.

One local run on **AMD EPYC 9V74 80-Core Processor**:

| Measurement | Observation |
|---|---|
| Shared-profile view budget | 200 views, 400 Sprite2D Nodes; no pool misses |
| Central animation update, 300 samples | p50 0.655 ms; p95 1.037 ms; max 2.900 ms |
| Rendering | Excluded; headless |

These are observations, not timing gates, desktop FPS claims or GPU benchmarks.
They exclude final atlas complexity, GPU upload, actual audio-device output and
production asset decoding. Pooling Nodes does not eliminate all engine-native
playback allocations.

## Manual acceptance still required

Headless checks verify state, geometry, resource lifecycle and real player API
behavior; they do not judge perceived animation smoothness, sound, phase, clicks,
mix balance, historical pronunciation or GPU stutter. Before shipping, run the
F9 lab on target devices with final assets, inspect contact in slow motion and
listen through the full Eco/Combat/VO/pause/mute cycle.

The shipped SVGs and synthesized tones are diagnostic placeholders. The 18
German captions are modernized casting drafts, not recorded or certified
Frühneuhochdeutsch. This stage supplies an integrated presentation lab and
reusable adapters; it does not replace the entire economy sandbox's art or add
military navigation, fog of war, a playable campaign or production recordings.
