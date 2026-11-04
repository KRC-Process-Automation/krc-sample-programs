PROGRAM OUTPUTS
// ---- body ----
// OUTPUTS: every output is written here and nowhere else. First the hardware, in terminal order.
DO_bClampClose := bClampClose;
DO_bStackGreen := bStackGreen;
DO_bStackRed := bStackRed;
DO_bStackOrange := bStackOrange;

// Pressure setpoint to the regulator: the input's scaling, run backwards. 0 to 32767 for 0 to 10 V.
AO_wPressureSet := REAL_TO_WORD(rPressureSet * AO_FULL_SCALE / PRESSURE_RANGE);

// Then the robot: the four words to its input registers 0 to 3, sent every EtherNet/IP cycle.
LINK_adiToRobot[TO_HEARTBEAT] := diPlcHeartbeat;
LINK_adiToRobot[TO_COMMAND] := diCommand;
LINK_adiToRobot[TO_FIXTURE_CLEAR] := BOOL_TO_DINT(bFixtureClear);
LINK_adiToRobot[TO_PLC_STEP] := INT_TO_DINT(iStep);

// And the robot program's Start, Stop, and Pause bits, input bit registers 0 to 2.
LINK_dwToRobotBits.BIT_START := bRobotStart;
LINK_dwToRobotBits.BIT_STOP := bRobotStop;
LINK_dwToRobotBits.BIT_PAUSE := bRobotPause;

// Then the HMI. The screen only reads these.
HMI_bStartLamp := bStartLamp;
HMI_bStopLamp := bStopLamp;
HMI_bResetLamp := bResetLamp;
HMI_bPauseLamp := bPauseLamp;
HMI_bStackGreen := bStackGreen;
HMI_bStackRed := bStackRed;
HMI_bStackOrange := bStackOrange;
HMI_rPressure := rPressure;
HMI_sState := sStateDescription;
HMI_bLinkUp := NOT bLinkError AND bRobotAlive;
HMI_bDashUp := bDashConnected;
HMI_bRemote := bRemoteControl;
HMI_bProgramRunning := bProgramRunning;
HMI_bRobotReady := bRobotReady;
HMI_bRobotRunning := bRobotRunning;
HMI_bRobotStopped := bRobotProtStop OR bRobotEStop;
HMI_bPartPresent := bPartPresent;
HMI_iToRobot[0] := LINK_adiToRobot[0];
HMI_iToRobot[1] := LINK_adiToRobot[1];
HMI_iToRobot[2] := LINK_adiToRobot[2];
HMI_iToRobot[3] := LINK_adiToRobot[3];
HMI_iToRobot[4] := DWORD_TO_DINT(LINK_dwToRobotBits AND 16#7);
HMI_iFromRobot[0] := LINK_adiFromRobot[0];
HMI_iFromRobot[1] := LINK_adiFromRobot[1];
HMI_iFromRobot[2] := LINK_adiFromRobot[2];
HMI_iFromRobot[3] := LINK_adiFromRobot[3];
HMI_iFromRobot[4] := LINK_adiFromRobot[4];
HMI_iFromRobot[5] := LINK_adiFromRobot[5];

// What the robot program is doing, in words, from the step it writes as it goes. The step only means
// something while the program plays: stopped or paused, the register still holds the last step written.
IF NOT bDashConnected THEN
    HMI_sRobot := 'Robot: no Dashboard connection';
ELSIF bProgramPaused THEN
    HMI_sRobot := 'Robot: program paused';
ELSIF NOT bProgramRunning AND diRobotStep = ROBOT_NOT_HOME THEN
    HMI_sRobot := 'Robot: started away from home and stopped, jog it home';
ELSIF NOT bProgramRunning THEN
    HMI_sRobot := 'Robot: program stopped';
ELSE
    CASE diRobotStep OF
    10:  HMI_sRobot := 'Robot: starting, checking it is at home';
    100: HMI_sRobot := 'Robot: at home, waiting for a command';
    200: HMI_sRobot := 'Robot: load, picking a part';
    210: HMI_sRobot := 'Robot: load, waiting for fixture clear';
    220: HMI_sRobot := 'Robot: load, placing the part';
    300: HMI_sRobot := 'Robot: unload, waiting for fixture clear';
    310: HMI_sRobot := 'Robot: unload, taking the part out';
    320: HMI_sRobot := 'Robot: unload, dropping the part';
    400: HMI_sRobot := 'Robot: done, waiting for the PLC to clear the command';
    800: HMI_sRobot := 'Robot: gripper missed, going home';
    ELSE
        HMI_sRobot := CONCAT('Robot: step ', DINT_TO_STRING(diRobotStep));
    END_CASE
END_IF
