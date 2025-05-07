# ArDenHub Staff Tag System

A FiveM resource that displays a customizable tag above staff members' heads, making them easily identifiable to players.

## Features

- Displays a customizable tag above staff members
- Staff can toggle their tag visibility with a command or keybind
- Customizable tag color, text, and appearance
- Tag visibility fades with distance
- Pulse animation effect
- Discord webhook integration for logging

## Requirements

- ESX Framework

## Installation

1. Download the resource
2. Place it in your server's `resources` directory
3. Add `ensure ardenhub_tagstaff` to your `server.cfg`
4. Configure the `config.lua` file according to your needs

## Configuration

The `config.lua` file allows you to customize:

- Staff identifiers (license, steam, discord)
- Discord webhook for logging
- Tag appearance (color, text, font)
- Visual effects (glow, pulse animation)
- Maximum visibility distance
- Default keybind

## Commands

- `/tagstaff` - Toggle the staff tag on/off
- `/tagcolor [r] [g] [b]` - Change the tag color (RGB values 0-255)
- `/tagtext [text]` - Change the tag text (max 20 characters)

## Permissions

Staff members are identified by:
1. Their identifiers in the `Config.StaffIdentifiers` list
2. ESX permissions (owner, admin, mod, helper)

## Author

Created by [ArduinoDenis](https://arduinodenis.it)

## Support
For support, contact [**ArDenHub**](https://discord.ardenhub.it) in the discord or open an issue on GitHub.