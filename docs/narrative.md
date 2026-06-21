# Narrative Notes

These notes are author-facing. They describe what the current built-in story
paths are about, not what the player should be told.

## Core Method

Immortal Coil uses later context to change what earlier scenes meant. The room,
bed, night stand, doors, objects, and voices should feel like they were always
what a later path reveals. Avoid visible transformations, reality-warping prose,
or interface text that explains the trick.

The player should usually understand less than the author. Branches should
create new context, not announce new genres.

Keep the prose plain and concrete. The situations can be mysterious by
themselves; avoid stock paradoxical mystery language where rooms, shadows,
silence, or objects act ominous just to sound strange.

The deeper a route goes, the more specific it should become. Early branch
entries can withhold context, but once the player is inside a path, scenes
should be grounded in named characters, concrete places, actions, costs, and
consequences.

Long dialogue blocks look bad in the typewriter UI. Prefer shorter dialogue
nodes chained together when a real scene beat needs room, but do not add
extra nodes just to pad an otherwise direct transition.

Becoming concrete does not fix a single canon. A later divergence can still
recontextualize even grounded material, and the reveal is branch-relative: one route
may establish that a path was a simulation all along, while another holds it was the
real world all along. Each is that route's own canon, not one truth shared across
paths — the same future-shapes-past method applied to a whole path's reality rather
than a single object. It should still feel like it was always so, not like the world
changed.

Every major path should eventually hold 20 to 30 minutes of content at the
typewriter pace, minigames included. `scripts/content-report.lisp` measures
this per path family. After the current expansion round the seven major
families all measure above the 20-minute floor, with Rogue and JRPG now the
largest current surfaces. Growth toward 30 continues. Each path should also
keep growing its own minigames, not only prose. The war path is
Suzerain-inspired: conspiracy and intrigue through cabinet politics, with the
player's unremembered signature at the center.

The "future shapes the past" effect only works when transitions are gentle
enough that a player on a single playthrough would not recognize them as
transitions. A branch entry should feel like the next ordinary detail in the
same situation; only later, or on another route, should the player understand
that the detail carried them into a different context.

Choices should describe something the current player character can actually do,
notice, say, or decide. Do not ask the player to choose facts outside that
character's control, such as which unrelated person happens to meet them at a
gate. If a choice affects a fact, the causal path should be in-world: the player
goes to someone, asks for help, takes a route, or uses an established power.
Reality-warping choices are only acceptable when that power belongs explicitly
to the branch and is not just an author shortcut.

## Current Branch Shape

The current branch events are still prototype hooks, but the base-room split
should avoid looking like a genre picker or a symbolic object menu:

- `base/exit-bed`: starts the ordinary room interaction.
- `base/thirst`, `base/match`, and `base/unlock-door`: route through actions
  discovered while exploring the room.
- `base/sleep`: enters the dream maze directly. Do not pad the bed-refusal path.
- `dream/maze`: routes by minigame outcome map (:left, :upper, :right).

This is acceptable for proving the graph, minigame, music, particle, and mod
surfaces. Future versions should keep making these events subtler and easier
for mods to hook into. Prefer small diegetic cues, hidden flags, remembered
details, and ordinary node extension points over loud "choose your genre"
moments.

## Base Room

The base room is intentionally under-described. It begins as a strange bedroom,
but each path should reveal that the player lacked the right context.

Current anchors:

- The bed can later read as a crash couch, prison bed, inn bed, dream bed, or
  dungeon memory without saying it changed.
- The night stand and door area are branch surfaces for ordinary actions whose
  meanings become path-local.
- Door counting and sound selection are secondary hook points for future paths.
- The room should remain sparse enough that mods can reinterpret it.

## War Leader

The refuse-all route through door counting and hall sounds should lead to a
nation-leader-in-war story.

Author truth:

- The player is a head of state or equivalent national leader during a war.
- The opening room can later read as a bunker, command residence, cabinet room,
  or emergency office.
- The path should focus on abstract command, distance, propaganda, incomplete
  information, and decisions whose costs are paid by unseen people.
- The leader should not feel like a battlefield hero. Their horror is deciding
  from behind doors, reports, maps, and voices.
- Do not announce the role abruptly. Let the room acquire political and wartime
  context through staff, briefings, blackout windows, radios, maps, and titles.

Planned surface:

- Door counting can become fronts, ministries, shelters, or briefings waiting
  behind numbered rooms.
- Hall sounds can become radio static, boots, sirens, water pipes in a bunker,
  glass in blackout windows, keys to sealed archives, or distant artillery.
