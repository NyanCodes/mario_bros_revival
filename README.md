# Mario Bros Revival

A 2D platformer built with **Godot 4.7** (GL Compatibility renderer).

## Getting started

1. Install [Godot 4.7](https://godotengine.org/download) or newer.
2. Clone the repo:
   ```bash
   git clone https://github.com/NyanCodes/mario_bros_revival.git
   ```
3. In the Godot Project Manager, click **Import**, select `project.godot`, and open it.

On first open Godot regenerates the `.godot/` folder (import cache). That folder is
git-ignored on purpose — never commit it.

## What's in so far

- **Player movement** — walk, jump, gravity, and platform collision
  (`Scripts/player.gd`). Falling into a pit respawns you at the start.
- **Stage 1: Basic Platforming** — `Scenes/Stage1.tscn`, the game's main scene.
  A 215-tile stage that starts flat, then introduces a step, four pits, and
  floating platforms.

Coins, enemies, power-ups, the goal flag and Stages 2-3 are not built yet.

## Controls

| Action | Keys                    |
| ------ | ----------------------- |
| Move   | `A` / `D` or `←` / `→`  |
| Jump   | `Space`, `W`, or `↑`    |

## Layout

| Path                                | Contents                                     |
| ----------------------------------- | -------------------------------------------- |
| `Scenes/Stage1.tscn`                | Stage 1 — the main scene                     |
| `Scenes/Player.tscn`                | The player; its origin sits at its feet        |
| `Scenes/Game.tscn`                  | Older sandbox scene, kept for reference       |
| `Scenes/hidden_block.tscn`          | Surprise block, not placed in a stage yet     |
| `Assets/Tilemap/world_tileset.tres` | Shared `TileSet` — 18x18 tiles, used by every stage |
| `Scripts/`                          | GDScript files                                |
| `Assets/`                           | Sprites and tilemaps                          |

## Level editing

Stage 1 is two `TileMapLayer` nodes: `Terrain` (solid) and `Decor` (plants, no
collision). Both share `world_tileset.tres`, so paint them with the TileMap
editor as usual. The jump tuning in `Scripts/player.gd` clears roughly a 110 px
gap and a 63 px rise — keep new gaps under that or the stage becomes impossible.

## Working together

- The `*.import` and `*.uid` files next to assets **are** tracked. They keep resource
  IDs identical across machines, so commit them along with the asset itself.
- `.tscn` files are text but merge badly. Avoid editing the same scene at the same
  time — split work by scene, or use short-lived branches and pull before you start.
- Use branches and pull requests rather than pushing straight to `main`.
