# Tile Credits

## dawnlike-mono.png

- Source: https://opengameart.org/content/dawnlike-16x16-universal-rogue-like-tileset-v181
- Authors: DragonDePlatino (tiles) and DawnBringer (the palette the set is built on)
- License: CC-BY-SA 3.0 — attribution required, derivatives stay share-alike
- Notes: A small monochrome atlas composited from selected DawnLike v1.81 sheets
  and converted to white-on-transparent (grayscale + contrast) to match the
  black-and-white CRT look. Tiles used so far: a brick face (`Objects/Floor`), a
  paved tile (`Objects/Floor`), an interior door and a portcullis gate
  (`Objects/Door0`), a candle lamp (`Objects/Decor0`), and the traveller
  (`Characters/Player0`). The atlas is the game's in-city / overworld tile
  renderer source. More sheets (walls for autotiling, terrain, creatures,
  items) will be folded in as the integration grows.
- TODO (license obligation): DawnLike's license asks that a hidden Platino
  sprite from `Characters/Reptile0` appear somewhere obscure in the game. Honour
  this when creatures are wired in.

## kenney-1bit-mono.png

- Source: https://opengameart.org/content/1-bit-pack (file `1bitpack_kenney_1.1.zip`)
- Author: Kenney (kenney.nl)
- License: CC0 (Creative Commons Zero / Public Domain)
- Original file: `Tilesheet/monochrome_transparent_packed.png`
- Notes: The 1-bit monochrome, transparent, packed tilesheet — a 48x22 grid of
  16x16 tiles, white ink on a transparent ground. Now backs the in-menu Scene
  Builder tile editor (`atlas-reference.png` is its coordinate guide); the game
  world itself renders from `dawnlike-mono.png` above.