- The first clear address should be restrained, such as a title spoken by an
  aide, not a blunt declaration of identity.

Current surface:

- `game/campaign/war.lisp` grafts onto the static, bells, and glass hall-sound
  leaves; the other leaves stay open as hook points.
- `war/aide` is the first address: Brandt says "chancellor" in passing.
- `war/doors` reuses the counted `door-count` as the cabinet room number.
- `war/briefing` and `war/decision` are the first abstract command beats; the
  bridge/rail-yard/delay choice is stored in `war-first-order`, and each cost
  is paid by people the player never sees.
- `war/radio` is the tuning minigame: the quiet band can be found, but it is
  reading numbers too. Either outcome turns the radio down, not off.
- The path is Suzerain-inspired: conspiracy and intrigue carried by cabinet
  conversations and stored choices rather than action. Day two opens with the
  rerouting order signed in the player's own hand, dated the night the bells
  began, unremembered — the path's memory-gap motif made political.
- The cabinet: Vey (interior, trades silence for emergency powers), Sorel
  (supply, follows the manifests), Olen (army, heard the order dictated
  through a door). `war-confidant`, `war-decree`, and `war-km-nine` store who
  the player trusted, what the decree became, and what they did about
  kilometer nine. The sealed car at kilometer nine stays unopened for now.
- Planned: a manifest-audit minigame (flag the line that does not match), a
  third-day arc where the decree's consequences arrive, and the numbers the
  player wrote down beginning to mean something.

## Ship Captain

The glass of water path leads to the hard-sci-fi ship captain story.

Author truth:

- The player is a stressed captain on a large hard-sci-fi ship.
- The captain is close to breaking and trapped in repeated lethal failures.
- The crew sees an impeccable captain who makes the correct call every time.
- The player experiences the failed attempts, pain, death, and private burden.
- Crew admiration should become painful because it only sees the final polished
  result.
- Hallucinations are memory intrusions from previous failures, not ghosts,
  prophecies, or reality changing in front of the player.
- The register sits between dark Star Trek and outright space horror, and the
  horror is mostly psychological: the crew is unaware of the horrors around
  them, while the captain knows both the horrors and the gore and carnage they
  would cause — known naturally, because in failed attempts they happened.
- Plan for impossible choices where no option saves every crew member. The
  result belongs in the shared store so later scenes remember who was lost.
- What civilization the ship belongs to is branch-relative canon: one route
  may establish a dystopic vestige of humanity, another a thriving empire,
  another a republic or alliance of planets. Each is that route's own truth.
- The path also time-switches to an unknown future where the captain is alone
  on the ship and does not remember why — everyone died, or everyone was
  dropped off safely somewhere, or something in between. Keep that ambiguity.
- Scene shifts use the `:scene` lower-third node (`dialog-scene`), which marks
  a cut with a small label instead of an announcing title card.

Current surface:

- `ship/wake` reveals restraint straps and indicator lights in reflection.
- `ship/name` collects the name stenciled on the frame at the foot of the bed.
- `ship/flight` is the crossing minigame; the fiction calls it the crossing,
  never the wireframe.
- `ship/later` opens the lonely-future interlude with a lower-third scene
  shift: dark bridge, one cup on the rack, the manual open to the player's
  procedure.
- Failure loops back into the same alarm without explaining the loop, and
  silently counts in the `ship-failures` store key. The crash-return sequence
  (`ship/crash-return`, `ship/crash-return-hands`,
  `ship/crash-return-alarm`) stays under the `:warp` particle field, so the
  private loop has a white-line effect screen without prose explaining it.
- `ship/bridge` and `ship/praise` introduce Imari (logs) and Voss (lanes);
  the crew's praise reads as a compliment and is meant to sting later.
- `ship/galley-remembered` is the first memory intrusion: Voss's burned
  sleeve mid-pour, shown only when at least one crossing failed.
- `ship/voss-question` records how the captain explains the crossing, and
  `ship/bunk` returns to the room through ordinary sleep.

## Forest Escape

The brass key path leads to the dark forest survival story.

Author truth:

- The player has been kidnapped and has escaped without understanding that yet.
- The house is confinement, not a house that transforms into confinement.
- The pursuer is the kidnapper, possibly supernatural.
- The forest may hide the player or return them; the uncertainty matters.

Current surface:

- `forest/threshold` opens the front door with the warm brass key.
- `forest/porch` places the house alone in a black pine forest.
- `forest/tag` shows the wrist tag and begins the confinement reveal.
- `forest/pursuer` names the player like misplaced property.
- `forest/hold-still` is the hiding minigame: breath rises on its own,
  letting it out makes noise. Being heard only sets `forest-seen` and slows
  the lantern; both outcomes continue.
