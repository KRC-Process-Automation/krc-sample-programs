// SAMPLE PROGRAM: a clamp station loaded and unloaded by a robot. KRC (Kurtin Robotics), written as a teaching
// example. The PLC (WAGO CC100) runs the cell and talks to a Universal Robots arm over EtherNet/IP: it tells the
// robot to load a part, clamps it to a pressure setpoint from the HMI, holds, opens, and tells the robot to
// unload it. Every command is a handshake (command, acknowledge, done, clear), every step of it has a timeout,
// and the PLC watches the robot's heartbeat. The panel's Start, Stop, and Pause work the robot program through
// three register bits, and a second connection, the robot's Dashboard, tells the PLC whether the program is
// playing, paused, or stopped. Each fault says which side failed.
// NOT A SAFETY FUNCTION. Nothing on this link stops the robot. Stopping motion is the robot's safety system
// (its protective and emergency stops); the PLC only watches it.
// How it is laid out: MainTask calls SIM (simulation only), then INPUTS, STATE_MACHINE, DEVICES, OUTPUTS, and
// DASHBOARD, every scan. INPUTS reads every input, the robot's words included, into a program tag. STATE_MACHINE
// decides the step. DEVICES sets every output from the step. OUTPUTS writes every output to the hardware, the
// robot, and the HMI. DASHBOARD is the driver for the Dashboard connection: it asks the robot what its program
// is doing.
PROGRAM INPUTS
// ---- body ----
// INPUTS: every input is read here and nowhere else.
// Start: the panel button or the HMI button. The state machine acts on the press, the scan it goes on, so
// a button held down (or stuck) can't start one cycle after another.
bStartPB := DI_bStartPB OR HMI_bStartPB;
bStartPressed := bStartPB AND NOT bStartLast;
bStartLast := bStartPB;

// Stop is wired normally closed: the input is on while nobody presses it, so a broken wire reads the
// same as pressing Stop. This is the only place it gets turned around. Or the Stop button on the HMI.
bStopPB := NOT DI_bStopPB_NC OR HMI_bStopPB;

// Reset: the panel button or the HMI button.
bResetPB := DI_bResetPB OR HMI_bResetPB;

// Pause: the HMI button.
bPausePB := HMI_bPausePB;

// The clamp open sensor and the part-present sensor in the fixture.
bClampOpen := DI_bClampOpen;
bPartPresent := DI_bPartPresent;

// Pressure: the CC100 reads 0 to 10 V as 0 to 32760. Scaled once, here, to psi.
rPressure := WORD_TO_REAL(AI_wPressure) * PRESSURE_RANGE / AI_FULL_SCALE;

// The link's own health. On a real controller it's the scanner's word on the robot's connection, from the
// robot's device, UR_Robot. In simulation the scanner doesn't run, so SIM plays it instead.
IF NOT SIM_ENABLED THEN
    LINK_bCommError := UR_Robot.State <> IoDrvEtherNetIP.ADAPTERSTATE.RUNNING;
END_IF
bLinkError := LINK_bCommError;

// The robot's words, read once, each into a tag with a name.
diRobotHeartbeat := LINK_adiFromRobot[FROM_HEARTBEAT];
bRobotReady := LINK_adiFromRobot[FROM_READY] = 1;
diRobotAck := LINK_adiFromRobot[FROM_ACK];
diRobotDone := LINK_adiFromRobot[FROM_DONE];
diRobotFault := LINK_adiFromRobot[FROM_FAULT];
diRobotStep := LINK_adiFromRobot[FROM_ROBOT_STEP];
bHandshakeClear := diRobotAck = CMD_NONE AND diRobotDone = CMD_NONE;

// The robot controller's own state, from the same EtherNet/IP assembly: its mode, whether its program is
// running, and its stops (a safeguard stop is a protective stop from a guard; the three emergency stops are
// the system's, the robot's, and the cell's).
bRobotRunning := LINK_siRobotMode = ROBOT_RUNNING;
bProgramRunning := LINK_dwRobotBits.1;
bRobotProtStop := LINK_dwSafetyBits.2 OR LINK_dwSafetyBits.4;
bRobotEStop := LINK_dwSafetyBits.5 OR LINK_dwSafetyBits.6 OR LINK_dwSafetyBits.7;

// The Dashboard's answers: the connection, whether the robot program is playing, paused, or stopped (all
// EtherNet/IP can say is running or not), and whether the robot is in remote control.
bDashConnected := LINK_bDashConnected;
bProgramPlaying := FIND(LINK_sProgramState, 'PLAYING') = 1;
bProgramPaused := FIND(LINK_sProgramState, 'PAUSED') = 1;
bProgramStopped := FIND(LINK_sProgramState, 'STOPPED') = 1;
bRemoteControl := LINK_bRemoteControl;

// The robot's heartbeat: its program counts it up. If the count hasn't changed for a second, the robot
// program has stopped. The timer only runs while the count stands still, so every change restarts it.
TON_BEAT_LOST(IN := diRobotHeartbeat = diRobotBeatLast, PT := HEARTBEAT_LOST);
bRobotAlive := NOT TON_BEAT_LOST.Q;
diRobotBeatLast := diRobotHeartbeat;

// The timeouts from the HMI, in seconds, as each timer's preset.
TON_ACK.PT := T#1S * HMI_iAckTimeout;
TON_CLEAR.PT := T#1S * HMI_iAckTimeout;
TON_MOVE.PT := T#1S * HMI_iMoveTimeout;
TON_CLAMP.PT := T#1S * HMI_iClampTimeout;
TON_HOLD.PT := T#1S * HMI_iHoldTime;
TON_OPEN.PT := T#1S * HMI_iOpenTimeout;
