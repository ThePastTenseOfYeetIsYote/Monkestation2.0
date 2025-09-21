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
*   **holodeck**: The holodeck and its various programs.
*   **instruments**: Playable musical instruments.
*   **keybindings**: Manages custom keybindings for players.
*   **lighting**: The system that controls all lighting on the station.
*   **lootpanel**: A UI panel for viewing and managing loot.
*   **mafia**: The Mafia game mode.
*   **media**: The in-game media system, including the station's news network.
*   **modular_implants**: The system for creating and installing cybernetic implants.
*   **movespeed**: Manages the movement speed of mobs.
*   **NTNet**: The in-game internet and network system.
*   **plumbing**: The system for plumbing and fluid distribution.
*   **point**: A system for awarding and spending points.
*   **procedural_mapping**: The system for generating maps procedurally.
*   **projectiles**: The physics and behavior of all projectiles.
*   **recycling**: The system for recycling items and materials.
*   **requests**: A system for players to make requests to different departments.
*   **shuttle**: The code for all shuttles, including the emergency shuttle and department shuttles.
*   **spatial_grid**: A system for dividing the map into a grid for various calculations.
*   **station_goals**: A system for setting and tracking station-wide goals.
*   **tgchat**: The integration with the TG-Chat service.
*   **tgs**: The /tg/station-specific systems and modifications.
*   **tgui_input**: Handles input from tgui windows.
*   **tgui_panel**: The main tgui panel that hosts the UI.
*   **tooltip**: The system for displaying tooltips when hovering over objects.
*   **tutorials**: The in-game tutorial system.
*   **unit_tests**: The framework for running automated unit tests.
*   **visuals**: Handles visual effects like explosions, particles, and animations.
*   **vox**: The system for the Vox race, including their unique language and physiology.
*   **wiremod**: A system for wiring and logic gates.
*   **zombie**: The zombie infection game mode.

## Monkestation Module Index

This section provides a comprehensive list of all modules in the `/monkestation/code/modules` directory, which are specific to the Monkestation fork.

*   **_nightmare**: Appears to be a new game mode or event with a horror theme.
*   **_paperwork**: Overrides and extends the base paperwork system.
*   **a_medical_day**: Likely a scenario or event focused on the medical department.
*   **a_ship_in_need_of_breaking**: A scenario or mission involving ship destruction.
*   **abberant_organs**: Adds new, unusual types of organs.
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