- The three refuges deepen the reveal and store `forest-refuge`:
  `forest/culvert` reaches a road where cars pass and the lantern turns back,
  `forest/gate` finds the property sign facing inward, and
  `forest/cellar-dark` shows a kept cot and four more wrist tags on a nail.

Future writing should soften the branch trigger. The player should not feel that
"brass key means forest route" as clearly as they do in this draft.

## JRPG Adventure

The matchbook path leads to a straight-faced fantasy adventure.

REWRITE IN PROGRESS (2026-06-22): the path's worldbuilding is being reset into
Carcosa, the world of *The King in Yellow*. The demon lord becomes the King in
Yellow — the maddened ship-captain from the `mutiny/` bad branch, whose loop
broke into Carcosa. The familiar JRPG frame is kept as the surface. Full design
in `docs/king-in-yellow.md`. The path carries the one sanctioned color in the
B&W game: a yellow (`#ffff00`) crown marker. The "Author truth" below is the
original frame, preserved because the early route still reads that way.

Author truth:

- It should initially read as a bog-standard JRPG demon-lord quest.
- It can be corny and stereotypical at first. The familiar frame is useful
  because the later game can pull that certainty away.
- The genre comfort is useful because later details can reframe the same room,
  bed, keyhole, inventory, and role expectations.
- It should not wink too hard at the player. The joke can exist, but the path
  should remain sincere enough to support later unease.
- Hidden long-term idea: the demon lord may turn out to be the player from
  another path. Do not foreshadow this in the early JRPG route.
- The demon-lord route is the built-in spine, not the only valid JRPG branch.
  Keep enough stored state and hook points that later authors can leave the
  expected route in substantial ways.
- JRPG stats, route choices, companion choice, combat results, and inventory
  should live in the shared dialog store so later branches and mods can hook
  into them.

Current surface:

- `jrpg/inn` reframes the room as an inn room.
- `jrpg/name` collects the name written on the quest notice.
- Oakbarrow currently introduces Mira, Toma, Oren, and the companion routes
  Lena, Nio, and Bram through ordinary actions before the gate.
- `jrpg/village-errand` records whether the player dealt with Mira, Toma, or
  Oren before leaving.
- `jrpg/overworld` is a small overworld-walk minigame leading to companion
  road dialogue; `jrpg/shrine-overworld` reuses it for a roadside shrine
  detour, `jrpg/hill-overworld` for the final tower approach, and
  `jrpg/home-overworld` for the return road.
- `jrpg/slime-combat` is an early-Final-Fantasy-style turn combat minigame.
  `jrpg/shrine-slime-combat` and `jrpg/home-ambush` reuse it with different
  road contexts.
- `jrpg/tower-choice` records the tower approach.
- Pell, the tower steward, introduces the tower approach choices.
- `jrpg/pell-questions` is the first dogfooded interrogation helper: a
  question menu that asks Pell about the front door, side stair, and morning
  bell before approach selection.
- `jrpg/vane-questions` reuses the interrogation helper on first meeting Vane,
  keeping the demon-lord material concrete and local before the player decides
  what to do.
- `jrpg/demon-choice` records how the player approaches Vane.
- `jrpg/sword-choice` settles the visit (duel, terms, or asking about the
  broken swords) into `jrpg-vane-answer`. Vane's hill of broken swords stays
  ordinary JRPG lore; it must not foreshadow the hidden demon-lord idea.
- `jrpg/home-overworld` reuses the overworld minigame for the return road, then
  `jrpg/home-ambush` reuses turn combat before the bridge.
- `jrpg/inn-return`, `jrpg/ledger-line`, and `jrpg/fair-choice` close the
  Oakbarrow chapter into either the fair branch or room-four return.

## Dream Maze

Sleeping enters the dream maze. The maze is a branch surface for dream genres.

Author truth:

- Dream exits should be portals into other narrative frames.
- The exits should eventually be less mechanical and more tied to remembered
  detail, orientation, or repeated symbols.
- The maze should not explain that it is choosing a genre.

Current surface:

- `dream/maze` runs the Doom-like maze minigame.
- A left exit leads to Alice.
- An upper exit leads to Rogue.
- A right exit leads through `dream/right-exit` into containment.
- Lost results lead through `dream/maze-lost` into containment.

## Alice Branch

The left dream exit leads to an Alice-like impossible courtesy path.

Author truth:

