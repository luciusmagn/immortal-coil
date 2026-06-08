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

The "future shapes the past" effect only works when transitions are gentle
enough that a player on a single playthrough would not recognize them as
transitions. A branch entry should feel like the next ordinary detail in the
same situation; only later, or on another route, should the player understand
that the detail carried them into a different context.

## Current Branch Shape

The current branch events are still prototype hooks, but the base-room split
should avoid looking like a genre picker or a symbolic object menu:

- `base/exit-bed`: starts the ordinary room interaction.
- `base/thirst`, `base/match`, and `base/unlock-door`: route through actions
  discovered while exploring the room.
- `base/sleep`: enters the dream maze.
- `dream/maze-exit`: routes by maze exit value.

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

Current surface:

- `ship/wake` reveals restraint straps and indicator lights in reflection.
- `ship/name` collects what the room calls the captain.
- `ship/flight` is the wireframe flight minigame.
- Failure loops back into the same alarm without explaining the loop.

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

Future writing should soften the branch trigger. The player should not feel that
"brass key means forest route" as clearly as they do in this draft.

## JRPG Adventure

The matchbook path leads to a straight-faced fantasy adventure.

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
- `jrpg/party` chooses a companion and stores the selected companion.
- `jrpg/overworld` is a small overworld-walk minigame.
- `jrpg/slime-combat` is an early-Final-Fantasy-style turn combat minigame.
- `jrpg/tower-choice` records the tower approach.
- `jrpg/demon-choice` records how the player approaches the demon lord.

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
- A right exit should lead toward the containment-researcher path.
- Failure/lost results should also lead into authored content, not a literal
  loop back to the opening.

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

## Rogue Branch

The upper dream exit leads to a Rogue-inspired dungeon branch.

Author truth:

- The branch should evoke terse dungeon logic: inventory, doors, hidden danger,
  identification, stairs, and grid-like movement.
- It should be austere and readable, not a parody.
- Earlier room details can return as dungeon objects, but should feel like they
  were always part of this frame.

Current surface:

- `rogue/entrance` opens onto hard white dungeon lines.
- `rogue/inventory` gives a ration, ring, and stair memory.
- `rogue/door` chooses a door by list.
- `rogue/loot` chooses scroll, ring, or ration.

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

Visual note:

- A black-and-white demake-style flash of an SCP-Foundation-like circular logo
  could be a strong beat if used sparingly. Treat it as a brief visual memory or
  institutional mark, not as an explanatory title card.

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
