# KRC_Sample_MotorRamp: the ladder version (AutomationDirect Productivity) and its HMI screen

The KRC sample program from the video "The KRC Sample PLC Program, Walked Through", in ladder for an AutomationDirect Productivity1000, with its C-more screen.

| | |
|---|---|
| Ladder program | `KRC_Sample_MotorRamp.adpro` (Productivity Suite) |
| HMI screen | `KRC_Sample_MotorRamp_HMI.eap9` (C-more, a 7 inch EA9-T7CL panel) |
| Hardware it's set up for | P1-540 CPU, P1-08NE3 (8 inputs), P1-08TRS (8 relay outputs), P1-4ADL2DAL-2 (4 analog in, 2 analog out, 0 to 10 V) |

## What you need, all free from AutomationDirect

- Productivity Suite 4.6 or newer. It includes the PLC Simulator. No add-ons or libraries.
- C-more Programming Software for EA9 panels, 6.80 or newer, for the screen. It includes its own simulator. No add-ons.

## The machine

A motor on a variable speed drive, run from a panel with Start, Stop, and Reset. Press Start and the motor ramps up through 10, 25, 50, and 75 % speed, each step waiting for the drive's speed feedback. A step that takes longer than the ramp timeout (set on the HMI, 10 s to start) faults the machine. Stop ramps it back down; Reset clears a fault.

Four programs run every scan, in this order: INPUTS reads every input, STATE_MACHINE decides the step, DEVICES sets every output from the step, and OUTPUTS writes them to the hardware and the HMI.

To keep it simple, this sample's Stop button is normally open. A real panel wires stop buttons normally closed, and because every input is read in INPUTS, only that one rung changes. There is no E-stop in the program on purpose: on a real machine the E-stop is hardwired safety, not something a standard PLC program is trusted with.

## Run it

Ladder: open the project in Productivity Suite, click Simulator, then File > Transfer Project > To CPU, then Run.

Screen: C-more's simulator runs the screen on a PC, but it can't talk to the Productivity PLC Simulator, so in the simulator you set the tag values by hand from its Tag List. On a real panel, set the PLC's IP address in C-more's Panel Manager (DEV001), give the P1-540 a static IP, and set its Ethernet port security to Read/Write. The screen only touches the HMI_ tags.

The same program in Structured Text, rung for rung, is in `../motor-ramp-codesys/`.
