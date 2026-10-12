# Stage 4 diagnostic assets

`bundschuh_unit.svg` and `league_unit.svg` are original code-authored geometric
sprite atlases created for this project. Each is 512×256: four rows (Idle, Run,
Attack, Die), eight 64×64 frames, ground pivot (32,54). They are one-direction
animation test art, not final historical costumes or the GDD's isometric render.

`Stage4DemoAssets` builds AtlasTexture/SpriteFrames references once at scene load.
It also synthesizes two 8-second music test loops and 18 short diagnostic tones
into AudioStreamWAV. There are no external music samples or voice recordings.
The tones are NOT speech, lute, brass, hurdy-gurdy or chorale recordings.

Casting text lives in `data/presentation/voice_casting_bank.tres`. It is newly
written/modernized draft text based on the game's GDD brief; language_approved is
false. Replace the empty stream slots with actor recordings and create a full
production audio bank as described in `docs/STAGE_4_ASSETS_AUDIO.md`.

Keep SVG `.import` sidecars in Git to retain import settings; `.godot` cached
textures stay untracked. No raster image-generation service was used for these
code-native placeholders.
