# Project Overview

This is the codebase for Monkestation, a fork of the popular Space Station 13 game. The project is built using the BYOND engine and its proprietary language, Dream Maker (DM). The game is a round-based roleplaying game set on a space station, filled with paranoia and sci-fi elements.

The project is a fork of the /tg/station codebase and has its own set of modifications and features. The codebase is actively maintained and has a dedicated community.

## Development Conventions

The project has a set of coding guidelines and contribution rules that should be followed.

*   **Coding Guidelines:** The coding guidelines can be found on [HackMD](https://hackmd.io/@MonkestationPooba/code_guidelines).
*   **Contributing:** The contributing guide is located in the `.github/CONTRIBUTING.md` file. It provides information on how to contribute to the project, including pull request guidelines and code of conduct.
*   **Git Hooks:** The project uses git hooks to enforce commit message formatting. Make sure to install them by running `git config core.hooksPath .githooks`.

## Key Files

*   `tgstation.dme`: The main project file for the Dream Maker environment. It acts as the central manifest, including all other source files, icons, and resources required to compile and run the game.
*   `bin/`: Contains essential command scripts for managing the project. `build.cmd` compiles the code, and `server.cmd` builds and launches the development server.
*   `code/`: This directory is the heart of the game, containing the majority of the game's source code written in Dream Maker (DM).
    *   `__DEFINES/`: Holds global macro definitions.
    *   `modules/`: Contains the source for in-game objects, items, mechanics, and systems.
    *   `game/`: Core game loop, mode handling, and fundamental systems.
    *   `datums/`: Data-only objects for various game components.
*   `config/`: Contains all server configuration files. This is where you configure admins (`admins.txt`), job slots (`jobconfig.toml`), map rotation (`maps.txt`), and game settings (`config.txt`).
*   `html/`: Contains HTML, CSS, and JavaScript files for the in-game browser, the stat panel, and other UI elements that use a web-based renderer.
*   `icons/`: A vast collection of `.dmi` files, which are sprite sheets containing all the in-game graphics for objects, mobs, turfs, and effects.
*   `interface/`: Contains files related to the game's native UI, such as the main menu (`menu.dm`) and the UI skin (`skin.dmf`).
*   `_maps/`: Contains the game's map files, primarily in the `.json` (TGM) format, which is a text-based format for defining maps.
*   `tgui/`: Contains the source code for `tgui`, a modern React-based UI library used for creating complex and interactive in-game windows. The source is written in TypeScript and can be developed independently using `bin/tgui-dev.cmd`.
*   `tools/`: Contains various development tools, including build scripts (`build/`), map editors, and other utilities. The `tools/build/README.md` provides details on advanced build options.
*   `.github/`: Holds project metadata for GitHub, including issue templates, pull request templates, and the main `CONTRIBUTING.md` guide.

## Codebase Deep Dive

This section provides a granular look at the project's structure, focusing on individual files and modules within the `code` and `monkestation` directories.

### `/code/` - The Core Game Logic

This is the primary directory for all Dream Maker (DM) source code, inherited from the upstream /tg/station repository.

*   `world.dm`: Defines `world`, the global singleton object in BYOND. It's the entry point for many global procedures and holds global variables.
*   `_compile_options.dm`: Contains preprocessor directives that control the compilation process, enabling or disabling large parts of the codebase.
*   `__DEFINES/`: A critical directory holding global macros, constants, and preprocessor directives. These files define everything from mob states to reagent IDs.
*   `__HELPERS/`: Contains helper functions and macros that are used throughout the codebase, but don't fit into a specific module.
*   `controllers/`: Manages global, persistent subsystems.
    *   `ticker.dm`: The heart of the game loop. It manages round setup, game mode selection, round start/end, and shuttle calls.
    *   `process_scheduler.dm`: Manages a queue of long-running processes to distribute CPU load over multiple ticks.
*   `datums/`: Defines data-only objects. These are the building blocks of the game's data model.
    *   `datum/reagent.dm`: The base type for all chemicals in the game.
    *   `datum/game_mode.dm`: The base type for all game modes (e.g., Traitor, Changeling, Nuclear Emergency).
*   `game/`: Core game logic that doesn't fit into a specific module.
    *   `process.dm`: The main game loop `process()` proc, which is called by the BYOND engine on every tick.
    *   `say.dm`: Handles all mob communication, including speaking, whispering, and radio messages.
*   `modules/`: The bulk of the game's features are implemented here. Each subdirectory is a module for a specific system.

#### Module Deep Dive: `/code/modules/power/`

The power module handles all aspects of electricity on the station.

*   `powernet.dm`: The core of the power system. It defines the `powernet` object, which tracks all connected power equipment and distributes power.
*   `cable.dm`: Defines the different types of power cables and their behavior, including how they connect to form a grid.
*   `apc/`: Contains the code for Area Power Controllers (APCs), which distribute power to a specific area and manage lighting and equipment power.
*   `smes.dm`: Defines the Superconducting Magnetic Energy Storage (SMES) units, which are the station's primary batteries for storing large amounts of power.
*   `singularity/`: The code for the singularity engine, a high-risk, high-reward power source that creates a black hole.
*   `supermatter/`: The code for the supermatter engine, another high-risk power source that involves a crystal that reacts to radiation.
*   `solar.dm`: Defines the solar arrays and the solar control computer, the station's primary, safe power source.

#### Module Deep Dive: `/code/modules/surgery/`

This module contains the logic for performing medical surgery on mobs.

*   `surgery.dm`: The main file that defines the overall surgery process and the `GLOBAL_SURGERY_ACTIONS` list.
*   `surgery_step.dm`: Defines the base `surgery_step` object. Each individual action in a surgery (e.g., cutting, clamping, retracting) is a `surgery_step`.
*   `tools.dm`: Defines the medical tools used for surgery, such as scalpels, retractors, and hemostats.
*   `amputation.dm`: Contains the surgery steps for amputating a limb.
*   `organ_manipulation.dm`: Contains the steps for removing and transplanting organs.
*   `prosthetic_replacement.dm`: Defines the surgery for replacing limbs with robotic prosthetics.
*   `bodyparts/`, `organs/`: These subdirectories define the individual body parts and organs that can be operated on.

### `/monkestation/` - Fork-Specific Modifications

This directory contains code that is specific to the Monkestation fork. It overrides or extends the functionality of the base `/tg/` code. The directory structure mirrors the main `/code` directory. Any file here with the same path as a file in `/code` will be loaded *after* the base file, allowing it to override procs and variables.

*   `monkestation/code/modules/`: Contains Monkestation's new modules or modifications to existing ones.
*   `monkestation/code/datums/`: Custom datums for Monkestation features.
*   `monkestation/code/__DEFINES/`: Monkestation-specific defines.

## Module Index

This section provides a comprehensive list of all modules in the `/code/modules` directory, with a brief description of their purpose.

*   **actionspeed**: Modifies the speed of various character actions. This module uses a system of `actionspeed_modifier` datums to reliably manage speed changes from multiple sources.
    *   `_actionspeed_modifier.dm`: Defines the core `actionspeed_modifier` datum and the procs for adding, removing, and updating speed modifiers on mobs. It includes logic for caching static modifiers and handling variable ones.
    *   `modifiers/`: This directory contains specific implementations of `actionspeed_modifier` for various in-game effects.
        *   `addiction.dm`: Adds a speed boost for stimulants.
        *   `base.dm`: Defines the default, variable speed modifier for mobs.
        *   `drugs.dm`: Contains a modifier for the "kronkaine" drug, which provides a large speed boost.
        *   `mood.dm`: Implements speed changes based on sanity levels (slower for low sanity, faster for high sanity).
        *   `status_effects.dm`: Defines modifiers for various status effects, including speed boosts and slowdowns.
        *   `wound.dm`: Implements a slowdown effect based on the severity of a character's wounds.
*   **art**: Tools and objects for creating art. This module contains the logic for paintings and statues.
    *   `paintings.dm`: Defines the systems for creating, displaying, and saving paintings. This includes the `canvas` item which players can draw on using a TGUI, the `easel` to hold the canvas, `painting` frames for display, and the `paint_palette` tool. It also includes a system for saving paintings persistently across rounds.
    *   `statues.dm`: Defines the system for creating statues. This includes the base `statue` object with many subtypes for different materials and shapes, the `chisel` tool for carving, and the `carving_block` from which statues are made. It also allows for creating custom statues based on the appearance of other objects.
*   **autowiki**: Automatically generates wiki documentation from the code. This module is used to keep the official game wiki up-to-date with in-game information.
    *   `autowiki.dm`: Contains the core logic for the autowiki system. It works by iterating through all subtypes of `/datum/autowiki` and calling their `generate()` proc to create a data file that is then used by an external script to update the wiki.
    *   `pages/`: This directory contains the definitions for the different wiki pages that are automatically generated.
        *   `base.dm`: Defines the base `/datum/autowiki` with helper functions for creating mediawiki templates and uploading icons.
        *   `techweb.dm`: Generates the documentation for the research and development tech tree, including both standard and experimental nodes.
        *   `vending.dm`: Generates documentation for all vending machines, listing their inventory of standard, contraband, and premium items.
*   **awaymissions**: Code for away missions and dynamically loaded maps. This module contains the core logic for creating and managing away missions, as well as code for specific missions.
    *   `away_props.dm`: Defines several objects used in away missions, such as one-way barriers, wind effects, path blockers, and pit grates.
    *   `cordon.dm`: Defines a special turf and area used to create impassable map borders, including a version that blocks ghosts.
    *   `exile.dm`: Defines a secure closet containing exile implants, which are used to prevent players from returning to the main station.
    *   `gateway.dm`: Defines the gateway system, which allows for travel between different locations. It includes the gateway objects, destination data structures, and a control computer.
    *   `pamphlet.dm`: Defines several informational pamphlets, some of which provide lore or give items to the player.
    *   `signpost.dm`: Defines a structure that can teleport a player back to a safe location on the station.
    *   `super_secret_room.dm`: Defines a secret error-handling room where players are sent when something goes wrong. It features a talking tile that provides meta-commentary.
    *   `zlevel.dm`: Contains the logic for loading away missions on separate z-levels, including picking a random map and setting up gateway destinations.
    *   `mission_code/`: This subdirectory contains code specific to individual away missions.
        *   `Cabin.dm`: Code for a snow-themed mission, including areas, a firepit, a lumbermill, and a snowy map generator.
        *   `caves.dm`: Code for a cave-themed mission, with areas and lore-providing paper objects.
        *   `centcomAway.dm`: Code for a mission on a former Central Command station, with areas and lore papers.
        *   `moonoutpost19.dm`: Code for a mission on a moon outpost that was studying xenomorphs, with areas, decorative objects, and a large number of lore papers.
        *   `murderdome.dm`: Code for an arena-style mission, with indestructible objects and respawning barricades.
        *   `research.dm`: Code for a research outpost mission, with areas and a paper about sensitive data.
        *   `snowdin.dm`: Code for a large snow-themed mission with many areas, items, and lore-filled papers and holodisks.
        *   `stationCollision.dm`: Code for a mission involving a station collision, with a safe-cracking objective.
        *   `undergroundoutpost45.dm`: Code for an underground outpost mission, defining the areas of the outpost.
*   **basketball**: Implements the physics and rules for the game of basketball. This module contains everything needed to play a game of basketball, including a minigame mode for ghosts.
    *   `basketball_map_loading.dm`: Defines landmarks for spawning basketball-related objects and areas, as well as map templates for different basketball stadiums.
    *   `basketball_teams.dm`: Defines the outfits for the different basketball teams and the referee.
    *   `basketball.dm`: Defines the basketball object itself, including its physics and interactions like dribbling, passing, and shooting.
    *   `controller.dm`: The main controller for the basketball minigame. It manages player signups, game setup, starting and ending the game.
    *   `hoop.dm`: Defines the basketball hoop, including scoring logic and a minigame variant.
    *   `referee.dm`: Defines the referee's whistle and the "timeout" action to call fouls.
*   **buildmode**: Provides an in-game editor for map and object manipulation. This module is used by admins and developers to modify the game world in real-time.
    *   `buildmode.dm`: The core of the module, it manages the build modes, switches between them, and handles user input.
    *   `bm_mode.dm`: A base class for all build modes, it provides common functionality like area selection.
    *   `buttons.dm`: Defines the UI buttons for interacting with the build mode.
    *   `submodes/`: This directory contains the actual build mode implementations, each as a separate file. The available modes are:
        *   `basic.dm`: Allows creation of simple structures consisting of floors, walls, windows, and airlocks.
        *   `advanced.dm`: Creates an instance of a configurable atom path where you click.
        *   `fill.dm`: Creates an instance of an atom path on every tile in a chosen region.
        *   `copy.dm`: Take an existing object in the world, and place duplicates with identical attributes where you click.
        *   `area_edit.dm`: Modifies and creates areas.
        *   `variable_edit.dm`: Allows for setting and resetting variables of objects with a click.
        *   `mapgen.dm`: Fills rectangular regions with algorithmically generated content.
        *   `throwing.dm`: Select an object with left click, and right click to throw it towards where you clicked.
        *   `boom.dm`: Make explosions where you click.
        *   `delete.dm`: Deletes objects.
        *   `map_export.dm`: Exports a part of the map to a file.
        *   `outfit.dm`: Allows to save and load outfits.
        *   `proccall.dm`: Allows to call a proc on an object.
        *   `smite.dm`: Smites objects.
        *   `tweakcomps.dm`: Allows to tweak components of an object.
*   **capture_the_flag**: Implements the "Capture the Flag" game mode. This module contains the logic for a team-based game where the objective is to capture the enemy's flag and bring it to your own base.
    *   `ctf_controller.dm`: Manages the overall CTF game, including teams, scoring, and game state.
    *   `ctf_game.dm`: Defines the objects used in the game, such as spawners, flags, and control points.
    *   `ctf_player_component.dm`: A component attached to players that handles player-specific logic like respawning and team association.
    *   `ctf_classes.dm`: Defines the different classes that players can choose from, each with their own unique equipment.
    *   `ctf_equipment.dm`: Defines the equipment used by the different classes.
    *   `ctf_map_loading.dm`: Handles the loading of CTF maps.
    *   `ctf_panel.dm`: Defines the UI panel for the CTF game, showing scores and other relevant information.
    *   `ctf_voting.dm`: Handles the voting system for starting a CTF game.
    *   `medieval_sim/`: Contains a medieval-themed version of CTF with its own set of classes and equipment.
*   **cards**: Defines the behavior of card games like poker. This module provides a framework for creating and managing card games, including different types of decks and hands.
    *   `cards.dm`: The base file that defines the core functionality of cards, including drawing, inserting, and throwing them.
    *   `cardhand.dm`: Manages the player's hand of cards, including UI and interactions.
    *   `singlecard.dm`: Defines the individual card object.
    *   `deck/`: This directory contains different types of decks, such as a standard 52-card deck, a tarot deck, and a wizard deck.
*   **chatter**: Simulates background chatter and radio noise. This module takes a string of text and converts it into a series of sounds that mimic speech, adding to the game's ambient audio.
*   **cluwne**: Logic for the Cluwne antagonist role. This module contains the code for a cursed clown that transforms people into other cluwnes.
    *   `cluwne_component.dm`: The core of the module, this component turns a human into a "cluwne" and back. It handles the transformation, including changing the brain and applying new clothing.
    *   `cluwne_brain.dm`: Defines the "cluwne" brain, which gives the player negative traits and a "banana tumor" brain trauma, causing erratic behavior.
    *   `cluwne_clothing.dm`: Defines the special, indestructible clothing that "cluwne"s wear, including a mask that replaces speech with "HONK!".
*   **deathmatch**: A game mode where everyone is an antagonist. This module provides a complete deathmatch experience, with lobbies, loadouts, maps, and modifiers.
    *   `deathmatch_controller.dm`: The main entry point for the deathmatch game mode. It manages lobbies, players, and the overall game state.
    *   `deathmatch_loadouts.dm`: Defines a wide variety of loadouts that players can choose from, each with unique equipment and sometimes special abilities.
    *   `deathmatch_lobby.dm`: Defines the lobby for a deathmatch game, handling player and observer management, map and loadout selection, and game start/end.
    *   `deathmatch_mapping.dm`: Defines some of the map elements used in deathmatch maps, such as player spawns and environmental hazards.
    *   `deathmatch_maps.dm`: Defines the various maps available for the deathmatch game mode, each with its own layout, player limits, and allowed loadouts.
    *   `deathmatch_modifier.dm`: Defines a variety of modifiers that can be applied to a deathmatch game to change the rules and gameplay.
*   **debugging**: Provides tools and commands for debugging the game. This module includes a debugger and a profiler to help developers identify and fix issues.
    *   `debugger.dm`: This file defines a debugger that can be enabled to help with development. It uses an external DLL (`auxtools`) to provide debugging functionality.
    *   `tracy.dm`: This file defines an integration with `byond-tracy`, a profiling tool for BYOND. It allows for enabling and disabling the profiler, and for flushing the trace log.
*   **detectivework**: Code for the detective's special equipment and abilities. This module provides the tools for the detective to gather and analyze evidence.
    *   `scanner.dm`: Defines the detective's forensic scanner, which is used to scan for fingerprints, DNA, and other evidence on objects and people.
    *   `evidence.dm`: Defines the `evidencebag` item, which is used to store and preserve evidence for later analysis.
*   **discord**: Integration with Discord for things like admin notifications. This module allows for linking BYOND and Discord accounts, sending rich embeds, and creating interactive bot commands.
    *   `accountlink.dm`: Allows a user to link their BYOND account to their Discord account.
    *   `discord_embed.dm`: Defines a datum for creating Discord embeds, which are used to send richly formatted messages.
    *   `discord_link_record.dm`: Defines a simple datum to hold the information about a linked Discord account.
    *   `tgs_commands.dm`: Defines several Discord bot commands that can be used to interact with the game server, such as checking the server status and getting the game version.
    *   `toggle_notify.dm`: Defines a verb that allows a player to toggle whether they receive a Discord notification when the server restarts.
*   **economy**: Simulates a station-wide economy with currency and markets. This module manages player bank accounts, transactions, and paydays.
    *   `account.dm`: Defines the `bank_account` datum, which is the core of the economy system. It stores the account holder's name, balance, and other information. It also handles transactions, paydays, and bounties.
    *   `holopay.dm`: Defines a holographic pay stand that can be used to transfer credits from one account to another.
*   **emoji**: Adds support for emojis in chat. This module provides the logic for parsing and sanitizing emoji codes, replacing them with the corresponding emoji icon.
*   **emote_panel**: The UI panel for selecting and using emotes. This module provides a user-friendly interface for players to express themselves through a wide variety of emotes.
*   **engineering**: Core module for station engineering, including the engine and power distribution. This module is not self-contained, and the core logic for power and atmospherics is located in their respective modules. This module primarily contains tools and other items used by engineers.
    *   `tools/multitool.dm`: Defines the multitool, a fundamental tool for engineers used for a variety of tasks, such as hacking, repairing, and diagnosing machinery.
*   **error_handler**: Catches and logs runtime errors. This module provides a custom error handler that gives more detailed information than the default BYOND error handler, and includes a UI for viewing and managing errors.
    *   `error_handler.dm`: Defines the custom error handler, which catches runtime errors, logs them, and provides features like error silencing.
    *   `error_viewer.dm`: Defines the UI for viewing the errors caught by the error handler, allowing admins to inspect the error details.
*   **escape_menu**: The main game menu that is accessed with the Escape key. This module handles the creation of the menu, the blurring of the background, and the switching between different pages of the menu.
    *   `escape_menu.dm`: The main file that defines the escape menu and handles its creation and page switching.
    *   `subsystem.dm`: Defines the escape menu as a processing subsystem.
    *   `details.dm`: Defines the details that are displayed in the escape menu, such as the round ID and map name.
    *   `dimmer.dm`: Defines a screen-sized dimmer that is used to darken the background when the escape menu is open.
    *   `home_page.dm`: Defines the home page of the escape menu, which contains buttons for various actions like resuming the game, opening settings, and leaving the body.
    *   `leave_body.dm`: Defines the "Leave Body" page of the escape menu, which gives the player the option to either commit suicide or become a ghost.
    *   `title.dm`: Defines the title that is displayed in the escape menu, which includes the station name.
*   **explorer_drone**: Code for the player-controlled explorer drones. This module allows players to send drones on exploration missions to various sites, where they can encounter events, find loot, and participate in adventures.
    *   `exodrone.dm`: Defines the `exodrone` item, which is a player-controlled drone that can be sent on exploration missions. It also defines the `exodrone_launcher` machine, which is used to launch and refuel the drones.
    *   `control_console.dm`: Defines the control console for the exploration drones. It allows players to select a drone, view its status, and control its actions.
    *   `manager.dm`: Defines the `adventure_browser` datum, which is an admin-only tool for managing and testing adventures for the exploration drones.
    *   `exploration_events/`: This directory contains the different types of events that can be encountered during an exploration mission, such as finding resources, encountering danger, or meeting a trader.
    *   `example_adventures/`: This directory contains example adventures that can be used as a reference for creating new adventures.
    *   `adventure.dm`: Defines the base class for adventures.
    *   `exploration_site.dm`: Defines the exploration sites that the drones can travel to.
    *   `loot.dm`: Defines the loot that can be found during exploration missions.
    *   `scanner_array.dm`: Defines the scanner array, which is used to find new exploration sites.
*   **fishing**: Implements the mechanics of fishing. This module includes everything from the fishing rod and the fishing minigame to the different types of fish and where to find them.
    *   `fishing_rod.dm`: Defines the fishing rod item, which is the primary tool for fishing.
    *   `fishing_minigame.dm`: Defines the fishing minigame that players engage in when they cast their line.
    *   `fish_catalog.dm`: Defines the "Fish Encyclopedia", a book that provides information about all the different types of fish in the game.
    *   `fish/`: This directory contains the definitions for the different types of fish that can be caught.
    *   `sources/`: This directory contains the definitions for the different sources where fish can be found.
    *   `aquarium/`: This directory contains the code for the aquarium, where players can keep their caught fish.
    *   `admin.dm`: Contains admin-related tools for managing the fishing system.
    *   `bait.dm`: Defines the different types of bait that can be used for fishing.
    *   `fishing_equipment.dm`: Defines other fishing-related equipment.
    *   `fishing_portal_machine.dm`: Defines a machine that can be used to create fishing portals.
*   **flufftext**: Adds descriptive text to items and objects. This module is responsible for the dreaming system, which provides flavor text to sleeping players.
    *   `Dreaming.dm`: This file defines the dreaming system, which provides flavor text to sleeping players. It defines different types of dreams, including random dreams and dreams for heretics.
*   **forensics**: Tools and mechanics for forensic investigation. This module provides the systems for tracking and analyzing forensic evidence, such as fingerprints, blood, and fibers.
    *   `_forensics.dm`: Defines the `forensics` datum, which is attached to atoms and stores forensic information.
    *   `forensics_helpers.dm`: Provides helper functions for adding and transferring forensic data to and from atoms.
*   **holiday**: The system for holiday-themed events and items.
    *   `foreign_calendar.dm`: This file contains the logic for converting between different calendar systems. It defines a base `foreign_calendar` datum and then specific implementations for Islamic and Hebrew calendars. It includes functions for converting Gregorian dates to Julian Day, and for handling leap years in different calendars. This is used to determine the dates of holidays that don't follow the Gregorian calendar.
    *   `holidays.dm`: This is the core file for the holiday system. It defines the base `/datum/holiday` with variables for the holiday's name, start and end dates, and other properties. It includes the `shouldCelebrate()` proc to determine if a holiday is active. It also defines a large number of specific holidays, from "Fleet Day" to "New Year's", each with their own properties, greetings, and sometimes special effects. It also contains logic for holiday-themed station names and colors.
    *   `nth_week.dm`: This file defines a special type of holiday, `/datum/holiday/nth_week`, for holidays that fall on the "nth" weekday of a month, like Thanksgiving (the 4th Thursday in November). It includes logic to calculate the correct date for these holidays. It defines several specific `nth_week` holidays, such as Thanksgiving, Mother's Day, Father's Day, and Moth Week.
*   **holodeck**: The holodeck and its various programs.
    *   `computer.dm`: This file contains the core logic for the holodeck computer console. It handles the UI, program selection, and loading of holodeck programs. It defines the `/obj/machinery/computer/holodeck` object, which manages the holodeck's state, including the currently loaded program, spawned objects, and power usage. It also includes logic for emergency shutdowns, safety protocols, and emagging.
    *   `holo_effect.dm`: This file defines special effect objects that can be used in holodeck programs. It defines the base `/obj/effect/holodeck_effect` and several specific effects, such as spawning cards, sparks, random books, and various mobs like carps, pets, and monkeys. These effects are activated when the holodeck program loads and are managed by the holodeck computer.
    *   `holodeck_map_templates.dm`: This file defines the various programs that can be loaded on the holodeck. Each program is a `/datum/map_template/holodeck` that points to a specific map file. It defines a wide range of programs, from simple courts for sports to complex simulations like a beach, a firing range, or even a winter wonderland. It also defines restricted, "emagged" programs that are only available when the holodeck's safeties are disabled.
    *   `items.dm`: This file defines various items that are specific to holodeck programs. This includes holographic energy swords, dodgeballs, skateboards, and other items that are spawned as part of a holodeck simulation. These items are typically flagged as holographic and may have modified behaviors, such as doing stamina damage instead of brute damage when safeties are on.
    *   `turfs.dm`: This file defines the special floor tiles used in the holodeck. The base is `/turf/open/floor/holofloor`, which is a special turf that can be dynamically changed by holodeck programs. It defines various appearances for the holofloor, such as grass, sand, water, and even space. These turfs are essential for creating the immersive environments of the holodeck programs.
*   **instruments**: Playable musical instruments.
    *   `instrument_data/_instrument_data.dm`: This file defines the base datum `/datum/instrument_data`, which holds the sound data for a specific instrument. It contains variables for the instrument's name, sound file, and other properties.
    *   `instrument_data/_instrument_key.dm`: This file defines the `/datum/instrument_key` datum, which represents a single key or note on an instrument. It holds the note's pitch and the instrument it belongs to.
    *   `instrument_data/brass.dm`: This file contains the instrument data for various brass instruments, such as the trumpet, trombone, and tuba.
    *   `instrument_data/chromatic_percussion.dm`: This file contains the instrument data for chromatic percussion instruments like the xylophone and marimba.
    *   `instrument_data/fun.dm`: This file contains instrument data for "fun" or novelty instruments, like the bike horn and air horn.
    *   `instrument_data/guitar.dm`: This file contains the instrument data for guitars, including acoustic and electric guitars.
    *   `instrument_data/hardcoded.dm`: This file contains instrument data for instruments that have their sounds hardcoded in the engine, rather than using external sound files.
    *   `instrument_data/organ.dm`: This file contains the instrument data for organs.
    *   `instrument_data/piano.dm`: This file contains the instrument data for pianos.
    *   `instrument_data/synth_tones.dm`: This file contains a variety of synthesized tones that can be used as instruments.
    *   `items.dm`: This file defines the base `/obj/item/instrument` object, which is the parent for all playable instrument items. It contains the core logic for playing notes, handling UI, and managing the instrument's state.
    *   `piano_synth.dm`: This file contains specific logic for the piano and synthesizer instruments, including their UI and special features.
    *   `songs/_song.dm`: This file defines the base `/datum/song` datum, which represents a pre-recorded song that can be played on an instrument. It contains the song's title, artist, and a list of notes.
    *   `songs/editor.dm`: This file contains the logic for the in-game song editor, which allows players to create and edit their own songs.
    *   `songs/play_legacy.dm`: This file contains the logic for playing back legacy song formats.
    *   `songs/play_synthesized.dm`: This file contains the logic for playing back songs using synthesized instrument sounds.
    *   `stationary.dm`: This file defines large, stationary instruments that cannot be picked up, such as grand pianos and church organs.
*   **keybindings**: Manages custom keybindings for players.
    *   `bindings_atom.dm`: This file handles keybindings that are specific to in-game objects (`atoms`). It defines the `keyLoop` proc for movable atoms, which processes movement input from the client and handles turning and moving the object. It also includes logic for the movement lock key.
    *   `bindings_client.dm`: This file contains the core client-side logic for handling key presses. It defines the `keyDown` and `keyUp` verbs, which are called for all key press and release events. It includes anti-spam and anti-flood measures to prevent abuse. It also handles modifier keys (Alt, Ctrl, Shift) and calls the appropriate keybinding datums based on the user's preferences.
    *   `focus.dm`: This file defines the concept of "focus" for keybindings. It allows a client's keypresses to be directed to a specific datum, rather than just the player's mob. This is used for things like controlling a mech or interacting with a UI window. It defines the `set_focus` proc on mobs to change their current focus.
    *   `readme.md`: This file provides a detailed explanation of the keybinding system. It explains the rationale behind the system, how it works, and how to use it. It also includes notes about specific keys and their behavior.
    *   `setup.dm`: This file handles the setup and initialization of the keybinding system. It defines the base `/datum/proc/key_down`, `/datum/proc/key_up`, and `/datum/proc/keyLoop` procs that can be overridden by other datums to handle keypresses. It also includes the `set_macros` proc, which erases all existing macros and sets up the new keybinding system for the client.
*   **lighting**: The system that controls all lighting on the station.
    *   `lighting_area.dm`: This file defines how lighting is handled at the area level. It adds variables to the `/area` datum to control area-wide lighting effects, such as `luminosity`, `base_lighting_alpha`, and `base_lighting_color`. It includes procs to set and update the base lighting for an area, which can be used to create ambient light or darkness.
    *   `lighting_atom.dm`: This file contains the core logic for making any atom a light source. It defines the `set_light` proc, which is the main interface for setting an atom's light properties, such as range, power, color, and falloff. It also handles the creation and destruction of `/datum/light_source` objects, which are the actual emitters of light.
    *   `lighting_corner.dm`: This file defines the `/datum/lighting_corner` datum, which represents a corner of a turf where four turfs meet. The lighting system calculates the light level at each corner and then interpolates between them to create smooth lighting. This file contains the logic for updating the light level at each corner based on the light sources affecting it.
    *   `lighting_object.dm`: This file defines the `/datum/lighting_object`, which is responsible for applying the lighting underlay to a turf. Each turf with dynamic lighting has a `lighting_object` that manages its `current_underlay`. The `update` proc in this datum calculates the final color of the underlay based on the light levels of its four corners.
    *   `lighting_setup.dm`: This file contains the setup and initialization logic for the lighting system. The `create_all_lighting_objects` proc is the main entry point, which iterates through all areas and creates `lighting_object`s for turfs in areas with static lighting.
    *   `lighting_source.dm`: This file defines the `/datum/light_source` datum, which is the actual source of light in the game. Each atom that emits light has a `light_source` datum associated with it. This datum tracks the light's properties (power, range, color, etc.) and calculates its effect on the surrounding `lighting_corner`s. It uses a falloff formula to determine how the light's intensity decreases with distance.
    *   `lighting_turf.dm`: This file adds lighting-related procs and variables to the `/turf` datum. It includes procs for clearing and building the lighting overlay, getting the luminosity of a turf, and handling opacity for lighting calculations. It also defines how turfs react to being lit, and how they can block light.
    *   `static_lighting_area.dm`: This file defines areas with static, pre-calculated lighting. These areas do not have dynamic lighting objects and are therefore less performance-intensive. It includes logic for creating and removing lighting objects when an area's `static_lighting` property is changed.
*   **lootpanel**: A UI panel for viewing and managing loot.
    *   `_lootpanel.dm`: This is the main file for the loot panel system. It defines the `/datum/lootpanel` datum, which stores information about the contents of a turf. It handles opening the loot panel UI, searching the turf for items, and managing the list of found objects.
    *   `contents.dm`: This file contains the logic for populating and managing the contents of the loot panel. The `populate_contents` proc searches a turf for items and creates a `/datum/search_object` for each one. It also handles adding and removing items from the index as they are created or destroyed.
    *   `handlers.dm`: This file defines the event handlers for the loot panel. The `on_searchable_deleted` proc is called when an item in the loot panel is deleted, and it updates the UI accordingly.
    *   `misc.dm`: This file contains miscellaneous helper functions for the loot panel system. The `open` proc is used to open the loot panel for a specific turf. The `process_images` proc is called by the `ss_looting` subsystem to generate icons for the items in the loot panel.
    *   `search_object.dm`: This file defines the `/datum/search_object` datum, which is a lightweight representation of an item in the loot panel. It stores the item's name, icon, and other relevant information. This is done to avoid sending the full item data to the client, which would be slow and inefficient.
    *   `ss_looting.dm`: This file defines the `ss_looting` subsystem, which is responsible for generating the icons for the items in the loot panel in the background. This is done to avoid lagging the game when a player opens a loot panel with a large number of items.
    *   `ui.dm`: This file contains the UI-related logic for the loot panel. The `get_contents` proc converts the list of `search_object` datums into a format that can be displayed by the tgui UI. The `grab` proc is called when a player clicks on an item in the loot panel, and it handles the interaction with the item.
*   **mafia**: The Mafia game mode.
    *   `_defines.dm`: This file contains all the defines for the Mafia game mode. This includes player counts, phase timings, team names, role types, and various flags for abilities and roles.
    *   `abilities/abilities.dm`: This file defines the base `/datum/mafia_ability` datum, which is the parent for all role abilities in the game mode. It contains the core logic for validating and performing actions.
    *   `abilities/investigative/`: This folder contains abilities related to gathering information.
        *   `investigate.dm`: Defines the "Investigate" ability, which allows a player to learn the faction of another player.
        *   `pray.dm`: Defines the "Seance" ability, which allows a player to learn the role of a dead player.
        *   `reveal.dm`: Defines the "Reveal" ability, which publicly reveals the role of another player.
        *   `thoughtfeed.dm`: Defines the "Thoughtfeed" ability, which allows a player to learn the exact role of another player.
    *   `abilities/killing/`: This folder contains abilities related to killing other players.
        *   `alert.dm`: Defines the "Alert" ability, which allows a player to kill anyone who visits them during the night.
        *   `flicker_rampage.dm`: Defines the "Flicker/Rampage" ability, a two-part ability that first marks a player and then allows for a multi-kill.
        *   `kill.dm`: Defines the basic "Attack" ability, which allows a player to attempt to kill another player during the night.
    *   `abilities/protective/`: This folder contains abilities related to protecting other players.
        *   `heal.dm`: Defines the "Heal" ability, which can prevent a player from dying.
        *   `vest.dm`: Defines the "Vest" ability, which allows a player to protect themselves from an attack.
    *   `abilities/support/`: This folder contains miscellaneous support abilities.
        *   `roleblock.dm`: Defines the "Roleblock" ability, which prevents a player from using their abilities for a night.
        *   `self_reveal.dm`: Defines the "Self Reveal" ability, which allows a player to publicly reveal their role for a strategic advantage.
    *   `abilities/voting/`: This folder contains abilities related to the voting process.
        *   `changeling_kill.dm`: Defines the "Kill Vote" ability for the changeling team, allowing them to collectively decide on a target.
        *   `day_voting.dm`: Defines the basic "Vote" ability, used during the day to nominate a player for lynching.
    *   `controller.dm`: This is the main controller for the Mafia game mode. It manages the game state, including the current phase, the list of players and roles, and the voting process. It handles the entire game loop, from setup to victory checks.
    *   `map_pieces.dm`: This file defines the map-specific elements for the Mafia game mode, such as player spawns and the town center. It also defines the different map templates that can be used for the game.
    *   `outfits.dm`: This file defines the outfits for the various roles in the Mafia game mode.
    *   `roles/changelings/changeling.dm`: This file defines the basic "Changeling" role for the mafia team, as well as the "Thoughtfeeder" variant.
    *   `roles/neutral/neutral_benign.dm`: This file defines the "Fugitive" role, a neutral role that wins by surviving.
    *   `roles/neutral/neutral_chaos.dm`: This file defines the "Obsessed" and "Clown" roles, neutral roles with chaotic win conditions.
    *   `roles/neutral/neutral_killing.dm`: This file defines the "Traitor" and "Nightmare" roles, neutral roles focused on killing other players.
    *   `roles/roles.dm`: This file defines the base `/datum/mafia_role` datum, which is the parent for all roles in the game mode. It contains the core logic for roles, such as handling death, greeting players, and revealing roles.
    *   `roles/town/`: This folder contains the roles for the "Town" faction.
        *   `town_investigative.dm`: Defines the investigative town roles: "Detective", "Psychologist", and "Chaplain".
        *   `town_killing.dm`: Defines the killing town roles: "Head of Security" and "Warden".
        *   `town_protective.dm`: Defines the protective town roles: "Medical Doctor" and "Security Officer".
        *   `town_support.dm`: Defines the support town roles: "Lawyer" and "Head of Personnel".
*   **media**: The in-game media system, including the station's news network.
    *   `assets/media_player.html`: This is the basic HTML structure for the in-game media player. It's a simple HTML page that includes the JavaScript for the media player.
    *   `assets/media_player.js`: This file contains the JavaScript code for the in-game media player. It uses the Howler.js library to handle audio playback. It defines functions for playing, pausing, stopping, and seeking audio, as well as for setting the volume and position of the audio source.
    *   `media_mob_helpers.dm`: This file contains helper procs for mobs interacting with the media system. It adds variables to the `/mob` datum to track the current and available media sources. It includes procs for adding and removing media sources, and for updating the media player when the mob's media source changes.
    *   `media_player.dm`: This file defines the `/datum/media_player` datum, which represents a single client's media player. It handles communication between the BYOND server and the client's media player, sending commands to play, pause, and stop audio, and receiving events such as "ready" and "playing".
    *   `media_track.dm`: This file defines the `/datum/media_track` datum, which represents a single audio track. It contains the track's URL, title, artist, genre, and duration.
    *   `sources/_media_source.dm`: This file defines the base `/datum/media_source` datum, which is the parent for all media sources in the game. It contains the core logic for managing listeners and playing media for them.
    *   `sources/lobby_source.dm`: This file defines the `/datum/media_source/lobby` datum, which is a global media source for the lobby music.
    *   `sources/object_source.dm`: This file defines the `/datum/media_source/object` datum, which is a media source that is attached to a specific object in the game world. It handles positional audio, with the volume and panning of the audio changing based on the listener's distance and direction from the source object.
*   **modular_implants**: The system for creating and installing cybernetic implants.
    *   `misc_devices.dm`: This file defines miscellaneous devices related to modular implants, such as the "NIFSoft Remover" for removing installed software, a "NIF Repair Kit" for repairing damaged implants, and a "NIF HUD Adapter" for making regular glasses compatible with HUD software.
    *   `nif_actions.dm`: This file defines the `/datum/action/item_action/nif/open_menu` action, which is the action that players use to open the NIF management UI.
    *   `nif_implants.dm`: This file defines the different types of Nanite Implant Frameworks (NIFs) available in the game. This includes the "Standard Type NIF", the "Econo-Deck Type NIF", and the temporary "Trial-Lite Type NIF".
    *   `nif_persistence.dm`: This file handles the saving and loading of NIF data between rounds. It defines the `/datum/modular_persistence` datum, which stores the player's NIF configuration, including the installed implant, its durability, and any persistent software.
    *   `nifs_tgui.dm`: This file contains the TGUI (tg-station user interface) code for the NIF management panel. It defines the UI's layout, data bindings, and actions, allowing players to view and manage their installed NIF and software.
    *   `nifs.dm`: This is the core file for the Nanite Implant Framework system. It defines the base `/obj/item/organ/internal/cyberimp/brain/nif` object, which represents the NIF implant itself. It handles the implant's power, durability, calibration, and software management.
    *   `nifsoft_catalog.dm`: This file defines the in-game NIFSoft catalog, which is a program that can be run on a modular computer. It allows players to browse and purchase NIFSofts for their implants.
    *   `nifsofts.dm`: This file defines the base `/datum/nifsoft` datum, which is the parent for all NIF software. It contains the core logic for installing, activating, and managing NIFSofts. It also defines the `/obj/item/disk/nifsoft_uploader` item, which is used to install NIFSofts from a disk.
    *   `nifsofts/action_granter.dm`: This file defines the `/datum/nifsoft/action_granter` NIFSoft, which grants the user a new action when activated.
    *   `nifsofts/book_summoner.dm`: This file defines the "Grimoire Akasha" NIFSoft, which allows the user to summon various educational books.
    *   `nifsofts/hivemind.dm`: This file defines the "Hivemind" NIFSoft, which allows users to communicate telepathically with other users of the same software.
    *   `nifsofts/huds.dm`: This file defines various HUD (Heads-Up Display) NIFSofts, such as medical, diagnostic, and security HUDs. It also defines the `/datum/element/nifsoft_hud` which can be added to glasses to make them compatible with HUD NIFSofts.
    *   `nifsofts/money_sense.dm`: This file defines the "Automatic Appraisal" NIFSoft, which allows the user to see the monetary value of items.
    *   `nifsofts/prop_summoner.dm`: This file defines the "Grimoire Caeruleam" NIFSoft, which allows the user to summon various cosmetic or "fun" items.
    *   `nifsofts/soul_poem.dm`: This file defines the "Poem of Communal Souls" NIFSoft, which allows users to share short messages with other nearby users of the same software.
*   **movespeed**: Manages the movement speed of mobs.
    *   `_movespeed_modifier.dm`: This is the core file for the movespeed modification system. It defines the base `/datum/movespeed_modifier` datum, which is used to alter a mob's movement speed. It includes the logic for adding, removing, and updating these modifiers on a mob. It also introduces a caching system for static (non-variable) modifiers to improve performance.
    *   `modifiers/components.dm`: This file contains movespeed modifiers that are applied by or related to components. This includes a slowdown for being a snail, a speedup for being tenacious, and a modifier based on sanity.
    *   `modifiers/drugs.dm`: This file defines movespeed modifiers caused by various drugs. For example, it includes a modifier for stimulants that increases movement speed.
    *   `modifiers/innate.dm`: This file contains innate movespeed modifiers for certain mobs or situations. This includes a slowdown for strained muscles and a speedup for the DNA vault.
    *   `modifiers/items.dm`: This file defines movespeed modifiers that are applied by worn or held items. This includes a speed boost from jetpacks and a slowdown from carrying a bulky belt satchel.
    *   `modifiers/misc.dm`: This file contains miscellaneous movespeed modifiers that don't fit into other categories. This includes a modifier for admin-var-edited speed and a speed boost from a "yellow orb".
    *   `modifiers/mobs.dm`: This file defines movespeed modifiers that are specific to certain mobs or mob states. This includes slowdowns for obesity, being grabbed, and crawling, as well as speed boosts for certain mob-specific abilities.
    *   `modifiers/reagent.dm`: This file contains movespeed modifiers that are applied by reagents. This includes speed boosts from stimulants and methamphetamine, and slowdowns from pepper spray and cannabis.
    *   `modifiers/status_effects.dm`: This file defines movespeed modifiers that are applied by various status effects. This includes slowdowns from "bloodchill" and "bonechill", and a speed boost from "lightpink".
*   **NTNet**: The in-game internet and network system.
    *   `relays.dm`: This file defines the NTNet Quantum Relay, which is the backbone of the in-game internet (NTNet). It defines the `/obj/machinery/ntnet_relay` object, which acts as a router and transmitter for the network. The file includes logic for enabling and disabling the relay, handling power, and simulating Denial of Service (DoS) attacks. The `find_functional_ntnet_relay` proc is used to check if the NTNet is online by verifying that at least one relay is operational.
*   **plumbing**: The system for plumbing and fluid distribution.
    *   `ducts.dm`: This file defines the `/obj/machinery/duct` object, which is the basic building block of the plumbing system. It handles the connection of ducts to each other and to other plumbing machinery, forming a `ductnet`. It also defines the `/obj/item/stack/ducts` item, which is used to build ducts.
    *   `plumbers/_plumb_machinery.dm`: This file defines the base `/obj/machinery/plumbing` object, which is the parent for all plumbing machinery. It contains common variables and procs for plumbing machines, such as power usage, reagent handling, and deconstruction.
    *   `plumbers/acclimator.dm`: This file defines the `/obj/machinery/plumbing/acclimator`, a machine that can heat or cool chemicals to a specific temperature.
    *   `plumbers/bottler.dm`: This file defines the `/obj/machinery/plumbing/bottler`, a machine that can bottle reagents from the plumbing network into containers.
    *   `plumbers/destroyer.dm`: This file defines the `/obj/machinery/plumbing/disposer`, a machine that destroys chemicals.
    *   `plumbers/fermenter.dm`: This file defines the `/obj/machinery/plumbing/fermenter`, a machine that can ferment plants into alcoholic beverages.
    *   `plumbers/filter.dm`: This file defines the `/obj/machinery/plumbing/filter`, a machine that can filter specific chemicals from a mixture.
    *   `plumbers/grinder_chemical.dm`: This file defines the `/obj/machinery/plumbing/grinder_chemical`, a machine that can grind items into chemicals.
    *   `plumbers/pill_press.dm`: This file defines the `/obj/machinery/plumbing/pill_press`, a machine that can create pills, patches, and tubes from reagents.
    *   `plumbers/plumbing_buffer.dm`: This file defines the `/obj/machinery/plumbing/buffer`, a machine that acts as a buffer in a plumbing network, waiting for other buffers to be ready before releasing its contents.
    *   `plumbers/pumps.dm`: This file defines the `/obj/machinery/plumbing/liquid_pump`, a machine that can pump liquids from geysers into the plumbing network.
    *   `plumbers/reaction_chamber.dm`: This file defines the `/obj/machinery/plumbing/reaction_chamber`, a machine that can mix chemicals and trigger reactions. It also defines a `chem` subtype that can use acid and base buffers.
    *   `plumbers/splitters.dm`: This file defines the `/obj/machinery/plumbing/splitter`, a machine that can split a stream of chemicals into two outputs based on a configurable ratio.
    *   `plumbers/synthesizer.dm`: This file defines the `/obj/machinery/plumbing/synthesizer`, a machine that can produce a single chemical. It also defines `soda` and `beer` subtypes for producing specific beverages.
    *   `plumbers/teleporter.dm`: This file defines a bluespace-based chemical teleportation system, consisting of a `/obj/machinery/plumbing/sender` and a `/obj/machinery/plumbing/receiver`.
*   **point**: A system for awarding and spending points.
    *   `point.dm`: This file implements the "point at" action, which allows mobs to point at other atoms (mobs, objects, or turfs). It defines the `/atom/movable/proc/point_at` proc, which creates a visual effect of an arrow pointing from the source atom to the target atom. It also defines the `/mob/verb/pointed` verb, which is what players actually use to initiate the pointing action. The file also handles the creation of a "thought bubble" when pointing at an object inside a container.
*   **procedural_mapping**: The system for generating maps procedurally.
    *   `mapGenerator.dm`: This file defines the base `/datum/map_generator` datum, which is the core of the procedural map generation system. It manages a list of `mapGeneratorModule` datums and orchestrates the map generation process by calling their `generate` procs. It also includes helper procs for defining the region to be generated, and a debug verb for testing map generators.
    *   `mapGeneratorModule.dm`: This file defines the base `/datum/map_generator_module` datum. Each module is responsible for a specific part of the map generation, such as placing turfs or spawning atoms. It contains variables for controlling the placement of atoms and turfs, including spawn probabilities and clustering rules.
    *   `mapGeneratorModules/helpers.dm`: This file contains helper modules for the map generation system. This includes a `repressurize` module to fill an area with air, a `massdelete` module to clear an area of all objects and turfs, and a `border` module to place atoms or turfs only on the borders of an area.
    *   `mapGeneratorModules/nature.dm`: This file contains modules for generating natural environments. It includes modules for spawning pine trees, dead trees, random bushes, rocks, and grass.
    *   `mapGenerators/asteroid.dm`: This file defines map generators for creating asteroids. It includes generators for hollow asteroids, asteroids with scattered walls, and asteroids with monsters.
    *   `mapGenerators/cellular.dm`: This file defines a map generator that uses a cellular automaton to create cave-like structures. It includes a `caves` generator for creating volcanic caves and a `maze` generator for creating mazes.
    *   `mapGenerators/cult.dm`: This file defines map generators for creating cult-themed rooms, with cult floors and walls.
    *   `mapGenerators/lava_river.dm`: This file defines a map generator for creating lava rivers.
    *   `mapGenerators/lavaland.dm`: This file defines map generators for creating lavaland environments. It includes modules for spawning lavaland-specific turfs, ores, monsters, and tendrils.
    *   `mapGenerators/nature.dm`: This file defines a map generator for creating natural, outdoor environments, combining several of the modules from `mapGeneratorModules/nature.dm`.
    *   `mapGenerators/repair.dm`: This file defines map generators for repairing or modifying existing areas. It includes a generator for replacing floors, a generator for enclosing a room with walls, and a generator for reloading a portion of the station map from its original map file.
    *   `mapGenerators/shuttle.dm`: This file defines map generators for creating shuttle-themed rooms, with shuttle floors and walls.
    *   `mapGenerators/syndicate.dm`: This file defines map generators for creating syndicate-themed rooms, including furniture and mobs.
    *   `README.md`: This file provides documentation for the procedural mapping system, explaining how to use the `mapGenerator` and `mapGeneratorModule` datums to create new procedural maps.
*   **projectiles**: The physics and behavior of all projectiles.
    *   `gun.dm`: This file defines the base `/obj/item/gun` object, which is the parent for all firearms in the game. It contains the core logic for firing, reloading, and handling ammunition. It also includes variables for gun properties such as fire rate, recoil, and spread.
    *   `pins.dm`: This file defines the `/obj/item/firing_pin` object, which is a component that can be inserted into a gun to allow it to fire. It includes different types of firing pins, such as DNA-locked pins, implant-keyed pins, and clown pins with special effects.
    *   `projectile.dm`: This file defines the base `/obj/projectile` object, which is the parent for all projectiles in the game. It contains the core logic for projectile movement, impact, and damage. It also includes variables for projectile properties such as speed, range, and damage type.
    *   `ammunition/`: This directory contains the definitions for different types of ammunition.
        *   `_ammunition.dm`: This file defines the base `/obj/item/ammo_casing` object, which represents a single round of ammunition.
        *   `_firing.dm`: This file contains the core logic for firing a projectile from a casing.
        *   `ballistic/`: This subdirectory contains definitions for various types of ballistic ammunition, such as pistol, rifle, and shotgun rounds.
        *   `caseless/`: This subdirectory contains definitions for caseless ammunition, such as energy cells and foam darts.
        *   `energy/`: This subdirectory contains definitions for energy-based ammunition, such as lasers and plasma bolts.
        *   `special/`: This subdirectory contains definitions for special ammunition types, such as magic spells and syringes.
*   **recycling**: The system for recycling items and materials. This module includes conveyor belts, the pneumatic disposal system, and sorting machinery.
    *   `conveyor.dm`: Implements conveyor belts (`/obj/machinery/conveyor`) and switches (`/obj/machinery/conveyor_switch`). Conveyors can be turned on/off, reversed, and linked together with an ID system.
    *   `sortingmachinery.dm`: Defines `delivery` packages, which can be wrapped, tagged with a destination, and sent through the disposal system. It also defines the `destination tagger` item.
    *   `disposal/`: This subdirectory contains the core of the pneumatic disposal system.
        *   `bin.dm`: Defines the main disposal units (`/obj/machinery/disposal/bin`) and delivery chutes (`/obj/machinery/disposal/delivery_chute`), which are the entry points to the system.
        *   `pipe.dm`: Defines the various types of disposal pipes (`/obj/structure/disposalpipe`) that form the transport network.
        *   `holder.dm`: Defines the `disposalholder` object, a virtual container that travels through the pipes, carrying the flushed items.
        *   `outlet.dm`: Defines the `disposaloutlet`, the exit point of the disposal system.
        *   `pipe_sorting.dm`: Implements sorting pipes that can divert `disposalholder` objects based on their contents or tags.
        *   `construction.dm`: Defines the `disposalconstruct` objects used to build the disposal system.
        *   `multiz.dm`: Implements multi-z-level disposal pipes.
        *   `eject.dm`: Contains a helper proc for ejecting items from the disposal system.
*   **requests**: A system for players to make requests to different departments or to admins. This includes prayers, Centcom messages, and nuke code requests.
    *   `request.dm`: Defines the base `/datum/request` object, which represents a single request.
    *   `request_manager.dm`: Defines the global `request_manager` datum, which handles all player requests. It includes a TGUI for admins to view and manage requests.
*   **shuttle**: The code for all shuttles, including the emergency shuttle and department shuttles. This is a complex module that handles shuttle movement, docking, and events.
    *   `shuttle.dm`: Contains the core logic for docking ports, both mobile (`/obj/docking_port/mobile`) and stationary (`/obj/docking_port/stationary`).
    *   `docking.dm`: Defines the `initiate_docking` proc, which handles the complex process of moving a shuttle from one dock to another.
    *   `on_move.dm`: Contains all the `onShuttleMove`, `beforeShuttleMove`, and `afterShuttleMove` procs for various atoms, defining how they behave when a shuttle moves.
    *   `emergency.dm`: Implements the emergency shuttle, including the logic for calling, recalling, and launching the shuttle at the end of the round. It also includes the system for authorizing an early launch and for hijacking the shuttle.
    *   `arrivals.dm`: Defines the arrivals shuttle, which is used for late-joining players.
    *   `supply.dm`: Implements the cargo shuttle, which is used for ordering and selling goods. It includes logic for buying supplies from a shopping list and selling exported items.
    *   `computer.dm`: Defines the base shuttle control console (`/obj/machinery/computer/shuttle`).
    *   `navigation_computer.dm`: Defines an advanced navigation computer that allows for designating custom docking locations.
    *   `shuttle_events/`: A subdirectory for events that can occur during shuttle travel.
        *   `_shuttle_events.dm`: The base datum for shuttle events.
        *   `turbulence.dm`: Simulates turbulence, which can knock down unbuckled players.
        *   `carp.dm`, `meteors.dm`, `misc.dm`, `player_controlled.dm`: Various events that can spawn objects or mobs that interact with the shuttle.
    *   Other files in this module define specific types of shuttles, such as the `ferry`, `infiltrator`, `assault_pod`, and various escape pods.
*   **spatial_grid**: A system for dividing the map into a grid for various calculations.
    *   `cell_tracker.dm`: Defines a datum for tracking cells in a spatial grid, used to optimize range-based searches and make repeated "everything in range" checks faster.
*   **station_goals**: A system for setting and tracking station-wide goals.
    *   `station_goal.dm`: Defines the base `station_goal` datum.
    *   `bsa.dm`: Implements the Bluespace Artillery goal, which requires the crew to build and fire a large cannon.
    *   `budget.dm`: Implements a budget goal, requiring the station to have a certain amount of credits.
    *   `dna_vault.dm`: Implements the DNA Vault goal, which requires collecting DNA from various sources.
    *   `meteor_shield.dm`: Implements the Meteor Shield goal, which requires deploying a network of satellites to protect the station.
    *   `vault_mutation.dm`: Defines the mutations that can be gained from the DNA vault.
*   **tgchat**: The integration with the TG-Chat service.
    *   `to_chat.dm`: Contains the core `to_chat` proc for sending messages to clients.
    *   `message.dm`: Defines the message format for tgchat.
    *   `README.md`: Explains the internals of the tgchat system.
*   **tgs**: The /tg/station-specific systems and modifications, primarily the DMAPI for communication with the TGS server.
    *   `core/`: Contains the core DMAPI code, including the API datum and versioning.
    *   `v3210/`, `v4/`, `v5/`: Implementations of different versions of the DMAPI.
    *   `includes.dm`: Includes all the necessary files for the TGS API.
*   **tgui_input**: Handles input from tgui windows, providing a set of procs for creating various input modals.
    *   `alert.dm`: Defines `tgui_alert` for simple confirmation windows.
    *   `checkboxes.dm`: Defines `tgui_input_checkboxes` for selecting multiple options.
    *   `color.dm`: Defines `tgui_color_picker` for selecting a color.
    *   `keycombo.dm`: Defines `tgui_input_keycombo` for capturing key combinations.
    *   `list.dm`: Defines `tgui_input_list` for selecting from a list of options.
    *   `number.dm`: Defines `tgui_input_number` for number input.
    *   `text.dm`: Defines `tgui_input_text` for text input.
    *   `say_modal/`: Contains the implementation of the TGUI-based say/chat input window.
*   **tgui_panel**: The main tgui panel that hosts the UI.
    *   `tgui_panel.dm`: The core `tgui_panel` datum that manages the main TGUI window.
    *   `audio.dm`: Handles playing music and sounds through the TGUI panel.
    *   `external.dm`: Provides a verb for fixing the TGUI panel if it breaks.
    *   `telemetry.dm`: Handles collecting telemetry data from the client.
*   **tooltip**: The system for displaying tooltips when hovering over objects.
    *   `tooltip.dm`: Defines the `tooltip` datum and the `show` and `hide` procs.
    *   `tooltip.html`: The HTML and JavaScript for the tooltip UI.
*   **tutorials**: The in-game tutorial system.
    *   `_tutorial.dm`: Defines the base `tutorial` datum and the `tutorial_manager`.
    *   `tutorial_instruction.dm`, `tutorial_skip.dm`: UI elements for the tutorial.
    *   `tutorials/`: Contains the implementation of specific tutorials, like how to drop items or switch hands.
*   **unit_tests**: The framework for running automated unit tests. This is a very large module containing hundreds of tests for various game mechanics, from combat and surgery to atmospherics and reagents.
    *   `_unit_tests.dm`: The core of the unit testing framework, defining the `unit_test` datum and the test runner.
    *   The other files are individual tests for specific parts of the codebase.
    *   `screenshots/`: Contains reference screenshots for visual regression testing.
*   **visuals**: Handles visual effects like explosions, particles, and animations.
    *   `render_steps.dm`: Defines `render_step` atoms, which are used to apply visual modifications to other atoms, such as color changes and emissive effects.
*   **vox**: The system for the Vox race, including their unique language and physiology. This module also contains the VOX speech system.
    *   `vox_holder.dm`: Defines the `vox_holder` datum, which manages the VOX announcements.
    *   `vox_voice.dm`: Defines the base `vox_voice` datum.
    *   `voices/`: Contains different voice packs for the VOX system, such as the default female voice, and voices from Half-Life and its mod Blue Shift.
*   **wiremod**: A system for wiring and logic gates.
*   **zombie**: The zombie infection game mode.
    *   `zombie.dm`: Defines the zombie infection, how it spreads, and the effects of being a zombie.
    *   `leader.dm`: Defines the zombie leader and their special abilities.

## Monkestation Module Index

This section provides a comprehensive list of all modules in the `/monkestation/code/modules` directory, which are specific to the Monkestation fork.

*   **_nightmare**: Appears to be a new game mode or event with a horror theme.
    *   `nightmare_equipment.dm`: Defines the `light_eater` item, which seems to be a tool for nightmares that can snuff out lights and pry open doors.
    *   `nightmare_organs.dm`: Defines a special `nightmare` brain that can heal wounds in the dark.
*   **_paperwork**: Overrides and extends the base paperwork system.
    *   `paper_premade.dm`: Defines several pre-written paper objects, including a "Contractor Guide" for a new antagonist role, and several lore documents related to the station's engineering systems on a specific map (boxstation).
*   **a_medical_day**: Likely a scenario or event focused on the medical department.
    *   `internal_bleeding.dm`: Defines a new wound type for internal bleeding, which causes gradual blood loss.
    *   `lungless.dm`: Defines a status effect for mobs without lungs, causing them to take oxygen damage.
    *   `surgery.dm`: Defines new surgery steps for repairing internal bleeding and fractured ribs.
    *   `thermics.dm`: Defines status effects for hypo and hyperthermia, which affect consciousness and movement speed.
*   **a_ship_in_need_of_breaking**: A scenario or mission involving ship destruction.
    *   `code/controllers/subsystem/mapping.dm`: Manages the map templates for the ships that can be broken.
    *   `machines/console.dm`: Defines the shipbreaking console, which is used to spawn and manage the ships to be broken.
    *   `machines/recycler.dm`: Defines a ship recycler machine that processes scrap for credits.
    *   `tool/raynewelder.dm`: A special welder for shipbreaking.
    *   `tool/sledgehammer.dm`: A sledgehammer tool for breaking ship parts.
    *   `area.dm`: Defines the shipbreak zone area.
    *   `scrap.dm`: Defines the different types of scrap that can be obtained from shipbreaking.
    *   `ships.dm`: Defines the different ship map templates that can be spawned for shipbreaking.
*   **abberant_organs**: Adds new, unusual types of organs with special properties.
    *   `organ_process.dm`: Defines the processing subsystem for aberrant organs.
    *   `components/abberant_organ.dm`: Defines the core component for aberrant organs, which manages triggers, processes, and outcomes.
    *   `custom_organs/drunkards_liver.dm`: An example of a custom organ, a "drunkard's liver" that converts reagents.
    *   `triggers/`: Defines the conditions that trigger the organ's special effects, such as chemical consumption or a timed process.
    *   `processes/`: Defines the effects that happen when an organ is triggered, such as reagent conversion.
    *   `outcomes/`: Defines the final result or outcome of an organ's process.
    *   `traits/`: Defines special traits that can be added to an organ.
*   **admin**: Overrides the base `admin` module.
*   **aesthetics**: Adds new visual and aesthetic options.
*   **and_roll_credits**: A system for displaying game credits.
*   **antagonists**: Overrides the base `antagonists` module.
*   **antimatter**: Adds an antimatter engine or power source.
*   **art_sci_overrides**: Overrides for the art and science systems.
*   **assault_ops**: A game mode or event focused on a combat operation.
*   **assembly**: Overrides the base `assembly` module.
*   **asset_cache**: Overrides the base `asset_cache` module.
*   **atmospherics**: Overrides the base `atmospherics` module.
*   **balloon_alert**: Overrides the base `balloon_alert` module.
*   **ballpit**: Adds a ballpit.
*   **bitrunners**: Overrides the base `bitrunning` module.
*   **blood_datum**: Adds a new datum for blood.
*   **blood_for_the_blood_gods**: A new event or game mode, likely related to the "blood god" meme.
*   **bloodsuckers**: Adds bloodsucking creatures or antagonists.
*   **blueshield**: Adds the "Blueshield" security role.
*   **blueshift**: A new game mode or event, possibly related to the Half-Life concept.
*   **botany**: Overrides the base `hydroponics` module.
*   **brewin_and_chewin**: Adds new brewing and chewing mechanics.
*   **bunny_wizard**: A new wizard type.
*   **can_spessmen_feel_pain**: A new system or event related to mob pain.
*   **cargo**: Overrides the base `cargo` module.
*   **cargoborg**: Adds a cargoborg role.
*   **cassettes**: Adds cassette tapes and players.
*   **client**: Overrides the base `client` module.
*   **clothing**: Overrides the base `clothing` module.
*   **code_redemption**: A system for redeeming codes for in-game items.
*   **coin-events**: Events related to a in-game currency.
*   **conveyor**: Adds conveyor belts.
*   **conveyor_sorter**: Adds a machine for sorting items on a conveyor belt.
*   **cryopods**: A new system for cryopods.
*   **cybernetics**: A new system for cybernetics.
*   **datums**: Overrides the base `datums` module.
*   **displacement**: Adds a displacement mechanic.
*   **divine_warning**: A system for divine warnings.
*   **donator**: A system for donator perks.
*   **emotes**: Overrides the base `emote_panel` module.
*   **ERT**: A new system for ERT.
*   **events**: Overrides the base `events` module.
*   **experisci**: Overrides the base `experisci` module.
*   **factory_type_beat**: A new system for factory production.
*   **flavor_text**: Overrides the base `flufftext` module.
*   **floorsigns**: Adds signs that can be placed on the floor.
*   **food_and_drinks**: Overrides the base `food_and_drinks` module.
*   **get_off_my_lawn**: A new event or game mode.
*   **ghost_critters**: Adds critters that can be controlled by ghosts.
*   **ghost_players**: Adds new abilities for ghost players.
*   **goonimizations**: Adds animations from Goonstation.
*   **hallucination**: Overrides the base `hallucination` module.
*   **holomaps**: Adds holographic maps.
*   **hydroponics**: Overrides the base `hydroponics` module.
*   **indicators**: Overrides the base `indicators` module.
*   **industrial_lift**: Overrides the base `industrial_lift` module.
*   **interview**: Overrides the base `interview` module.
*   **job_xp**: A system for gaining experience in a specific job.
*   **jobs**: Overrides the base `jobs` module.
*   **language**: Overrides the base `language` module.
*   **library**: Overrides the base `library` module.
*   **liquids**: Adds new liquids.
*   **loadouts**: A system for custom loadouts.
*   **loafing**: A system for "loafing" or being idle.
*   **logging**: Overrides the base `logging` module.
*   **machining**: A new system for machining.
*   **map_gen_expansions**: Adds new map generation expansions.
*   **mapfluff**: Overrides the base `mapfluff` module.
*   **mapping**: Overrides the base `mapping` module.
*   **maptext**: Adds text that can be placed on the map.
*   **martial_arts**: Adds martial arts.
*   **mech_comp**: A new system for mech computers.
*   **mentor**: Overrides the base `mentor` module.
*   **meteor_shield**: Adds a shield to protect the station from meteors.
*   **meteors**: Overrides the base `meteors` module.
*   **microfusion**: Adds a microfusion power source.
*   **mining**: Overrides the base `mining` module.
*   **mob**: Overrides the base `mob` module.
*   **mob_spawn**: Overrides the base `mob_spawn` module.
*   **mod**: Overrides the base `mod` module.
*   **modular_bartending**: A new system for modular bartending.
*   **modular_computers**: Overrides the base `modular_computers` module.
*   **modular_guns**: A new system for modular guns.
*   **NTrep**: A new system for NT representatives.
*   **NTSL**: A new system for NTSL.
*   **ocean_content**: Adds ocean-related content.
*   **oldstation_idconsole**: Adds an old station ID console.
*   **out_of_game_assets**: A system for managing assets outside of the game.
*   **outdoors**: Adds new outdoor environments.
*   **overwatch**: A system for overwatch and observation.
*   **pai**: Overrides the base `pai` module.
*   **paperwork**: Overrides the base `paperwork` module.
*   **paradise_ports**: Ports of features from Paradise Station.
*   **patches_if_they_were_cool**: A collection of cool patches.
*   **photography**: Overrides the base `photography` module.
*   **physics**: A new system for physics.
*   **pissing**: Adds a pissing mechanic.
*   **pollution**: A system for pollution and environmental effects.
*   **pools**: Adds pools.
*   **possession**: A system for possession and ghosts.
*   **power**: Overrides the base `power` module.
*   **ranching**: A system for ranching and animal husbandry.
*   **random_rooms**: A system for generating random rooms.
*   **reagents**: Overrides the base `reagents` module.
*   **religion**: Overrides the base `religion` module.
*   **replays**: A system for recording and playing back game replays.
*   **research**: Overrides the base `research` module.
*   **security**: Overrides the base `security_levels` module.
*   **shelves**: Adds new types of shelves.
*   **signboards**: Adds new types of signboards.
*   **skyrat_snipes**: A collection of snipes from Skyrat station.
*   **slash_commands**: Adds new slash commands.
*   **slimecore**: A new system for slime cores.
*   **smithing**: A system for smithing and metalworking.
*   **spells**: Overrides the base `spells` module.
*   **store**: A system for an in-game store.
*   **storytellers**: A system for storytellers to create and manage events.
*   **surgery**: Overrides the base `surgery` module.
*   **syndicate_ghostroles**: Adds new ghost roles for the syndicate.
*   **temperature_overhaul**: An overhaul of the temperature system.
*   **tgui**: Overrides the base `tgui` module.
*   **the_bird_inside_of_me**: A new event or game mode.
*   **the_fabled_dna_changes**: A new system for DNA changes.
*   **the_wolf_inside_of_me**: A new event or game mode.
*   **trading**: A system for trading between players.
*   **twitch_bits**: Integration with Twitch bits.
*   **uplink**: Overrides the base `uplink` module.
*   **vehicles**: Overrides the base `vehicles` module.
*   **vending**: Overrides the base `vending` module.
*   **veth_misc_items**: A collection of miscellaneous items from Veth.
*   **viking**: A new viking-themed event or game mode.
*   **virology**: A new system for virology.
*   **visual_changes**: A collection of visual changes.
*   **wiki_templater**: A tool for templating wiki pages.
*   **wiremod_chem**: A system for wiremod chemistry.