- The branch should feel like social rules, etiquette, and accusation in an
  impossible room.
- It can be surreal, but should still recontextualize earlier room details
  rather than transform them.

Current surface:

- `alice/fall` descends from the left exit.
- `alice/table` introduces the table and inverted cups.
- `alice/choice` selects an impossible courtesy.
- `alice/court` asks for name, crime, and room size.
- `alice/doors` re-records `door-count` through the foreman's question, and
  `alice/verdict` rules the room was the player's all along — that branch's
  own canon, not a shared truth.
- `alice/thread-out` follows the white thread back under the door.

## Rogue Branch

The upper dream exit flashes a large `@`, then leads to a Rogue-inspired
dungeon branch.

Author truth:

- The branch should evoke terse dungeon logic: inventory, doors, hidden danger,
  identification, stairs, and grid-like movement.
- It should be austere and readable, not a parody.
- Earlier room details can return as dungeon objects, but should feel like they
  were always part of this frame.

Current surface:

- `rogue/ascii-reveal` is the slow `@` flash at the branch reveal.
- `rogue/entrance` opens onto hard white dungeon lines.
- `rogue/inventory` gives a ration, a ring, and no memory of the stairs.
- `rogue/door` chooses a door by list.
- `rogue/loot` chooses scroll, ring, or ration; wearing the ring sets
  `rogue-ring-worn`.
- `rogue/stairs` descends past the carved name; turning back finds the way
  locked from the other side.
- `rogue/floor-two` and `rogue/cell` end in a room furnished like the base
  bedroom, drawn in dungeon lines, with no lock plate on the inside.
- `rogue/pillow` hides a half-used matchbook; `rogue/sleep` fades out with
  the torch.
- `rogue/delve` is the long stair: the reusable ASCII crawl with class choice,
  pack menu, HP, rations, map scrolls, monsters, traps, items, and
  store-persisted progress. Its bottom room is the bedroom with a fresh
  wrist tag; marks gathered tie back to the chalk tally.
- `rogue/stair-maze` reuses the Doom-like maze engine to find the stairs after
  the cell row, and `lightsout/hold-still` reuses the hiding minigame in the
  lights-out branch.
- `below/clerk-questions` reuses the interrogation helper for the clerk: ask
  about the auditors, the ajar door, and what the ledger wants before the branch
  returns to the ribbon book.
- `rogue/housekeeping`, `rogue/exit-choice`, and `rogue/candle-choice` carry
  the branch back out through inventory/accounting choices. Keep the return
  short; do not pad it after the shrine choice.

## Containment Researcher

The dream right-exit and maze-lost route should lead to a containment-research
story in the spirit of anomalous-institution horror.

Author truth:

- The player is a researcher, observer, or facility staff member connected to
  containment protocols.
- The dream maze can later read as a facility corridor, test route,
  observation protocol, or decontamination memory.
- The branch should use procedures, logs, classifications, access levels,
  observation rooms, and institutional language to make earlier weirdness feel
  catalogued rather than transformed.
- Avoid importing a full external canon in prose. The story can evoke that mode
  while remaining Immortal Coil's own institution.
- Transitions must be gradual. The player should first notice forms, symbols,
  protocols, and repeated room details before understanding the role.

Current surface:

- `dream/right-exit` shows a straightened corridor with a white floor line,
  then enters the facility path.
- `dream/maze-lost` enters the same facility path when the player loses the
  route.
- `facility/desk` holds a sign-in sheet already signed three times in the
  player's handwriting; `facility/designation` collects a designation, not a
  name, into `facility-designation`.
- `facility/card` introduces the RECURRENCE card; `facility/window` passes a
  dark room furnished like the base bedroom without comment.
- `facility/end` leaves the player at a warm brass handle, echoing the forest
  key.

Visual note:

- A black-and-white demake-style flash of an SCP-Foundation-like circular logo
  could be a strong beat if used sparingly. Treat it as a brief visual memory or
  institutional mark, not as an explanatory title card.

## Dark Branches

Every major path is growing two darker, more twisted branches, each with
its own id prefix (measurable in `scripts/content-report.lisp`). Length
must be earned by concrete scenes, not padding. Entries obey the
gentle-branching rules: in-scene, concise, one-of-N choices inside the
parent narrative, with recontextualization as the engine of the horror.
Status notes live with each parent path's section and org file.

- ship: `husk/` — boarding a dead sister ship whose logs are in the
  captain's hand and whose manifest is the crew's. DONE (20.5 min).
