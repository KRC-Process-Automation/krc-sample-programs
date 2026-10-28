# KRC_Sample_MotorRamp_Alarms: the motor ramp with alarms, timeouts, and diagnostics (CODESYS, WAGO CC100)

The program from the video "Alarms, Timeouts, and Diagnostics in a PLC State Machine": the walkthrough's motor ramp sample (`../motor-ramp-codesys/`), taken further. Structured Text on a WAGO CC100 (751-9301), CODESYS 3.5 SP19 Patch 7.

| | |
|---|---|
| Project | `KRC_Sample_MotorRamp_Alarms.project` (open it in CODESYS) |
| Declarations and programs, to read | `source/`, in the same folders as the project tree |
| Screen | VIZ_Main, in the project |

## What you need, all free

- CODESYS V3.5 SP19 Patch 7, 64 bit (CODESYS Store), with CODESYS Visualization, part of the standard install.
- WAGO's CODESYS device package with the Compact Controller 100, 751-9301 (WAGO's Download Center, or the CODESYS Installer).

## What's added to the walkthrough's program

- An alarm list with three levels (INFO shows on the list, WARNING lights the orange light and the machine keeps running, ALARM stops the machine), acknowledged with ACK or Reset, and cleared once it's acknowledged and its cause is gone.
- A timeout on every step that waits on the machine, each one an alarm.
- A permissive list: the state line names the first thing Ready is waiting for.
- The speed feedback watched the whole time the motor is at speed (a deviation warning).
- One-shots on Start, Reset, and ACK.
- The naming convention, with the program that writes each variable noted on its declaration.
- Stop wired normally closed.

**Not a safety function.** The E-stop input only watches the safety relay. On a real machine the safety relay stops the motor, hardwired, and the PLC reports it.

## Run it

Open the project. Online > Simulation is already on. Login, Start, then double-click VIZ_Main.

The strip along the bottom of the screen is for simulation only: eight switches that break the machine on purpose (Drive not ready, Drive in local, E-stop, Motor stall, Won't stop, Speed droop, Cut Stop wire, Start stuck). The SIM program plays the drive and the motor from those switches. Set the ramp timeout to 3 s on the screen to see a timeout without waiting.

**Before downloading to a real CC100,** set `SIM_ENABLED` to FALSE in `07_SIM/GVL_Sim`, so the SIM program does nothing and the real I/O drives the inputs.

Sample-only choices: an alarm list in Structured Text rather than CODESYS's Alarm Manager, programs rather than function blocks, unqualified names so it reads cleanly.
