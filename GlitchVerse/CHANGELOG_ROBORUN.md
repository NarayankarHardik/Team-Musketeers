# Robo Run Upgrade — Changelog

## Gameplay and visuals
- Replaced the original simple rectangular player drawing with BYTE, a procedural robot featuring a metallic shell, glowing antenna and chest reactor, expressive LED eyes, articulated longer arms and legs, run-cycle movement, blink timing, and dash afterimages.
- Added a forward dash mapped to `X` / `Ctrl`, with a short burst, cooldown, visual glitch feedback, sound effect, and HUD status chip.
- Added the pulsing `L` laser-shutter map tile. Orange telegraphs an upcoming activation; red indicates an active beam. Time freeze pauses its cycle.
- Improved platform shading with brighter top edges, inset surfaces, tile seams, and deeper contrast.
- Added a more layered animated background with skyline silhouettes and floating energy motes.
- Updated the project icon to a cute robot emblem.

## Level content
- Reworked the project into six long-form sectors: Gravity Leak, Phase Shift, Frozen Moment, Magnetic Mayhem, Overclock, and the final Core Meltdown.
- The first five sectors teach and combine mechanics progressively; the sixth combines gravity flip, dimension switching, time freeze, dash, moving platforms, lasers, and saw patrols in the hardest run.
- All six maps are 104 tiles wide and use a horizontally-following camera, creating substantially longer traversal routes.
- Added more spike trenches, ceiling hazards, dimension-specific structures, timed laser shutters, patrolling saws, and moving-platform sequences tailored to each sector.
- Each sector has a single mandatory access key on a safe landing lane before the exit barrier.
- Rebuilt the locked barrier as a continuous column from ceiling to floor, preventing the player from jumping over or bypassing it. The exit logic also checks key ownership independently.
- Updated the HUD to clearly show whether the key is still needed or has been acquired.
- The level selector and progression screens automatically use the new six-level list.

## Validation and limitations
- Static checks confirmed six level definitions, each map has 21 rows of 104 tiles, and every map contains exactly one player start, key, exit, and a full-height door column. Script delimiters and referenced `load()` paths were checked.
- A Godot executable was not available in the build environment, so runtime launch, GDScript parsing by the engine, and full playtesting could not be performed here. Open the project in Godot 4.x and press F5; the editor will regenerate its local `.godot` cache.
