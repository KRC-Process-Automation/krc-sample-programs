# KRC_Sample_ClampStation: a two-hand clamp station state machine (CODESYS, WAGO CC100)

The program built from a blank project in the video "Build a PLC State Machine in Codesys From a Blank Project". Structured Text on a WAGO CC100 (751-9301), CODESYS 3.5 SP19 Patch 7.

| | |
|---|---|
| Project | `KRC_Sample_ClampStation.project` (open it in CODESYS) |
| Declarations and programs, to read | `source/`, in the same folders as the project tree |
| Screen | VIZ_Main, in the project |

## What you need, all free

- CODESYS V3.5 SP19 Patch 7, 64 bit (CODESYS Store), with CODESYS Visualization, part of the standard install.
- WAGO's CODESYS device package with the Compact Controller 100, 751-9301 (WAGO's Download Center, or the CODESYS Installer).

## The machine

Hold both hand buttons and the clamp closes, with the pressure setpoint from the screen going out to a proportional regulator. At the setpoint (within 2 psi) the clamp opens. It faults if a hand comes off while clamping, if the pressure isn't reached in time, or if the clamp doesn't read open in time. Stop while clamping opens it without a fault; Reset clears a fault. The Stop button is wired normally closed, so a cut wire reads as Stop.

**Not a safety function.** On a real clamp that can catch a hand, the two-hand control is a safety-rated two-hand device or a safety controller, not this logic.

## Run it

Open the project. Online > Simulation is already on. Login, Start, then double-click VIZ_Main.

The strip along the bottom of the screen is for simulation only: the two hand switches (a mouse can't hold two buttons at once) and three switches that break the machine on purpose (Regulator stuck, Open sensor stuck, Cut Stop wire). The SIM program plays the machine from those switches.

**Before downloading to a real CC100,** set `SIM_ENABLED` to FALSE in `07_SIM/GVL_Sim`, so the SIM program does nothing and the real I/O drives the inputs.

## Analog scaling

The CC100 reads 0 to 10 V as 0 to 32760 and writes 0 to 32767 as 0 to 10 V (WAGO's CC100 manual, section 9.4). The pressure is 0 to 100 psi over 0 to 10 V on both the sensor and the regulator. For other hardware, change `PRESSURE_RANGE`, `AI_FULL_SCALE`, or `AO_FULL_SCALE` in `03_States/CONSTANTS`.

Sample-only choices: no function blocks, no alarm manager, no edge detection, unqualified names so it reads cleanly.
