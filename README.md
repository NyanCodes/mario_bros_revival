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

## Layout

| Path       | Contents                                      |
| ---------- | --------------------------------------------- |
| `Scenes/`  | `Game.tscn`, `Player.tscn`, `hidden_block.tscn` |
| `Scripts/` | GDScript files                                |
| `Assets/`  | Sprites and tilemaps                          |

## Working together

- The `*.import` and `*.uid` files next to assets **are** tracked. They keep resource
  IDs identical across machines, so commit them along with the asset itself.
- `.tscn` files are text but merge badly. Avoid editing the same scene at the same
  time — split work by scene, or use short-lived branches and pull before you start.
- Use branches and pull requests rather than pushing straight to `main`.