- ship: `mutiny/` — the crew's kind, loving removal of a captain they
  have concluded is no longer the one they serve. DONE (20.7 min).
- war: `tribunal/` — years later, the trial: the signature returns as
  evidence, the transcripts read into the record. DONE (21.4 min).
- war: `district/` — the third district visited at night, against all
  advice: bells, lists, coats, the loaded train. DONE (20.7 min).
- forest: `house/` — going back inside through the open door: rooms that
  match the bedroom, a recently used cot, the keeper. DONE (21.4 min).
- forest: `winter/` — letting the bus go and staying: the store closes,
  food appears on stumps, the hill keeps its own. DONE (21.9 min).
- jrpg: `ledger/` — Mira's other ledger read after breakfast: the names,
  the years, the economy that farms heroes. DONE (20.0 min).
- jrpg: `bellfall/` — the midnight bell and the year the notices stop
  working: a funeral pastoral, terms breaking. DONE (20.1 min).
- alice: `kept/` — the court keeps the defendant instead: the cell that
  is the room, visiting hours, courteous appeals. DONE (20.8 min).
- alice: `seam/` — following the white thread down under the table to
  the compost of doors, where unkept rooms go. DONE (20.1 min).
- rogue: `below/` — the bookkeeping floors beneath the tally, and the
  clerk met in person. Two-hunter delve and clerk interrogation. DONE
  (20.3 min before the interrogation expansion).
- rogue: `lightsout/` — the torch fails and the delve goes sight-starved.
  DONE.
- facility: `nightshift/` — reassigned to the room side of the glass:
  the log from inside, the predecessor's notes. DONE (20.2 min).
- facility: `release/` — decommissioning: files burned on schedule,
  rooms released, the player signs for the bed. DONE (20.7 min).

## Bright Branches

Counterweights to the dark branches: genuinely warm, up-beat branches
with their own id prefixes. Same gentle-entry rules, no minute floor,
but they should feel substantial. One of them carries the seeded-random
mechanic: a branch whose beat order and outcomes derive from a seed
rolled once into the dialog store (stable across save/load, different
across playthroughs), via target delegates reading the seed.

- jrpg: `festival/` — the midsummer fair at the inn crossing: game
  stalls, prizes, lantern launch. SEEDED via `festival-seed` +
  `festival-roll` avalanche hash. DONE (17.5 min).
- ship: `liberty/` — real shore leave at a good port: the crew at
  liberty, the captain talked into joining, nothing goes wrong.
- war: `armistice/` — the morning the bell does not ring, told as joy:
  corridors, windows opening, Brandt laughing. DONE (13.6 min).
- rogue: `haul/` — the genuinely good delve: a clean haul, the tally
  generous, and an evening spending it well in town.

## Hook Direction

Future hook points should be ordinary nodes and facts that mods can append to:

- objects noticed in the room
- names the room uses
- inventory details
- remembered sounds
- counted or miscounted exits
- minigame results
- particle or music shifts
- saved hidden flags

Prefer hook nodes with stable names and sparse prose. A mod should be able to
append one detail without fighting a large, over-specific paragraph.

Route through the store, never around it. Any node's next, any choice
target, and any graft can be a delegate function, and delegates should
read flags rather than private globals so saves, mods, and tools all see
the same truth. Divergence must also stay gentle: never fan one slot into
many parallel variants, because a row of siblings at a fixed spot reads
as a crossroads. The built-in graph instead picks at most one waking echo
per return (`choose-wake-echo` stores it in `wake-echo`, rotating by the
`wakes` counter) and surfaces it as a binary variant of whichever
ordinary room beat owns that detail diegetically — thread at the blanket,
pitch in the drawer, laminate on the lock plate. Path entries should stay
brief and diegetic: `base/drink`, `base/key-turn`, and `base/light-lantern`
are direct action beats before the path-owned node, and `ship/wake-after`,
`war/knock-again`,
`forest/threshold-again`, and `facility/desk-again` are revisit variants
chosen by each path's own flags. Durable artifacts are flagged as they
are established —
`alice-thread-pocket`, `alice-foreman-pencil`, `rogue-matchbook`,
`rogue-saw-tally`, `war-pencil-note`, `facility-second-coat`,
`forest-two-plates` — so later scenes and mods can pay them off.

## Loaded Dogfood Mods

- `one-pace/` — loaded from `mods/one-pace` and grafted onto
  `base/listen/steps`. It turns the stopped footsteps into a winter-night door
  vigil with a mod-local brace minigame, then returns through `one-pace/dawn`
  and its dawn close to `base/awake`. Documented in `story/one-pace.org`.
