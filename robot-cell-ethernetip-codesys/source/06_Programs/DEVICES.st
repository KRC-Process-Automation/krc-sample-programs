PROGRAM DEVICES
VAR
	iDeviceStep : E_Step;	// The step the devices follow: the step itself, or while paused, the step Pause came from
END_VAR
// ---- body ----
// DEVICES: every output is set here, once, from the step. Nothing here reads a button or another output.
// Each bit is written like a coil: TRUE while its condition is true, FALSE as soon as it isn't.

// While paused, the clamp, the command, and fixture clear stay as they were in the step Pause came from,
// so the robot carries on where it left off and a clamped part stays clamped.
IF iStep = S9_PAUSED OR iStep = S9_RESUMING THEN
    iDeviceStep := iPausedStep;
ELSE
    iDeviceStep := iStep;
END_IF

// Command to the robot: load in the two load steps, unload in the two unload steps, 0 everywhere else.
// Clearing it is the PLC's half of ending a handshake.
IF iDeviceStep = S4_LOAD_REQUEST OR iDeviceStep = S4_LOADING THEN
    diCommand := CMD_LOAD;
ELSIF iDeviceStep = S7_UNLOAD_REQUEST OR iDeviceStep = S7_UNLOADING THEN
    diCommand := CMD_UNLOAD;
ELSE
    diCommand := CMD_NONE;
END_IF

// Fixture clear: the robot may reach into the fixture, only while it's loading or unloading and the
// clamp reads open. The robot program waits for it before it goes in.
bFixtureClear := (iDeviceStep = S4_LOAD_REQUEST OR iDeviceStep = S4_LOADING OR iDeviceStep = S7_UNLOAD_REQUEST
    OR iDeviceStep = S7_UNLOADING) AND bClampOpen;

// The robot program's Start, Stop, and Pause: three register bits the robot has set up as I/O actions. Each
// acts as its bit turns on: Start while starting or resuming, Stop in Stopped, Pause in Paused.
bRobotStart := iStep = S3_STARTING OR iStep = S9_RESUMING;
bRobotStop := iStep = S8_STOPPED;
bRobotPause := iStep = S9_PAUSED;

// PLC heartbeat: counted up every 250 ms, in every step, so the robot can tell the PLC is still running.
// The timer restarts itself each time it fires.
TON_PLC_BEAT(IN := NOT TON_PLC_BEAT.Q, PT := HEARTBEAT_TIME);
IF TON_PLC_BEAT.Q THEN
    diPlcHeartbeat := diPlcHeartbeat + 1;
END_IF

// Clamp valve: on in Clamping and Holding.
bClampClose := iDeviceStep = S5_CLAMPING OR iDeviceStep = S5_HOLDING;

// Pressure setpoint to the regulator: the HMI setpoint while the valve is on, 0 the rest of the time.
IF iDeviceStep = S5_CLAMPING OR iDeviceStep = S5_HOLDING THEN
    rPressureSet := HMI_rPressureSet;
ELSE
    rPressureSet := 0.0;
END_IF

// Stack light green: ready, starting, cycling, or paused (the cycle is on hold, nothing is wrong).
bStackGreen := (iStep >= S3_READY AND iStep <= S7_UNLOAD_CLEAR) OR iStep = S9_PAUSED OR iStep = S9_RESUMING;

// Stack light red: not ready to cycle. Written from the steps, never as "not green".
bStackRed := iStep = S0_IDLE OR iStep = S1_NOT_READY OR iStep = S2_RESET OR iStep = S8_FAULT OR iStep = S8_STOPPED;

// Stack light orange: faulted.
bStackOrange := iStep = S8_FAULT;

// Start lamp: lit when Start does something: in Ready, and in Paused once the robot program has paused.
// Everywhere else Start does nothing.
bStartLamp := iStep = S3_READY OR (iStep = S9_PAUSED AND bProgramPaused);

// Stop lamp: lit when Stop does something, everywhere but Stopped.
bStopLamp := iStep <> S8_STOPPED;

// Pause lamp: lit when Pause does something, in a cycle.
bPauseLamp := iStep >= S4_LOAD_REQUEST AND iStep <= S7_UNLOAD_CLEAR;

// Reset lamp: lit when the cell is faulted or stopped and needs a reset.
bResetLamp := iStep = S8_FAULT OR iStep = S8_STOPPED;
