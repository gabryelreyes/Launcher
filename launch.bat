@echo off
rem Launcher of multiple Controllers for RadonUlzer and DroidControlShip
rem Author: Gabryel Reyes (gabryelrdiaz@gmail.com)

SETLOCAL EnableDelayedExpansion

rem ==== CONSTANTS ====
set LAUNCHER=%WEBOTS_HOME%\msys64\mingw64\bin\webots-controller.exe
set RU_PROJECT=RadonUlzer
set DCS_PROJECT=DroidControlShip
set BASE_PORT=65432
set BASE_NAME=zumo

rem ==== CHECK ARGUMENTS ====
if ["%~1"]==[""] goto usage
if ["%~2"]==[""] goto usage
if ["%~3"]==[""] goto usage

rem N_ROBOTS starts with 0, so we need to subtract 1 from the argument
set /a N_ROBOTS=%1-1

rem RadonUlzer environment and application
set RU_ENV=%2
set RU_EXECUTABLE=%RU_PROJECT%\.pio\build\%RU_ENV%\program.exe

rem DroidControlShip environment and application
set DCS_ENV=%3
set DCS_EXECUTABLE=%DCS_PROJECT%\.pio\build\%DCS_ENV%\program.exe


rem ==== CHECK WEBOTS_HOME ====
if "%WEBOTS_HOME%"=="" (
    echo ERROR: WEBOTS_HOME environment variable not set
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
    echo ERROR: %RU_EXECUTABLE% not found
    echo Please build the RadonUlzer application.
    exit 1
)

rem ==== CHECK DroidControlShip Application ====
if not exist "%DCS_EXECUTABLE%" (
    echo ERROR: %DCS_EXECUTABLE% not found
    echo Please build the DroidControlShip application.
    exit 1
)

rem ==== SPAWN INSTANCES ====
for /l %%G in (0, 1, %N_ROBOTS%) do (
    set /a instance_port=%BASE_PORT%+%%G
    set instance_name=%BASE_NAME%_%%G

    echo Starting %RU_PROJECT%: %RU_ENV%: !instance_name! on port !instance_port!
    start "%RU_PROJECT%: !instance_name!" "%LAUNCHER%" --robot-name=!instance_name! "%RU_EXECUTABLE%" -n !instance_name! -p !instance_port!
    
    echo Starting %DCS_PROJECT%: %DCS_ENV%: !instance_name! on port !instance_port!
    start "%DCS_PROJECT%: !instance_name!" "%DCS_EXECUTABLE%" -n !instance_name! -p !instance_port!
)

exit 0

rem ==== USAGE ====
:usage
    echo Usage: %0 ^<Number of N_ROBOTS^> ^<RadonUlzer Environment^> ^<DroidControlShip Environment^>
    exit 1