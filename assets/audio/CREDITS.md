# Audio Credits

## typewriter1.wav - typewriter8.wav

- Source: https://opengameart.org/content/typewriter-sounds
- Author: Cassie-OrbitGames
- License: CC0
- Notes: Loaded as a rotating per-character typewriter click bank in the opening prototype.

## backup/type-click.wav

- Source: https://opengameart.org/content/typewriter-sounds
- Original file: `typewriter1.wav`
- Author: Cassie-OrbitGames
- License: CC0
- Notes: Archived first downloaded copy; the game uses the numbered rotating bank.

## choice-switch.wav

- Source: https://opengameart.org/content/click
- Original file: `click.wav`
- Author: qubodup
- License: CC0
- Notes: Used when switching between visible choice options.

## start-confirm.wav

- Source: Generated locally as a procedural low-frequency confirmation sting.
- Author: Procedural tone generated for Immortal Coil.
- License: Procedural tone generated for this project.
- Notes: Used as the longer, heavier confirmation sound when committing to menu actions such as new game and continue.

## title-ambient-drone.mp3

- Source: Generated with OpenRouter using `google/lyria-3-pro-preview`.
- Provider: Google AI Studio via OpenRouter.
- Date generated: 2026-06-05.
- Prompt: Evolving dark ambient background music for a black-and-white text narrative, with long sustained tones, slow harmonic drift, low organ pad, soft analog hum, distant airy texture, subtle unease, and no drums/percussion/bells/beat.
- Notes: Selected as the title/menu background ambience candidate. Review the applicable OpenRouter and Google terms before public release.

## backup/generated/

- Source: Generated title-music candidates from earlier local experiments.
- Notes: Archived locally; ignored by git. The game uses `title-ambient-drone.mp3`.

## ship-lyria-drone.mp3, forest-lyria-drone.mp3, jrpg-lyria-drone.mp3, alice-lyria-drone.mp3, rogue-lyria-drone.mp3

- Source: Generated with OpenRouter using `google/lyria-3-pro-preview`.
- Provider: Google AI Studio via OpenRouter.
- Date generated: 2026-06-08.
- Prompt notes: Track-specific prompts asked for long, drawn-out, beatless dark ambience with no drums, percussion, snare, bells, vocals, lyrics, or melody hook. The cues target the ship, forest, fantasy-adventure, dream, and dungeon branches.
- Notes: Story-branch background ambience candidates. Review the applicable OpenRouter and Google terms before public release.

## jrpg/*.wav

- Source: Procedurally generated locally for Immortal Coil.
- Date generated: 2026-06-09.
- Files: `bell.wav`, `coin.wav`, `gate-chain.wav`, `hit.wav`, `ledger.wav`, `magic.wav`, `retreat.wav`, `slime.wav`, `sword.wav`, `tonic.wav`.
- Notes: Short mono PCM JRPG branch sound effects for dialogue nodes and the turn-combat minigame.

## maze/crt-static.mp3

- Source: https://opengameart.org/content/static
- Original file: `ScatterNoise1.mp3`
- Author: xhunterko
- License: CC0
- Notes: Used as the Doom-like dream-maze exit static cue.

## maze/footstep-01.ogg - maze/footstep-06.ogg

- Source: https://opengameart.org/content/footsteps-0
- Original files: `01-footstep.ogg` through `06-footstep.ogg`
- Author: GboxMikeFozzy
- License: CC0
- Notes: Used as alternating movement footsteps in the Doom-like dream-maze minigame.

## rogue/*.wav

- Source: Procedurally generated locally for Immortal Coil.
- Date generated: 2026-06-17.
- Generator: `scripts/generate-rogue-audio.lisp`.
- Files: `chiptune-crypt.wav`, `menu.wav`, `class.wav`, `step.wav`, `bump.wav`, `pickup.wav`, `hit.wav`, `kill.wav`, `stairs.wav`.
- Notes: 8-bit/chiptune-style Rogue branch loop and short crawl sound effects.
