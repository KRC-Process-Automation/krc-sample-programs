# KRC_Sample_RobotCell: a PLC running a UR robot over EtherNet/IP (CODESYS, WAGO CC100)

The program from the video "Connect a PLC to a Robot": a WAGO CC100 (751-9301) in CODESYS 3.5 SP19 Patch 7 running a Universal Robots program on PolyScope 5. The clamp station from `../clamp-station-codesys/`, now loaded and unloaded by the robot.

| | |
|---|---|
| Project | `KRC_Sample_RobotCell.project` (open it in CODESYS) |
| Declarations and programs, to read | `source/`, in the same folders as the project tree |
| Screens | VIZ_Main (the operator's) and VIZ_Setup (timeouts and simulation switches), in the project |
| Robot side | `robot/krc_tending.urp` (the program) and `robot/krc_cell.installation` (its installation), PolyScope 5.12; `robot/krc_tending.script`, the same program in URScript, to read |

## What you need, all free

- CODESYS V3.5 SP19 Patch 7, 64 bit (CODESYS Store), with CODESYS Visualization, part of the standard install.
- WAGO's CODESYS device package with the Compact Controller 100, 751-9301 (WAGO's Download Center, or the CODESYS Installer).
- UR's EtherNet/IP EDS file (Universal Robots' download center), installed in CODESYS with Tools > Device Repository > Install. The project's robot device, UR_Robot, comes from it.
- For the robot: URSim 5.12 (Universal Robots' download center), or a UR robot on PolyScope 5. Use URSim 5.12 rather than a later URSim: its EtherNet/IP adapter runs, and URSim 5.25's never answered when we tried it.

## How it works

Two connections, both on Ethernet. The CC100 is 192.168.1.20 and the robot 192.168.1.10.

- **EtherNet/IP.** The CC100 is the scanner (license-free on the CC100) and the robot the adapter. Every 10 ms the PLC writes the robot's general purpose input registers and reads its output registers (the mapping is in `01_Inputs/GVL_Link`, the register numbers in `03_States/CONSTANTS`).
- **The Dashboard Server** (TCP port 29999). EtherNet/IP only says whether the robot program is running; a paused program and a stopped one look the same. So the DASHBOARD program asks the robot `programState` four times a second, which tells playing, paused, and stopped apart, and checks the robot is in Remote Control.

**The handshake.** Every command takes four steps: the PLC writes the command (1 load, 2 unload), the robot echoes it as acknowledge, does the move and echoes it as done, the PLC writes 0, and the robot clears both and goes back to ready. Each step has a timeout, and each fault says which side failed.

**Start, Stop, and Pause** are bits 0, 1, and 2 of the robot's input bit registers, which the installation gives those three actions. Start starts the robot program, or carries on from a pause. Stop stops it from any step, and the arm stays where it was; next time the program starts it checks it's at home, and if it isn't, it stops and says so. Pause holds the cell where it is, a clamped part stays clamped, and no timeout runs.

**The heartbeat.** Each side counts a register up every 250 ms (register 0 both ways). If the robot's count doesn't change for 1 s, the PLC faults: the robot program has stopped, or the link is gone.

The Run continuous switch on the screen picks one part per Start or part after part until Stop or Pause.

**Not a safety function.** Nothing on either connection stops the robot for a person. The robot's own safety configuration and safety-rated devices do that.

## Run it

Open the project. Online > Simulation is already on. Login, Start, then double-click VIZ_Main and press START. In simulation the SIM program plays the robot and the clamp station. VIZ_Setup holds the four timeouts and nine switches that break the link or the robot on purpose (Unplug cable, Robot program stopped, Protective stop, Robot ignores commands, Gripper miss, Part stuck, Dashboard down, Pendant in local, Away from home).

**Before downloading to a real CC100,** set `SIM_ENABLED` to FALSE in `07_SIM/GVL_Sim`, so the SIM program does nothing and the real I/O and the real robot drive the inputs. If your network isn't 192.168.1.x, set the CC100's address in its Ethernet device, the robot's in UR_Robot, and `ROBOT_IP` in `03_States/CONSTANTS` for the Dashboard.

## The robot side

On the robot (or URSim), load `krc_cell.installation`, then `krc_tending.urp`. The installation turns EtherNet/IP on, names the registers, gives input bit registers 0, 1, and 2 the actions Start, Stop, and Pause, and makes the program the default at power-up. Set the robot's address to 192.168.1.10 (Settings > System > Network) and put it in Remote Control (Settings > System > Remote Control, then the switch in the header), or it ignores Start from the PLC. The installation's safety settings are URSim's defaults: use your own robot's.

**The waypoints are placeholders.** Teach your own home, tray, and fixture positions before it moves a real arm, and swap the gripper lines for your gripper's own commands. In URSim, which has no part sensor, the program's gripper check reads the gripper's close output, so it always passes; on a real robot, check the gripper's part-detect input instead (named Part_in_gripper in the installation), as `krc_tending.script` does.

Sample-only choices: programs rather than function blocks, unqualified names so it reads cleanly, and the Dashboard used only to read the program's state (Start, Stop, and Pause go over the register bits).
