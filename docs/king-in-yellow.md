# The Yellow Path — the JRPG path rewritten in the world of the King in Yellow

Author-facing narrative plan. This uproots the JRPG path's bog-standard
demon-lord worldbuilding and resets it inside Carcosa, the lost city of
Robert W. Chambers' *The King in Yellow* (`king-in-yellow.txt`, public domain).
The familiar JRPG frame (a hero, a town, a companion, a road, a demon lord to
end) is kept as the surface; the flesh is Carcosa.

## The seam (why this fits the existing design)

`AGENTS.md` and `docs/narrative.md` already hold the hidden idea that **the
JRPG demon lord may turn out to be the player from another path**, never
foreshadowed early. We make that canon, and we make it the King in Yellow.

The King in Yellow is the **maddened ship-captain from the `mutiny/` bad
branch** — the branch where the crew, lovingly and certain, removes a captain
they have concluded is no longer the one they serve. His time-loop was never a
game mechanic; it was accumulated death-memory, dying and returning and
carrying the pain forward (ship-path canon). When the crew finally put him off
the ship, the loop broke *wrong*: it stopped returning him to the alarm and the
crossing, and began returning him to a shore under twin suns, beside a still
lake, under black stars. He stopped being the captain. He became the tattered
King who **wears no mask** — because after enough deaths there is no longer a
face under one to hide. His old gift (every visible decision correct, the crew
saved from every crisis) curdled into the **Yellow Sign**: a mark he sends to
those whose story he means to conclude.

Recontextualizations the deep route can pay off (never early):

- the **Lake of Hali** is the crossing he kept failing — the void/water.
- the **twin suns** are the ship's binary primary, seen from the far shore.
- the **pallid courtiers** of Carcosa are the crew he could not save, kept,
  looping their last gestures, masked.
- the hero sent to end the demon lord is another loop/aspect of the same
  person; "slaying the King" is the loop trying, again, to end itself.

Early JRPG play stays a sincere (if uncanny) fantasy quest. The captain-reveal
is deep, gradual, diegetic — no title card.

## Visual marker — the Yellow Crown (#ffff00)

The game is pure black and white; `AGENTS.md` forbids palettes without an
explicit reason. The King in Yellow IS the explicit reason. This path carries
the single sanctioned color: a **yellow crown, `#ffff00`** — the only color in
the game, therefore unmistakable.

- `+yellow-sign-color+` = (255 255 0).
- A `yellow-path-node-p` predicate tags this path's node id prefixes.
- The story-tree overlay draws a small yellow crown on yellow-path nodes
  instead of the white bead.
- The crown also appears in-scene at the King's beats (the diadem, the Sign).
  Used sparingly: a single yellow stroke in a B&W frame should feel like a
  wound, not decoration.

## Carcosa — the world (from the source text)

- **Carcosa**: the lost lakeside city. "Along the shore the cloud waves break,
  / the twin suns sink behind the lake, / the shadows lengthen / In Carcosa."
  Towers, the King's palace, streets where Camilla's scream still hangs.
- **The Lake of Hali**: dark water, wet winds, the cloudy depths of Demhe.
  Crossing it is the deep ordeal.
- **The sky**: black stars rise, strange moons circle, the Hyades and Aldebaran.
- **The Yellow Sign**: a sigil. To receive it is to be written into the King's
  story. Item / key / curse.
- **The Pallid Mask**: the masque where all have laid aside disguise but the
  Stranger — who answers "I wear no mask." "No mask? No mask!"
- **The tatters of the King**: his scolloped yellow mantle.
- **The Play, *The King in Yellow***: a script whose innocent first act lures
  and whose second act maddens whoever reads it. Both an item and a hazard.
- **Cassilda, Camilla**: figures of the court — interrogable NPCs.
- **Hastur, Yhtill, the Dynasty**: names of the King's domain and line.

Naming rule (repo): humans keep real names; Carcosa's canon figures
(Cassilda, Camilla, the Stranger, the King) keep their canon names; places are
exempt. The townsfolk keep their existing real names.

## The reframed spine (existing jrpg/ ids kept; prose reset)

Node ids stay stable to preserve wiring and minigame hooks; only the world
changes. The matchbook entry still lands at `jrpg/inn`.

- `jrpg/inn` — the room is an inn at the **Hali strand**, the lakeward edge of
  Carcosa. Twin-sun dusk through the shutter; lake-mist; a playbill on the wall.
- `jrpg/name` — the name the player gives is the name on a summons that bears a
  faint yellow sign in the corner.
- the town (**Oakbarrow → the Strand under Carcosa**) — its people keep their
  names (Mira, Toma, Oren, Pell). Errands become strand errands. The "quest"
  is to go up to the towers and end the King whose Sign has been reaching the
  town, stopping the songs, keeping the dead from leaving.
- companions (Lena / Niko / Bram) — fellow travelers up the shore.
- `jrpg/overworld` — the walk minigame becomes the **Hali shore road** toward
  the towers; reused for the shrine detour (a roadside Yellow-Sign shrine) and
  the tower approach.
- combat — Carcosan creatures (see below).
- the tower / Pell — the **palace approach**; Pell the steward → a herald of
  the court.
