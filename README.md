# Supreme Guacamole (2048+Dungeon)

A unique blend of the sliding-tile puzzle mechanics of **2048** and the adventurous exploration of a **Dungeon Crawler**, built for the [PICO-8](https://www.lexaloffle.com/pico-8.php) fantasy console.

## Overview

In **Supreme Guacamole**, your movements are your main weapon and tool. Inspired by the logic of 2048, every move shifts the entire board, forcing you to think strategically about positioning, combat, and resource management within a procedurally generated dungeon.

## Features

- **Sliding Mechanics:** Movement follows the classic 2048 rules—sliding all movable tiles in the chosen direction.
- **Dungeon Exploration:** Navigate through grids filled with walls, traps, and stairs.
- **Combat & Loot:** Encounter enemies (like Slimes and Bombs) and collect items/chests to aid your journey.
- **Procedural Boards:** Every game generates a new layout with different tile configurations and hazards.
- **PICO-8 Aesthetics:** Retro 8-bit graphics and sound.

## How to Play

### Requirements
You need the [PICO-8](https://www.lexaloffle.com/pico-8.php) software to run the source cartridge.

### Running the Game
1. Clone this repository.
2. Open PICO-8.
3. Load the cartridge:
   ```bash
   load 2048+dungeon.p8
   run
   ```

### Controls
- **Arrow Keys:** Move/Slide all tiles in the dungeon.
- **Z / C / (O):** Confirm / Action.
- **X / V / (X):** Action / Back.

## Development

The game is written in **Lua** within the PICO-8 environment. The main logic is contained in `2048+dungeon.p8`.

### Key Systems
- **Board Logic:** Managed via the `t_casillas` table.
- **Movement Phases:** Separated into player input, tile movement, and action resolution.
- **Procedural Generation:** Uses `CrearTScriptes` for environment tiles and randomized entity placement.

## License

This project is licensed under the **GNU General Public License v3.0**. See the [LICENSE](LICENSE) file for details.
