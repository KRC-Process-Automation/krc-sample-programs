# KRC_Sample_MotorRamp: the Structured Text version (CODESYS, WAGO CC100)

The KRC sample program from the video "The KRC Sample PLC Program, Walked Through", in Structured Text on a WAGO CC100 (751-9301), CODESYS 3.5 SP19 Patch 7. It is the ladder version (`../motor-ramp-productivity/`) rung for rung: each block in the four programs starts with `// Rung N.` and the same comment as ladder rung N.

| | |
|---|---|
| Project | `KRC_Sample_MotorRamp.project` (open it in CODESYS) |
| Declarations and programs, to read | `source/` |
| Screen | VIZ_Main, in the project |

## What you need, all free

- CODESYS V3.5 SP19 Patch 7, 64 bit (CODESYS Store), with CODESYS Visualization, part of the standard install.
- WAGO's CODESYS device package with the Compact Controller 100, 751-9301, device description 6.3.1.5 (WAGO's Download Center, or the CODESYS Installer).
- No other libraries. Everything in the Library Manager comes with CODESYS or the WAGO package.

## The machine

A motor on a variable speed drive, run from a panel with Start, Stop, and Reset. Press Start and the motor ramps up through 10, 25, 50, and 75 % speed, each step waiting for the drive's speed feedback. A step that takes longer than the ramp timeout (set on the screen, 10 s to start) faults the machine. Stop ramps it back down; Reset clears a fault.

To keep it simple, this sample's Stop button is normally open. A real panel wires stop buttons normally closed, and because every input is read in one place (INPUTS), only that one line changes. There is no E-stop in the program on purpose: on a real machine the E-stop is hardwired safety, not something a standard PLC program is trusted with.

## Run it

Open the project. Online > Simulation is already on. Login, Start, then double-click VIZ_Main and press START, STOP, and RESET.

The slider at the bottom plays the drive's speed feedback, 0 to 32760 = 0 to 10 V = 0 to 100 %. It only works in simulation, where nothing overwrites the input.

## Analog scaling

The CC100 reads its analog inputs as raw counts, 0 to 32760 for 0 to 10 V, and writes 0 to 32767 for 0 to 10 V out (WAGO's CC100 manual, section 9.4). The full-scale values are `AI_FULL_SCALE` and `AO_FULL_SCALE` in `03_States/CONSTANTS`.

Sample-only choices, as in the ladder: no function blocks, no edge detection, unqualified names so the Structured Text reads with the same tag names as the ladder.
