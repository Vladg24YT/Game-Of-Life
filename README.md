# Game-Of-Life
![](https://img.shields.io/badge/openComputers-stable-brightgreen?style=plastic)

A Lua implementation of Conway's Game of Life for OpenComputers 1.7.5. 

*For 'Known issues' section, see Releases*

![Gosper Glider gun](/screenshots/gosper_glider_gun.png)

## Requirements
**Minimum:**<br>
![](/screenshots/minimum_configuration.png)
- Screen Tier 2
- Computer Case Tier 2:
  - Graphics Card Tier 2
  - CPU Tier 1
  - 2 RAM Tier 1
  - HDD Tier 1
  - EEPROM (Lua BIOS)
- Disk Drive
  - OpenOS Floppy
  
**Recommended:**<br>
![](/screenshots/recommended_configuration.png)
- Screen Tier 2
- Server Rack
- Server Tier 3:
  - Graphics Card Tier 3
  - CPU Tier 3
  - 4 RAM Tier 3.5
  - HDD Tier 3
  - EEPROM (Lua BIOS)
  - Internet Card
- Server disk drive with OpenOS Floppy

## Installation
**1st Method:**
1. `wget https://raw.githubusercontent.com/Vladg24YT/Game-Of-Life/master/gol.lua /home/gol.lua -fq`

**2nd Method:**
1. Download/clone the repository (`git clone -b master --progress https://github.com/Vladg24YT/Game-Of-Life.git`)
2. Copy file `gol.lua` to `.minecraft/saves/<world-name>/opencomputers/<filesystem-uuid>/` into `/bin` or `/home` directory

## UI & How to Play
![Game UI](/screenshots/ui.png)<br>
**Controls:**
- **]** - proceed to next generation
- **\[** - return to previous generation
- **\\** - start self-proceeding simulation
- **/** - clear field and restart
- **\`** - exit the game
- *LMB* - invert cell's state

The game is not yet optimized, so I recommend you to change cells' states when the bottom line is green like on a screenshot above. If the bottom line is red (screenshot below), all your actions will be put into event queue, so you won't be able to immediately see which cell you're changing.<br>
![](/screenshots/ui_red.png)

## Licensing

See file `LICENSE`
