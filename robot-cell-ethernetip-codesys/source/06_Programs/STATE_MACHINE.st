PROGRAM STATE_MACHINE
VAR
	bAllClear  : BOOL;	// Everything the cell needs before it can be Ready
	bCycling   : BOOL;	// The cell is in a cycle, from Load request to Unload clear
	bRobotBusy : BOOL;	// The robot program has work from the PLC: starting, cycling, paused, or resuming
END_VAR
// ---- body ----
// STATE_MACHINE: decides which step the cell is in. One CASE on the step, one branch per step.
// Inside a branch, each exit is one IF: the reason it leaves, then the next step into iNextStep and what
// the cell will be doing, for the HMI. The step only changes on the last line, so every line in one
// scan sees the same step.

// The step timers. Each runs only while its steps are active, so it starts from zero every time.
TON_START(IN := iStep = S3_STARTING OR iStep = S9_RESUMING, PT := ROBOT_START_TIME);
TON_PAUSE(IN := iStep = S9_PAUSED AND NOT bProgramPaused, PT := ROBOT_PAUSE_TIME);
TON_ACK(IN := iStep = S4_LOAD_REQUEST OR iStep = S7_UNLOAD_REQUEST);
TON_MOVE(IN := iStep = S4_LOADING OR iStep = S7_UNLOADING);
TON_CLEAR(IN := iStep = S4_LOAD_CLEAR OR iStep = S7_UNLOAD_CLEAR);
TON_CLAMP(IN := iStep = S5_CLAMPING);
TON_HOLD(IN := iStep = S5_HOLDING);
TON_OPEN(IN := iStep = S6_OPENING);

// Everything the cell needs before it's Ready: the link up, the Dashboard up and the robot in remote control
// (so it takes Start, Stop, and Pause), the arm Running with no stop on it, the robot program not paused, and
// if it's already running, its heartbeat ticking, ready, and the last handshake cleared; the clamp open, the
// fixture empty, and Stop not pressed. A stopped robot program is fine: Start starts it.
bAllClear := NOT bLinkError AND bDashConnected AND bRemoteControl AND bRobotRunning AND NOT bRobotProtStop
    AND NOT bRobotEStop AND NOT bProgramPaused
    AND (NOT bProgramRunning OR (bRobotAlive AND bRobotReady AND bHandshakeClear))
    AND bClampOpen AND NOT bPartPresent AND NOT bStopPB;
bCycling := iStep >= S4_LOAD_REQUEST AND iStep <= S7_UNLOAD_CLEAR;
bRobotBusy := bCycling OR iStep = S3_STARTING OR iStep = S9_PAUSED OR iStep = S9_RESUMING;

CASE iStep OF

S0_IDLE:
    // Idle: powered up and at rest. Go to Not Ready.
    iNextStep := S1_NOT_READY;
    sStateDescription := 'Not Ready - waiting for the robot and an empty fixture';

S1_NOT_READY:
    // Not Ready: all clear. Ready.
    IF bAllClear THEN
        iNextStep := S3_READY;
        sStateDescription := 'Ready - press Start';
    END_IF
    // Not Ready: Reset pressed. Go through Reset.
    IF bResetPB THEN
        iNextStep := S2_RESET;
        sStateDescription := 'Reset - release Reset';
    END_IF

S2_RESET:
    // Reset: Reset released. Back to Not Ready, which checks everything again before Ready.
    IF NOT bResetPB THEN
        iNextStep := S1_NOT_READY;
        sStateDescription := 'Not Ready - waiting for the robot and an empty fixture';
    END_IF

S3_READY:
    // Ready: Start pressed (just now, not held) and the robot program isn't running. Start it.
    IF bStartPressed AND NOT bProgramRunning THEN
        iNextStep := S3_STARTING;
        sStateDescription := 'Starting - starting the robot program';
    END_IF
    // Ready: Start pressed and the robot program is already running. Ask it to load a part.
    IF bStartPressed AND bProgramRunning THEN
        iNextStep := S4_LOAD_REQUEST;
        sStateDescription := 'Load - asking the robot to load a part';
    END_IF
    // Ready: anything in all clear is gone (the robot dropped out). Back to Not Ready. Written last, so it wins.
    IF NOT bAllClear THEN
        iNextStep := S1_NOT_READY;
        sStateDescription := 'Not Ready - waiting for the robot and an empty fixture';
    END_IF

