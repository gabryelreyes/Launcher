# Launcher for Webots Projects

This project takes over the coordination and process-spawning of the simulation robots and other applications related to the [RadonUlzer](https://github.com/BlueAndi/RadonUlzer) and [DroidControlShip](https://github.com/BlueAndi/DroidControlShip) projects.

![deployment](http://www.plantuml.com/plantuml/proxy?cache=no&src=https://raw.githubusercontent.com/gabryelreyes/Launcher/master/doc/uml/deployment.puml)

## Usage

The Launch Script requires at least 5 arguments: Number of Robots, name of RadonUlzer's Environment, name of DroidControlShip's Environment, path to the Webots world to open, and `clean` or `noclean` if the projects should clean all intermediate files before running. Optionally is possible to pass the IP Address of a remote Webots instance if needed.

Examples:

```batch
.\launch.bat 4 RemoteControlSim RemoteControlSim webots\worlds\RemoteControl.wbt noclean
```

```batch
.\launch.bat 1 LineFollowerSim RemoteControlSim webots\worlds\LineFollower.wbt clean "192.168.0.1"
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

The `.gitmodules` file defines the aforementioned projects as Git Submodules.
Make sure to clone the submodules when cloning this repository:

```bash
git clone --recurse-submodules https://github.com/gabryelreyes/Launcher
```

The launcher scripts are spawn the application instances according to the parameters passed in the command line. This script is available for Windows and Linux.

## Docker

A `docker-compose.yml` file can be found under the `docker` folder. This file can be used to spawn a stack of useful tools such as a MQTT Broker and a Database. These tools have been partially configured to work with each other, but can be adapted to fit the requirements of the user.

To start the services, use the following command from inside the `docker` folder:

```batch
docker-compose -p launcher -f docker/docker-compose.yml up -d
```

### Mosquitto MQTT Broker

- Opened ports: 1883 (Default MQTT Port)
- Port 8883 (SSL) is opened but not configured.
- Hostname: MQTT_Broker

### Node-Red

- Webview in port 1880

### InfluxDB Database

- Webview in port 8086
- Username: admin
- Password: admin12345
- Data Retention: 1 Week. Data older than one week will be deleted. Take this into account for your projects!
- Maximum time resolution of 1 second.

### Grafana

- Webview in port 3000
- Connection to InfluxDB is already established. Can be used to run queries directly with the Flux language.
- Maximum time resolution of 1 minute.

## Monitor (Python)

A monitoring/intermediate script has been written in Python. The main objective is to subscribe to topics from the MQTT Broker and send them to the InfluxDB database.
This script is provided the default configuration, and should work "out-of-the-box" once the dependencies in the `requirements.txt` file are installed.

Using a virtual environment is also suggested.

```batch
cd Monitor
python -m venv venv
./venv/bin/activate
pip install -r requirements.txt
python __main__.py
```
