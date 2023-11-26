@echo off
rem Launcher of multiple Controllers for RadonUlzer and DroidControlShip
rem Author: Gabryel Reyes (gabryelrdiaz@gmail.com)

SETLOCAL EnableDelayedExpansion

rem ==== CONSTANTS ====
set LAUNCHER=%WEBOTS_HOME%\msys64\mingw64\bin\webots-controller.exe
set WEBOTS_EXE=%WEBOTS_HOME%\msys64\mingw64\bin\webots.exe
set PIO_EXE=%USERPROFILE%\.platformio\penv\Scripts\pio.exe
set RU_PROJECT=RadonUlzer
set DCS_PROJECT=DroidControlShip
set BASE_PORT=65432
set BASE_NAME=zumo
set DEFAULT_IP_ADDRESS=localhost
set IP_ADDRESS=%DEFAULT_IP_ADDRESS%

rem ==== CHECK ARGUMENTS ====
if ["%~1"]==[""] goto usage
if ["%~2"]==[""] goto usage
if ["%~3"]==[""] goto usage
if ["%~4"]==[""] goto usage
if ["%~5"]==[""] goto usage

rem ==== CHECK IP ADDRESS ====
if not ["%~6"]==[""] (
    set IP_ADDRESS=%6
)

rem ==== CHECK DOCKER CONTAINER ====
for /f %%i in ('docker ps -qf "name=^MQTT_Broker"') do set containerId=%%i

if "%containerId%" == "" (
    rem If the container does not exist, create it
    docker-compose -p launcher down
    docker-compose -p launcher -f docker/docker-compose.yml up -d
)

rem N_ROBOTS starts with 0, so we need to subtract 1 from the argument
set /a N_ROBOTS=%1-1

rem RadonUlzer environment and application
set RU_ENV=%2
set RU_EXECUTABLE=%RU_PROJECT%\.pio\build\%RU_ENV%\program.exe

rem DroidControlShip environment and application
set DCS_ENV=%3
set DCS_EXECUTABLE=%DCS_PROJECT%\.pio\build\%DCS_ENV%\program.exe

rem Webots world path
set WEBOTS_WORLD=%4

rem ==== CHECK FORCE CLEAN ====
if ["%~5"]==["clean"] (
    echo Cleaning %RU_PROJECT% and %DCS_PROJECT% projects
    start "Clean RadonUlzer" /wait "%PIO_EXE%" run --target clean -e %RU_ENV% -d %RU_PROJECT%
    start "Clean DroidControlShip" /wait "%PIO_EXE%" run -t clean -e %DCS_ENV% -d %DCS_PROJECT%
)

rem ==== CHECK WEBOTS_HOME ====
if "%WEBOTS_HOME%"=="" (
    echo ERROR: WEBOTS_HOME environment variable not set
    exit 1
)

rem ==== CHECK WEBOTS_EXE ====
if not exist "%WEBOTS_EXE%" (
    echo ERROR: %WEBOTS_EXE% not found
    echo Please install Webots R2023b or later.
    exit 1
)

rem ==== CHECK LAUNCHER ====
if not exist "%LAUNCHER%" (
    echo ERROR: %LAUNCHER% not found
    echo Please install Webots R2023b or later.
    exit 1
)

rem ==== CHECK RadonUlzer Application ====
if not exist "%RU_EXECUTABLE%" (
    echo Building the RadonUlzer application.
    start "Build RadonUlzer" /wait "%PIO_EXE%" run -e %RU_ENV% -d %RU_PROJECT%
)

rem ==== CHECK DroidControlShip Application ====
if not exist "%DCS_EXECUTABLE%" (
    echo Building the DroidControlShip application.
    start "Build DroidControlShip" /wait "%PIO_EXE%" run -e %DCS_ENV% -d %DCS_PROJECT%
)

rem ==== SPAWN WORLD IF NO REMOTE IP ADDRESS GIVEN ====
if ["%~6"]==[""] (
    echo Starting Webots
    start /min "Webots" "%WEBOTS_EXE%" %WEBOTS_WORLD%
)

rem ==== SPAWN INSTANCES ====
for /l %%G in (0, 1, %N_ROBOTS%) do (
    set /a instance_port=%BASE_PORT%+%%G
    set instance_name=%BASE_NAME%_%%G

    echo Starting %RU_PROJECT%: %RU_ENV%: !instance_name! on port !instance_port!
    start /min "%RU_PROJECT%: !instance_name!" "%LAUNCHER%" --protocol=tcp --ip-address=%IP_ADDRESS% --robot-name=!instance_name! "%RU_EXECUTABLE%" -n !instance_name! -p !instance_port! -s
    
    echo Starting %DCS_PROJECT%: %DCS_ENV%: !instance_name! on port !instance_port!
    start /min "%DCS_PROJECT%: !instance_name!" "%DCS_EXECUTABLE%" -v -n !instance_name! --cfgFilePath "config/!instance_name!.json" --radonUlzerPort !instance_port!
)

exit 0

rem ==== USAGE ====
:usage
    echo Usage: %0 ^<Number of N_ROBOTS^> ^<RadonUlzer Environment^> ^<DroidControlShip Environment^> ^<Webots World^> ^<clean/noclean^> ^<OPTIONAL Webots IP Address^>
    exit 1