S3_STARTING:
    // Starting: the robot program runs, its heartbeat ticks, and it's at home, ready. Ask it to load a part.
    IF bProgramRunning AND bRobotAlive AND bRobotReady AND bHandshakeClear THEN
        iNextStep := S4_LOAD_REQUEST;
        sStateDescription := 'Load - asking the robot to load a part';
    END_IF
    // Starting: not running and ready in time. Fault, on the robot's side.
    IF TON_START.Q THEN
        iNextStep := S8_FAULT;
        sStateDescription := 'Fault - robot program did not start in time';
    END_IF
    // Starting: the robot program found itself away from home and stopped rather than move. Given time to
    // start and write its step first, so an old step from last time doesn't count. Written last, so it wins.
    IF TON_START.ET >= ROBOT_HOME_CHECK AND diRobotStep = ROBOT_NOT_HOME AND NOT bProgramRunning THEN
        iNextStep := S8_FAULT;
        sStateDescription := 'Fault - robot is away from home, jog it home';
    END_IF

S4_LOAD_REQUEST:
    // Load request: the robot echoes the load command. It's on its way.
    IF diRobotAck = CMD_LOAD THEN
        iNextStep := S4_LOADING;
        sStateDescription := 'Load - the robot is loading a part';
    END_IF
    // Load request: no answer in time. Fault, on the robot's side.
    IF TON_ACK.Q AND diRobotAck <> CMD_LOAD THEN
        iNextStep := S8_FAULT;
        sStateDescription := 'Fault - robot did not acknowledge the load';
    END_IF

S4_LOADING:
    // Loading: the robot says done and the fixture sees the part. Clear the handshake.
    IF diRobotDone = CMD_LOAD AND bPartPresent THEN
        iNextStep := S4_LOAD_CLEAR;
        sStateDescription := 'Load - part in, clearing the handshake';
    END_IF
    // Loading: the robot says done but the fixture doesn't see a part. Fault, checked on the PLC's side.
    IF diRobotDone = CMD_LOAD AND NOT bPartPresent THEN
        iNextStep := S8_FAULT;
        sStateDescription := 'Fault - robot finished the load but no part in the fixture';
    END_IF
    // Loading: no done in time. Fault, on the robot's side.
    IF TON_MOVE.Q AND diRobotDone <> CMD_LOAD THEN
        iNextStep := S8_FAULT;
        sStateDescription := 'Fault - robot did not finish the load in time';
    END_IF
    // Loading: the robot reports its own fault. Written last, so it wins.
    IF diRobotFault <> 0 THEN
        iNextStep := S8_FAULT;
        sStateDescription := 'Fault - robot reports its gripper missed the part';
    END_IF

S4_LOAD_CLEAR:
    // Load clear: the robot cleared its acknowledge and done. Clamp the part.
    IF bHandshakeClear THEN
        iNextStep := S5_CLAMPING;
        sStateDescription := 'Clamping - building pressure';
    END_IF
    // Load clear: the robot didn't clear in time. Fault, on the robot's side.
    IF TON_CLEAR.Q AND NOT bHandshakeClear THEN
        iNextStep := S8_FAULT;
        sStateDescription := 'Fault - robot did not clear the handshake';
    END_IF

S5_CLAMPING:
    // Clamping: the pressure is within the band of the setpoint. Hold it.
    IF rPressure >= HMI_rPressureSet - PRESSURE_BAND THEN
        iNextStep := S5_HOLDING;
        sStateDescription := 'Clamping - holding at pressure';
    END_IF
    // Clamping: the timeout ran out and the pressure is still short. Fault, on the clamp.
    IF TON_CLAMP.Q AND rPressure < HMI_rPressureSet - PRESSURE_BAND THEN
        iNextStep := S8_FAULT;
        sStateDescription := 'Fault - pressure not reached in time';
    END_IF