- the demon lord → **the King in Yellow**. `jrpg/demon-choice` /
  `jrpg/sword-choice` → how the hero approaches the King: duel, terms, or ask
  about the tatters / the Play / the masque. The "hill of broken swords"
  becomes the **drift of pallid masks** below the throne (every petitioner who
  unmasked and found nothing to threaten).
- return road / ambush / inn-return → the way back down the shore; the deep
  route may instead keep the player in Carcosa.

## Creatures and enemies (KiY + FF turn-combat)

New ASCII sprites + `:jrpg-combat` configs. Repurpose the existing engine.

- **tatterdemalion** — an animate shred of the King's yellow mantle. Fast, low
  HP. Drops a *scrap of the Play*.
- **pallid courtier** — a masked dead courtier. Medium. On a turn it may
  *unmask*: if it does, it stops attacking (there is nothing under the mask)
  and can be dismissed; if you strike the mask, it screams (the Camilla beat).
- **the Hali-drowned** — a lake-drowned thing, slow, tanky, wet; high defense.
- **byakhee-servant** (replaces the bat) — a winged thing of the Hyades.
- **the Phantom of Truth** — a play-character; a mini-boss with a *no-mask*
  gimmick.
- **the King in Yellow** — the final confrontation. Mechanically uncanny: his
  HP does not deplete by ordinary attack (every move you make, he has already
  answered). The "fight" resolves through choice/interrogation/submission, not
  damage. This is where the captain-reveal lands.

## Items (the world informs the haul)

- **scrap of the Play (Act I)** — safe; lore + small buff.
- **leaf of the Second Act** — risky consumable: large effect, costs composure
  (a sanity stat); reading too much maddens.
- **Yellow Sign token** — key/curse; marks the bearer, opens the palace, draws
  the King's attention.
- **Hali-water flask** — the reskinned potion: heals, but the lake remembers.
- **pallid mask shard** — defense charm.
- **Cassilda's locket** — a companion charm tied to the court.
- Stats reskin: keep hp/attack/defense; **MP → "will"**; add **composure**
  (sanity) read by the Play items and the masque.

## Living world — interrogation

`dialog-interrogation` (the dogfooded question-menu) for:

- the **innkeeper** — the lake, the Sign reaching the town, the songs that stop.
- **Cassilda** — Camilla, the masque, the King's face, "Not upon us, oh King."
- **Camilla** — the unmasking, what she saw.
- **the Stranger** — who wears no mask; the deepest seam (he remembers a ship,
  a crossing, a man who could not stop). The reveal lives here and at the throne.
- a **courtier** / the **herald** — court procedure, the drift of masks.

## Minigames and branching

- reuse: overworld (Hali road), turn-combat (KiY creatures), interrogation,
  and the maze engine for **crossing the Lake of Hali** toward the palace.
- new beat: **the masque** — hold composure as the court unmasks around you
  (reuse the hiding/hold-still tension engine, reskinned), gating the throne.
- the throne confrontation branches: **take the crown** (become the next King —
  the loop continues, the cruelest ending), **refuse / unmask him** (find the
  captain's ruined face, or no face), or **terms** (the songs are let go; the
  dead leave Carcosa). Choices stored for later paths and the crown marker.

## The ship stitch (mutiny → Carcosa)

In `game/campaign/mutiny.lisp`, after the crew removes the captain, add a
gentle, non-foreshadowing tail: the loop that always returned him to the alarm
returns him instead to a shore under two suns, a still lake, a crown someone
set on him as a last kindness. No title card; one or two diegetic beats. The
JRPG deep route pays this off — the King is that captain.

## Build order — IMPLEMENTED 2026-06-22

1. plan (this doc) + narrative.md update. DONE.
2. yellow crown marker: `yellow-sign-color`, `*yellow-crown-prefixes*`,
   `yellow-crown-node-p`, `tree-draw-crown` (source/util.lisp, tree-view.lisp). DONE.
3. spine reframe (game/campaign/jrpg.lisp) into Carcosa: Demhe on the Lake of
   Hali, twin suns, the King in the high tower, the Yellow Sign on the summons,
   the songs that stop. DONE.
4. creatures (game/jrpg/combat.lisp: tatter, drowned, byakhee, courtier,
   phantom sprites) + composure stat and recoverable items (game/jrpg/state.lisp).
   DONE.
5. the throne (game/campaign/carcosa.lisp): unmask -> the captain reveal -> the
   crown-offer -> branch (take the crown / refuse / free the songs), composure
   gated; mutiny/shore origin on the ship path. DONE.
6. living court: Cassilda and Camilla (eavesdropped, then interrogated) before
   the door; the Stranger interrogation in the deep branch. DONE.
7. branches reframed (ledger/bellfall/festival) into Carcosa. DONE.
8. the Lake of Hali crossing (maze reuse) + a pallid courtier on the causeway.
   DONE.

Entry: matchbook -> jrpg/inn. Deep throne: jrpg/sword-choice -> carcosa/unmask.
The crown marker tags `jrpg/ ledger/ bellfall/ festival/ carcosa/`. The ship
seed `mutiny/shore` stays unmarked so the ship route does not foreshadow it.
