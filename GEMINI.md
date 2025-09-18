# Project Overview

This is the codebase for Monkestation, a fork of the popular Space Station 13 game. The project is built using the BYOND engine and its proprietary language, Dream Maker (DM). The game is a round-based roleplaying game set on a space station, filled with paranoia and sci-fi elements.

The project is a fork of the /tg/station codebase and has its own set of modifications and features. The codebase is actively maintained and has a dedicated community.

## Building and Running

The project has a specific build process that needs to be followed. Building the project directly in Dream Maker is deprecated and might cause errors.

### Quick Start

The easiest way to get the server running is to use the provided batch script:

1.  Find the `bin/server.cmd` file in the root directory.
2.  Double-click the file to automatically build and host the server on port 1337.

### Manual Build

For a more controlled build process, you can use the `build.cmd` script:

1.  Find the `bin/build.cmd` file in the root directory.
2.  Double-click the file to initiate the build process. This might take a few minutes.
3.  Once the build is complete, you can run the server by opening the `tgstation.dmb` file in DreamDaemon.

### VSCode and other build options

For more advanced build options, including compiling in VSCode, refer to the documentation in `tools/build/README.md`.

## Development Conventions

The project has a set of coding guidelines and contribution rules that should be followed.

*   **Coding Guidelines:** The coding guidelines can be found on [HackMD](https://hackmd.io/@MonkestationPooba/code_guidelines).
*   **Contributing:** The contributing guide is located in the `.github/CONTRIBUTING.md` file. It provides information on how to contribute to the project, including pull request guidelines and code of conduct.
*   **Git Hooks:** The project uses git hooks to enforce commit message formatting. Make sure to install them by running `git config core.hooksPath .githooks`.

## Key Files

*   `tgstation.dme`: The main project file for the Dream Maker environment. It includes all the necessary files for the game.
*   `code/`: This directory contains the majority of the game's source code, written in Dream Maker.
*   `interface/`: This directory contains the UI-related files, including the game's skin and stylesheets.
*   `_maps/`: This directory contains the game's maps.
*   `tgui/`: This directory contains the source code for the tgui library, a UI library used in the game.
*   `tools/`: This directory contains various tools for development, including build scripts and map editors.
*   `config/`: This directory contains the server configuration files.
*   `html/`: This directory contains the HTML, CSS and JS files used for the in-game browser and other UI elements.