S5_HOLDING:
    // Holding: the hold time is up. Open the clamp.
    IF TON_HOLD.Q THEN
        iNextStep := S6_OPENING;
        sStateDescription := 'Opening - hold done';
    END_IF

S6_OPENING:
    // Opening: the clamp reads open. Ask the robot to unload the part.
    IF bClampOpen THEN
        iNextStep := S7_UNLOAD_REQUEST;
        sStateDescription := 'Unload - asking the robot to unload the part';
    END_IF
    // Opening: the timeout ran out and the clamp still doesn't read open. Fault, on the clamp.
    IF TON_OPEN.Q AND NOT bClampOpen THEN
        iNextStep := S8_FAULT;
        sStateDescription := 'Fault - clamp did not open in time';
    END_IF

S7_UNLOAD_REQUEST:
    // Unload request: the robot echoes the unload command. It's on its way.
    IF diRobotAck = CMD_UNLOAD THEN
        iNextStep := S7_UNLOADING;
        sStateDescription := 'Unload - the robot is unloading the part';
    END_IF
    // Unload request: no answer in time. Fault, on the robot's side.
    IF TON_ACK.Q AND diRobotAck <> CMD_UNLOAD THEN
        iNextStep := S8_FAULT;
        sStateDescription := 'Fault - robot did not acknowledge the unload';
    END_IF

S7_UNLOADING:
    // Unloading: the robot says done and the fixture is empty. Clear the handshake.
    IF diRobotDone = CMD_UNLOAD AND NOT bPartPresent THEN
        iNextStep := S7_UNLOAD_CLEAR;
        sStateDescription := 'Unload - part out, clearing the handshake';
    END_IF
    // Unloading: the robot says done but the part is still in the fixture. Fault, checked on the PLC's side.
    IF diRobotDone = CMD_UNLOAD AND bPartPresent THEN
        iNextStep := S8_FAULT;
        sStateDescription := 'Fault - robot finished the unload but the part is still in the fixture';
    END_IF
    // Unloading: no done in time. Fault, on the robot's side.
    IF TON_MOVE.Q AND diRobotDone <> CMD_UNLOAD THEN
        iNextStep := S8_FAULT;
        sStateDescription := 'Fault - robot did not finish the unload in time';
    END_IF
    // Unloading: the robot reports its own fault. Written last, so it wins.
    IF diRobotFault <> 0 THEN
        iNextStep := S8_FAULT;
        sStateDescription := 'Fault - robot reports its gripper missed the part';
    END_IF

S7_UNLOAD_CLEAR:
    // Unload clear, single cycle: the robot cleared its answer. The part is done: Ready for the next Start.
    IF bHandshakeClear AND NOT HMI_bContinuous THEN
        iNextStep := S3_READY;
        sStateDescription := 'Ready - press Start';
    END_IF
    // Unload clear, continuous: the part is done, straight into the next one, until Stop or Pause (or the
    // switch back to single cycle, which finishes this part and stops at Ready).
    IF bHandshakeClear AND HMI_bContinuous THEN
        iNextStep := S4_LOAD_REQUEST;
        sStateDescription := 'Load - asking the robot to load a part';
    END_IF
    // Unload clear: the robot didn't clear in time. Fault, on the robot's side.
    IF TON_CLEAR.Q AND NOT bHandshakeClear THEN
        iNextStep := S8_FAULT;
        sStateDescription := 'Fault - robot did not clear the handshake';
    END_IF

S8_FAULT:
    // Fault: Reset pressed. Go through Reset, then Not Ready.
    IF bResetPB THEN
        iNextStep := S2_RESET;
        sStateDescription := 'Reset - release Reset';
    END_IF

S8_STOPPED:
    // Stopped: Stop released and Reset pressed. Go through Reset, then Not Ready.
    IF bResetPB AND NOT bStopPB THEN
        iNextStep := S2_RESET;
        sStateDescription := 'Reset - release Reset';
    END_IF

