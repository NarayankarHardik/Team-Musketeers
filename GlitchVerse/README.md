# GlitchVerse - The World Is Broken
**Problem Statement PS01 - Single-Player Puzzle & Adventure**
Artificial Arcade VI - Atharva University, Mumbai

A 2D puzzle-platformer set inside a glitched virtual world. The player does not just
move through the level - they **rewrite its rules**: reverse gravity, phase between
two overlapping dimensions, and freeze time.

Built with **Godot 4.x** (GDScript, GL Compatibility renderer). This source project declares Godot 4.7 feature compatibility in `project.godot`; use a compatible editor version. No external assets -
all art is drawn in code, all sound is synthesised at runtime.

## How to open
1. Install Godot 4.2 or newer (standard build, no .NET needed).
2. Project Manager -> **Import** -> select `project.godot`.
3. Press **F5** (Play). Main scene: `scenes/Main.tscn`.

## Controls
| Key | Action |
|---|---|
| A / D, Arrows | Move |
| W / Space / Up | Jump (hold = higher) |
| Q / Shift | Flip gravity (cooldown 0.5 s) |
| E | Switch dimension (cyan <-> magenta) |
| F | Freeze time (4 s, then 5 s cooldown) |
| X / Ctrl | Dash forward (1.35 s cooldown) |
| R | Restart sector |
| Esc / P | Pause |
| F9 (level select) | Unlock all sectors |

## The six long-form sectors
| # | Name | Mechanic | Challenge focus |
|---|---|---|---|
| 1 | Gravity Leak | Gravity flip | Ceiling routes, spike trenches, moving platforms, and a key hunt |
| 2 | Phase Shift | Dimension switch | Alternating cyan/magenta structures, phase gates, and platform timing |
| 3 | Frozen Moment | Time freeze | Timed laser shutters, moving platforms, and multiple patrolling saws |
| 4 | Magnetic Mayhem | Gravity + phase | Vertical shafts, phase bridges, ceiling hazards, and layered routes |
| 5 | Overclock | Chained abilities | Faster overlapping saws, laser timing, phase blocks, and long obstacle chains |
| 6 | Core Meltdown | Final challenge: all skills | The longest and hardest reactor run combining gravity, phase, time-freeze, dash, hazards, and a mandatory key gate |

Each sector is a long scrolling route (104 tiles wide). The access key is placed on a safe landing lane before the exit barrier. The barrier is a continuous column from the ceiling to the floor, so it cannot be jumped over or bypassed; collecting the key opens it and the exit logic independently verifies key ownership.

## Requirements checklist (PS01)
- [x] 6 defined long-form sectors, including a final challenge that combines all abilities
- [x] At least 3 unique environment-altering mechanics (gravity reversal, dimension switching, time freezing)
- [x] Interactive puzzles / obstacles in every level (spikes, keys & doors, phase blocks, saws, moving platforms)
- [x] Functional level progression and restart system (result screen -> next sector, R to restart, auto-respawn on death, retry from results/pause)
- [x] Scoring AND timer-based performance tracking (par time, time bonus, shards, death penalty, ranks S-C)
- [x] Clear win/loss conditions and user-friendly interface (exit portal / system failure, HUD, menus, pause, how-to-play)
- [x] Smooth movement (coyote time, jump buffering, variable jump height, squash & stretch)

## Scoring
`score = 500 + 100 x shards + 10 x (seconds under par) - 50 x deaths`

## Project structure
```
project.godot
scenes/Main.tscn            entry scene (just a Node with main.gd)
shaders/glitch_post.gdshader  full-screen glitch / scanline / vignette effect
scripts/
  main.gd                   screen manager + post-processing
  game_state.gd  (autoload) input map, save data, shared flags
  sfx.gd         (autoload) procedural sound effects
  levels.gd                 LEVEL DATA - ASCII maps, saws, platforms, hints
  level.gd                  builds a level from its map, scoring, win/lose
  player.gd                 movement, 3 core abilities + dash
  entities/                 spike, pickup, saw, laser, moving_platform, door, exit_portal
  effects/                  burst (particles), background
  ui/                       hud, menus, result/pause/end screens, theme
```

## Editing levels
Open `scripts/levels.gd`. All six sectors use 104 x 21 maps with horizontal camera follow:

```
#  wall      .  empty     P  start     E  exit      o  shard     K  key
D  door      ^  spikes up v  spikes down   L  timed laser shutter
A  solid only in dimension A (cyan)    B  solid only in dimension B (magenta)
```
Saws and moving platforms are listed as dictionaries under each level
(`c1`/`c2` = patrol columns, `row`, `speed`, `yoff`). `abilities` controls which
powers a level unlocks. Add a new dictionary to `LEVELS` to add another sector. Each map must place its `K` key before a full-height `D` barrier and its `E` exit after that barrier.

## Tuning
Player feel lives at the top of `scripts/player.gd` (speed, jump, gravity,
cooldowns, freeze duration). Score values are constants at the top of `scripts/level.gd`.

## Adding a new mechanic
1. Add an input action in `game_state.gd` (`_setup_input`).
2. Add the ability in `player.gd` (`abilities` dictionary + `_handle_abilities`).
3. Enable it per level in `levels.gd`, and add a HUD chip in `ui/hud.gd`.


## Upgraded gameplay notes
- **BYTE** is drawn procedurally by `scripts/player.gd`: animated LED eyes, antenna, articulated arms and legs, core glow, run cycle, and dash afterimages.
- **Dash** is mapped to `X` or `Ctrl`. It provides a short directional burst with a cooldown and is shown in the HUD.
- **Laser shutters** use the map character `L`. Orange means a warning window; bright red means active. Time freeze also pauses their cycling.
- All six sectors are 104 tiles wide and use smooth horizontal camera follow, extra platform chains, and multiple obstacle sequences. The sixth sector is a final exam of the abilities introduced earlier. All sectors reuse the editable ASCII-map system. Tune hazards in each level's `saws` and `platforms` arrays.
- This ZIP intentionally omits Godot's generated `.godot` cache so Godot can rebuild editor/import data on first open. All project source files are included.
