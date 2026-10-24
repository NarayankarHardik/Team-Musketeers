[README_GitHub_GlitchVerse.md](https://github.com/user-attachments/files/33898919/README_GitHub_GlitchVerse.md)
# GLITCHVERSE: The World Is Broken

**A single-player puzzle-platformer built with Godot 4.x and GDScript.**  
**Challenge track:** PS01 — Single-Player Puzzle & Adventure  
**Team / Author:** _Add your team name and names here._

## Overview

GlitchVerse is a neon, glitch-themed platform adventure set inside a damaged virtual world. You play as **BYTE**, a small robot trying to cross unstable sectors and reach the exit. The world does not follow normal rules: instead of relying only on running and jumping, players can change the rules of each level by reversing gravity, switching between two dimensions, and freezing time.

The design goal is to make each power useful for both traversal and problem-solving. The first five sectors introduce and combine mechanics progressively; the sixth sector, **Core Meltdown**, acts as a final exam that challenges players to use every available skill together.

## The gameplay loop

1. Explore the sector and learn its layout.
2. Read the obstacle pattern and choose the right ability or route.
3. Jump, dash, reverse gravity, switch dimensions, or freeze moving hazards when needed.
4. Collect energy shards and find the required access key.
5. Use the key to pass the locked barrier and reach the exit portal.
6. Earn a result based on time, collectibles, and deaths, then move to the next sector.

The key is part of the progression puzzle—not just a bonus pickup. Players need to find it before the exit can be completed.

## Core mechanics

- **Gravity Flip — `Q` / `Shift`:** reverses the direction of gravity, opening ceiling routes and changing how the player crosses gaps and hazards.
- **Dimension Switch — `E`:** switches between cyan and magenta realities. Some platforms and barriers exist only in one dimension, so players must time switches and plan their route.
- **Time Freeze — `F`:** temporarily freezes supported moving hazards and platforms, creating a short window to cross dangerous sections.
- **Dash — `X` / `Ctrl`:** gives the robot a short burst of horizontal movement. It has a cooldown, so players must choose when to use it.
- **Jump — `W`, `Space`, or `Up`:** supports variable jump height; holding the button gives a higher jump.
- **Restart / Pause — `R` / `Esc` or `P`:** lets players retry a difficult section or pause the game.

The abilities are introduced in stages so the player can understand each one before facing combinations that require planning and timing.

## Six-sector progression

| Sector | Name | Main learning objective |
|---|---|---|
| 1 | **Gravity Leak** | Learn gravity reversal, ceiling routes, spike gaps, and moving-platform timing. |
| 2 | **Phase Shift** | Learn to switch between dimensions to use phase-specific paths and avoid blocked routes. |
| 3 | **Frozen Moment** | Learn to read hazard timing and use time freeze to cross moving hazards. |
| 4 | **Magnetic Mayhem** | Combine gravity and dimension switching across layered routes and phase bridges. |
| 5 | **Overclock** | Chain abilities through faster, denser obstacle sequences. |
| 6 | **Core Meltdown** | Final challenge combining gravity, dimension switching, time freeze, dash, hazards, and the key-locked exit. |

Each sector uses a long horizontal route with camera follow. The challenge grows through new mechanics and combinations, rather than only making the character move faster.

## Design choices

### Abilities change the level, not just the player
The three main powers affect traversal and the player's relationship with the environment. Gravity can turn a floor route into a ceiling route, dimension switching changes which structures are available, and time freeze changes the timing of supported moving obstacles.

### Keys make exploration matter
The key-and-door system provides a clear objective beyond reaching the far right of the level. Collectibles offer an additional reward, while the required key controls progression.

### Challenge builds gradually
Each sector focuses on a mechanic before asking the player to combine it with earlier skills. Core Meltdown is intended to test mastery of the complete control set.

### Consistent visual identity
The game uses neon cyan and magenta highlights, scanline/glitch styling, procedural character and environment drawing, and synthesized sound effects. This keeps the project visually coherent without relying on a large set of downloaded assets.

## Scoring and replay

The game tracks elapsed time, a target/par time, shards, score, and deaths. The score formula used in the current project is:

```text
score = 500 + (100 × shards collected) + (10 × seconds under par) − (50 × deaths)
```

Players can replay a sector to improve their time, collect more shards, avoid deaths, and earn a better rank.

## Controls

| Action | Keyboard |
|---|---|
| Move | `A` / `D` or Left / Right arrows |
| Jump | `W`, `Space`, or Up arrow |
| Flip gravity | `Q` or `Shift` |
| Switch dimension | `E` |
| Freeze time | `F` |
| Dash | `X` or `Ctrl` |
| Restart sector | `R` |
| Pause / Resume | `Esc` or `P` |

Some abilities are enabled progressively by sector, so a control may be unavailable until the relevant mechanic is introduced.

## Built with

- **Godot Engine 4.x**
- **GDScript**
- Godot 2D drawing and scene/node systems
- A custom glitch post-processing shader
- Procedurally drawn game visuals and runtime-synthesized sound effects

No separate art or audio downloads are required for the current source project. Use a Godot editor version compatible with the project's feature version.

## Run locally

1. Download or clone this repository.
2. Open **Godot Project Manager**.
3. Choose **Import** and select `project.godot` from the project folder.
4. Open the project and press **F5** to run the main scene.

The main scene is `scenes/Main.tscn`.

## Project structure

```text
project.godot
scenes/
  Main.tscn
shaders/
  glitch_post.gdshader
scripts/
  main.gd                 # Screen flow and post-processing
  game_state.gd           # Input map, progress, and save data
  levels.gd               # Sector definitions and ASCII maps
  level.gd                # Level creation, pickups, scoring, win/lose flow
  player.gd               # Movement and player abilities
  sfx.gd                  # Runtime sound effects
  entities/               # Pickups, doors, exit, hazards, platforms
  effects/                # Background and particle effects
  ui/                     # HUD, menus, pause, results, and end screens
```

## What we want players to experience

We want players to feel clever for solving a route, not just fast for getting through it. Each ability creates a different way to read the same space. The final sector brings those ideas together so the player's success depends on observation, timing, and choosing the right tool for each obstacle.

## Current limitations and future work

Potential next improvements include in-editor playtesting and balance passes, more distinct set-piece encounters, checkpoints placed according to difficulty, accessibility options for effects and controls, additional sound/music, and broader testing across window sizes and hardware.

> **Submission note:** Before submitting, add your team members, screenshots or a short gameplay GIF, and only describe tests as completed after running them in the Godot editor.
