# KRC sample programs

The PLC programs from Kurtin Robotics' PLC Programming videos on YouTube, so you can open them, run them in simulation, and compare them with your own. Each folder is one program.

| Folder | Program | Software |
|---|---|---|
| [`motor-ramp-productivity/`](motor-ramp-productivity/) | The motor ramp-up sample, in ladder, with its HMI screen | AutomationDirect Productivity Suite and C-more (both free) |
| [`motor-ramp-codesys/`](motor-ramp-codesys/) | The same program in Structured Text, rung for rung, with its screen | CODESYS V3.5 SP19 (free) on a WAGO CC100 |
| [`clamp-station-codesys/`](clamp-station-codesys/) | A two-hand clamp station built from a blank project: analog in and out, faults, a simulation program | CODESYS V3.5 SP19 (free) on a WAGO CC100 |
| [`motor-ramp-alarms-codesys/`](motor-ramp-alarms-codesys/) | The motor ramp taken further: an alarm list, a timeout on every step that waits on the machine, and a screen that names what Ready is waiting for | CODESYS V3.5 SP19 (free) on a WAGO CC100 |

Every program runs on a PC with no hardware, in the software's own simulator. The folder's README says what to install and how to run it.

**These are teaching programs, not safety functions.** Stops, E-stops, and two-hand control on a real machine go through safety-rated devices or a safety controller, not a standard PLC program.

Questions about a program, or something that doesn't work the way the video says? Tell us in the video's comments. If you need help with a PLC program or a machine, reach out at https://kurtinrobotics.com.
