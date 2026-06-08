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

## Current Branch Shape

The current branch events are deliberately obvious prototype hooks:

- `base/exit-bed`: starts the ordinary room interaction.
- `base/night-stand`: routes by visible object choice.
- `base/sleep`: enters the dream maze.
- `dream/maze-exit`: routes by maze exit value.

This is acceptable for proving the graph, minigame, music, particle, and mod
surfaces. Future versions should make these events subtler and easier for mods
to hook into. Prefer small diegetic cues, hidden flags, remembered details, and
ordinary node extension points over loud "choose your genre" moments.

## Base Room

The base room is intentionally under-described. It begins as a strange bedroom,
but each path should reveal that the player lacked the right context.

Current anchors:

- The bed can later read as a crash couch, prison bed, inn bed, dream bed, or
  dungeon memory without saying it changed.
- The night stand is a branch surface for objects whose meanings are path-local.
- Door counting and sound selection are secondary hook points for future paths.
- The room should remain sparse enough that mods can reinterpret it.

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
- The genre comfort is useful because later details can reframe the same room,
  bed, keyhole, inventory, and role expectations.
- It should not wink too hard at the player. The joke can exist, but the path
  should remain sincere enough to support later unease.

Current surface:

- `jrpg/inn` reframes the room as an inn room.
- `jrpg/party` chooses a companion and stores the selected companion.
- `jrpg/tower` ties the north tower door back to the same brass keyhole.
- `jrpg/demon-lord` keeps the bed visible in the demon lord room.

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
- A right exit returns to the base room.
- Failure returns to the base room through loss of corridor continuity.

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
