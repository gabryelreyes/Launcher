# Launcher for Webots Projects

This project takes over the coordination and process-spawning of the simulation robots and other applications related to the [RadonUlzer](https://github.com/BlueAndi/RadonUlzer) and [DroidControlShip](https://github.com/BlueAndi/DroidControlShip) projects.

## Usage

The Launch Script requires at least 3 arguments: Number of Robots, name of RadonUlzer's Environment, and the name of DroidControlShip's Environment. Optionally is possible to pass the IP Address of a remote Webots instance if needed.

Examples:

```batch
.\launch.bat 4 RemoteControlSim RemoteControlSim
```

```batch
.\launch.bat 1 LineFollowerSim RemoteControlSim "192.168.0.1"
```

## Structure

The following tree shows the basic structure and the most important files regarding this project:

```text
Launcher
├───DroidControlShip
│   └───.pio
│       └───build
│           └───RemoteControlSim
│               └─── program.exe
├───RadonUlzer
│   └───.pio
│       └───build
│           └───RemoteControlSim
│               └─── program.exe
├───webots
│   ├───protos
│   └───worlds
├─── .gitmodules
├─── launcher.bat
└─── launcher.sh
```

The executable of each project is found under the path: `%PROJECT_NAME%\.pio\build\%ENNVIRONMENT_NAME%\program.exe`

The `webots` folder contains the Webots files for the simulation environment.

The `.gitmodules` file defines the aforementioned projects als Git Submodules.
Make sure to clone the submodules when cloning this reposiory:

```bash
git clone --recurse-submodules https://github.com/gabryelreyes/Launcher
```

The launcher scripts are spawn the application instances according to the parameters passed in the command line. This script is available for Windows and Linux.

## Docker

A `docker-compose.yml` file can be found under the `docker` folder. This file can be used to spawn a stack of useful tools such as a MQTT Broker and a Database. These tools have been partially configured to work with each other, but can be adapted to fit the requirements of the user.

To start the services, use the following command from inside the `docker` folder:

```batch
docker-compose -p launcher up -d
```