S9_PAUSED:
    // Paused: the Dashboard says the robot program is paused, and Start is pressed. Carry on.
    IF bStartPressed AND bProgramPaused THEN
        iNextStep := S9_RESUMING;
        sStateDescription := 'Paused - resuming the robot program';
    END_IF
    // Paused: the robot program never paused. Fault, on the robot's side.
    IF TON_PAUSE.Q AND NOT bProgramStopped THEN
        iNextStep := S8_FAULT;
        sStateDescription := 'Fault - robot program did not pause';
    END_IF
    // Paused: the Dashboard says the robot program is stopped, not paused (stopped on the pendant, or it hit
    // an error). Start would run it from the top, not carry on, so the cycle can't go on. Fault. Written
    // last, so it wins.
    IF bProgramStopped THEN
        iNextStep := S8_FAULT;
        sStateDescription := 'Fault - robot program stopped while paused, it cannot carry on';
    END_IF

S9_RESUMING:
    // Resuming: the robot program runs and its heartbeat ticks. Back to the step Pause came from.
    IF bProgramRunning AND bRobotAlive THEN
        iNextStep := iPausedStep;
        sStateDescription := sPausedDescription;
    END_IF
    // Resuming: not running in time. Fault, on the robot's side.
    IF TON_START.Q THEN
        iNextStep := S8_FAULT;
        sStateDescription := 'Fault - robot program did not resume in time';
    END_IF
END_CASE

// Pause, in a cycle: remember where the cycle was going and what it was doing, and pause. Only while that
// is still a cycle step (an exit above may already be a fault, or the end of the cycle).
IF bCycling AND bPausePB AND iNextStep >= S4_LOAD_REQUEST AND iNextStep <= S7_UNLOAD_CLEAR THEN
    iPausedStep := iNextStep;
    sPausedDescription := sStateDescription;
    iNextStep := S9_PAUSED;
    sStateDescription := 'Paused - press Start to carry on';
END_IF

// While the robot has work, losing the robot wins over every exit above. Each has its own words, so the
// screen says which side failed. Written in this order, so the last true one wins: the arm stops Running,
// the robot's heartbeat stops (its program stopped; only checked in a cycle, since a paused or starting
// program doesn't count), the robot leaves remote control, the Dashboard drops, its protective stop, its
// emergency stop, and last the network, because with the link down every word from the robot is stale.
IF bRobotBusy AND NOT bRobotRunning THEN
    iNextStep := S8_FAULT;
    sStateDescription := 'Fault - robot arm not running';
END_IF
IF bCycling AND NOT bRobotAlive THEN
    iNextStep := S8_FAULT;
    sStateDescription := 'Fault - no robot heartbeat, robot program stopped';
END_IF
IF bRobotBusy AND bDashConnected AND NOT bRemoteControl THEN
    iNextStep := S8_FAULT;
    sStateDescription := 'Fault - robot left remote control';
END_IF
IF bRobotBusy AND NOT bDashConnected THEN
    iNextStep := S8_FAULT;
    sStateDescription := 'Fault - Dashboard connection lost';
END_IF
IF bRobotBusy AND bRobotProtStop THEN
    iNextStep := S8_FAULT;
    sStateDescription := 'Fault - robot in a protective stop';
END_IF
IF bRobotBusy AND bRobotEStop THEN
    iNextStep := S8_FAULT;
    sStateDescription := 'Fault - robot emergency stop';
END_IF
IF bRobotBusy AND bLinkError THEN
    iNextStep := S8_FAULT;
    sStateDescription := 'Fault - link lost, PLC cannot reach the robot';
END_IF

// Stop, from any step: the robot program stops right away and the cell waits in Stopped for Reset. It's
// the operator's word, so it wins over everything. (Stop is not a safety function: stopping the robot for
// a person is its own safety system.)
IF bStopPB AND iStep <> S8_STOPPED THEN
    iNextStep := S8_STOPPED;
    sStateDescription := 'Stopped - robot program stopped, press Reset';
END_IF

// Take the next step. This is the only place the step changes.
iStep := iNextStep;
