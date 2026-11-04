// SIM: SIMULATION ONLY. Test code: it never goes on a real machine.
// It plays the robot and the machine, so the program can be tested with nothing wired and no robot: it
// writes the robot's words in GVL_Link the way its EtherNet/IP adapter would, takes the Start, Stop, and Pause
// bits the way its I/O actions would, answers for the robot's Dashboard the way the DASHBOARD driver would
// report it, and writes the raw inputs the way the field would. It runs first, before INPUTS. SIM_ENABLED
// (GVL_Sim) turns it off. SIM_STATION, with SIM_ENABLED off, keeps only the clamp station's half: a bench with
// a real robot (or URSim) on the link and nothing wired to the CC100.
PROGRAM SIM
// ---- body ----
IF SIM_ENABLED THEN
    // The network. Unplugged, the scanner reports the connection down, the robot stops seeing the PLC's
    // words and bits, and the PLC stops getting new words from the robot: they freeze at their last values.
    LINK_bCommError := SIM_bUnplugCable;
    IF NOT SIM_bUnplugCable THEN
        SIM_adiPlcSeen := LINK_adiToRobot;
        SIM_dwBitsSeen := LINK_dwToRobotBits;
    END_IF

    // The robot's I/O actions on input bit registers 0 to 2: each acts as its bit turns on. Only in remote
    // control (in local control the pendant has the robot).
    IF NOT SIM_bLocalMode THEN
        IF SIM_dwBitsSeen.BIT_START AND NOT SIM_dwBitsLast.BIT_START AND NOT SIM_bProtStop AND NOT SIM_bEStop THEN
            // Start: a stopped program starts from the top; a paused one carries on.
            IF SIM_iProgram = 0 THEN
                SIM_iProgram := 1;
                SIM_iRobotStep := 5;
            ELSIF SIM_iProgram = 2 THEN
                SIM_iProgram := 1;
            END_IF
        END_IF
        IF SIM_dwBitsSeen.BIT_STOP AND NOT SIM_dwBitsLast.BIT_STOP THEN
            // Stop: a program stopped mid-move leaves the arm where it is.
            IF SIM_iProgram <> 0 AND (SIM_iRobotStep = 1 OR SIM_iRobotStep = 2) THEN
                SIM_bAwayFromHome := TRUE;
            END_IF
            SIM_iProgram := 0;
        END_IF
        IF SIM_dwBitsSeen.BIT_PAUSE AND NOT SIM_dwBitsLast.BIT_PAUSE AND SIM_iProgram = 1 THEN
            SIM_iProgram := 2;
        END_IF
    END_IF
    SIM_dwBitsLast := SIM_dwBitsSeen;

    // The robot's Dashboard: up unless the switch takes it down; in remote control unless the pendant is
    // switched to local.
    LINK_bDashConnected := NOT SIM_bDashboardDown;
    LINK_bRemoteControl := NOT SIM_bDashboardDown AND NOT SIM_bLocalMode;

    // The robot program stops on its own (someone stopped it on the pendant, or it hit an error).
    IF SIM_bProgramStopped AND NOT SIM_bProgramStoppedLast THEN
        IF SIM_iRobotStep = 1 OR SIM_iRobotStep = 2 THEN
            SIM_bAwayFromHome := TRUE;
        END_IF
        SIM_iProgram := 0;
    END_IF
    SIM_bProgramStoppedLast := SIM_bProgramStopped;

    // What the Dashboard says when asked for the program state.
    IF SIM_bDashboardDown THEN
        LINK_sProgramState := '';
    ELSIF SIM_iProgram = 1 THEN
        LINK_sProgramState := 'PLAYING krc_tending.urp';
    ELSIF SIM_iProgram = 2 THEN
        LINK_sProgramState := 'PAUSED krc_tending.urp';
    ELSE
        LINK_sProgramState := 'STOPPED krc_tending.urp';
    END_IF

    // The robot program, while it plays (stopped or paused, nothing below runs and its words stand still).
    IF SIM_iProgram = 1 THEN
        // Its heartbeat: a thread counts it up every 250 ms.
        TON_SIM_BEAT(IN := NOT TON_SIM_BEAT.Q, PT := SIM_BEAT_TIME);
        IF TON_SIM_BEAT.Q THEN
            SIM_diRobotBeat := SIM_diRobotBeat + 1;
        END_IF

        // The handshake, the way the URScript in robot/ does it.
        TON_SIM_ACK(IN := SIM_iRobotStep = 0 AND SIM_adiPlcSeen[TO_COMMAND] <> CMD_NONE AND NOT SIM_bIgnoreCommands,
                    PT := SIM_ACK_TIME);
        TON_SIM_MOVE(IN := SIM_iRobotStep = 2 AND NOT SIM_bProtStop AND NOT SIM_bEStop AND NOT SIM_bRobotSlow,
                     PT := SIM_MOVE_TIME);
        TON_SIM_START(IN := SIM_iRobotStep = 5, PT := SIM_START_TIME);
        CASE SIM_iRobotStep OF
        5:  // Starting from the top: everything cleared, then check it's at home. Away from home it stops
            // rather than move, and says so in its step.
            LINK_adiFromRobot[FROM_READY] := 0;
            LINK_adiFromRobot[FROM_ACK] := CMD_NONE;
            LINK_adiFromRobot[FROM_DONE] := CMD_NONE;
            LINK_adiFromRobot[FROM_FAULT] := 0;
            IF TON_SIM_START.Q AND SIM_bAwayFromHome THEN
                LINK_adiFromRobot[FROM_ROBOT_STEP] := ROBOT_NOT_HOME;
                SIM_iProgram := 0;
                SIM_iRobotStep := 8;
            ELSIF TON_SIM_START.Q THEN
                SIM_diRobotCommand := CMD_NONE;
                SIM_iRobotStep := 0;
            END_IF
        0:  // At home, ready. A command comes in: answer it.
            IF TON_SIM_ACK.Q THEN
                SIM_diRobotCommand := SIM_adiPlcSeen[TO_COMMAND];
                SIM_iRobotStep := 1;
            END_IF
        1:  // Answered. Wait for the fixture to be clear, then go in. Like the URScript, it waits as long as
            // it takes, even if the PLC drops the command: Stop is how the operator gets it out of here.
            IF SIM_adiPlcSeen[TO_FIXTURE_CLEAR] = 1 THEN
                SIM_iRobotStep := 2;
            END_IF
        2:  // Moving. At the end, the part goes in or comes out, or the gripper misses.
            IF TON_SIM_MOVE.Q THEN
                IF SIM_bGripperMiss THEN
                    SIM_iRobotStep := 9;
                ELSE
                    IF SIM_diRobotCommand = CMD_LOAD THEN
                        DI_bPartPresent := NOT SIM_bPartNotPlaced;
                    ELSIF SIM_diRobotCommand = CMD_UNLOAD THEN
                        DI_bPartPresent := SIM_bPartStuck;
                    END_IF
                    SIM_iRobotStep := 3;
                END_IF
            END_IF
        3:  // Done. Wait for the PLC to drop the command, then clear and go home.
            IF SIM_adiPlcSeen[TO_COMMAND] = CMD_NONE AND NOT SIM_bNoClear THEN
                SIM_diRobotCommand := CMD_NONE;
                SIM_iRobotStep := 0;
            END_IF
        9:  // Faulted. When the PLC drops the command, back home with the fault cleared.
            IF SIM_adiPlcSeen[TO_COMMAND] = CMD_NONE THEN
                SIM_diRobotCommand := CMD_NONE;
                SIM_iRobotStep := 0;
            END_IF
        END_CASE

        // The robot's words, unless the cable is out (or it's starting, or stopped away from home: it wrote those above).
        IF NOT SIM_bUnplugCable AND SIM_iRobotStep <> 5 AND SIM_iRobotStep <> 8 THEN
            LINK_adiFromRobot[FROM_HEARTBEAT] := SIM_diRobotBeat;
            LINK_adiFromRobot[FROM_READY] := BOOL_TO_DINT(SIM_iRobotStep = 0);
            IF SIM_iRobotStep >= 1 AND SIM_iRobotStep <= 3 THEN
                LINK_adiFromRobot[FROM_ACK] := SIM_diRobotCommand;
            ELSE
                LINK_adiFromRobot[FROM_ACK] := CMD_NONE;
            END_IF
            IF SIM_iRobotStep = 3 THEN
                LINK_adiFromRobot[FROM_DONE] := SIM_diRobotCommand;
            ELSE
                LINK_adiFromRobot[FROM_DONE] := CMD_NONE;
            END_IF
            LINK_adiFromRobot[FROM_FAULT] := BOOL_TO_DINT(SIM_iRobotStep = 9);
            // Its step, the numbers the URScript writes as it goes.
            IF SIM_iRobotStep = 0 THEN
                LINK_adiFromRobot[FROM_ROBOT_STEP] := 100;
            ELSIF SIM_iRobotStep = 1 AND SIM_diRobotCommand = CMD_LOAD THEN
                LINK_adiFromRobot[FROM_ROBOT_STEP] := 210;
            ELSIF SIM_iRobotStep = 1 THEN
                LINK_adiFromRobot[FROM_ROBOT_STEP] := 300;
            ELSIF SIM_iRobotStep = 2 AND SIM_diRobotCommand = CMD_LOAD THEN
                LINK_adiFromRobot[FROM_ROBOT_STEP] := 220;
            ELSIF SIM_iRobotStep = 2 THEN
                LINK_adiFromRobot[FROM_ROBOT_STEP] := 310;
            ELSE
                LINK_adiFromRobot[FROM_ROBOT_STEP] := 400;
            END_IF
        END_IF
        IF NOT SIM_bUnplugCable AND SIM_iRobotStep = 5 THEN
            LINK_adiFromRobot[FROM_ROBOT_STEP] := 10;
        END_IF
    END_IF

    // The robot controller's own state in the assembly: mode, power on, program running, and its stops.
    // These don't need the program.
    IF NOT SIM_bUnplugCable THEN
        IF SIM_bArmNotRunning THEN
            LINK_siRobotMode := 5;
        ELSE
            LINK_siRobotMode := ROBOT_RUNNING;
        END_IF
        LINK_dwRobotBits.0 := TRUE;
        LINK_dwRobotBits.1 := SIM_iProgram = 1;
        LINK_dwSafetyBits.2 := SIM_bProtStop;
        LINK_dwSafetyBits.7 := SIM_bEStop;
    END_IF
END_IF

// The bench: a real robot on the link, but no clamp station wired to the CC100. SIM_STATION plays the station
// alone: the part lands in the fixture (or comes out) when the real robot says it's done, and below, the panel,
// the regulator, and the clamp sensor.
IF SIM_STATION AND NOT SIM_ENABLED THEN
    IF LINK_adiFromRobot[FROM_DONE] = CMD_LOAD THEN
        DI_bPartPresent := NOT SIM_bPartNotPlaced;
    ELSIF LINK_adiFromRobot[FROM_DONE] = CMD_UNLOAD THEN
        DI_bPartPresent := SIM_bPartStuck;
    END_IF
END_IF

// The station: in simulation, or on the bench.
IF SIM_ENABLED OR SIM_STATION THEN
    // Part stuck switched back off: someone took the stuck part out of the fixture by hand.
    IF SIM_bPartStuckLast AND NOT SIM_bPartStuck THEN
        DI_bPartPresent := FALSE;
    END_IF
    SIM_bPartStuckLast := SIM_bPartStuck;

    // The panel: Start and Reset aren't pressed (the screen has its own), the Stop wire is healthy unless cut.
    DI_bStartPB := FALSE;
    DI_bResetPB := FALSE;
    DI_bStopPB_NC := NOT SIM_bCutStopWire;

    // The regulator: the pressure heads for whatever the analog output asks for, a share of the gap
    // each scan. Stuck, it only gets part of the way there.
    SIM_rTarget := WORD_TO_REAL(AO_wPressureSet) * PRESSURE_RANGE / AO_FULL_SCALE;
    IF SIM_bRegulatorStuck THEN
        SIM_rTarget := SIM_rTarget * SIM_STUCK_SHARE;
    END_IF
    SIM_rPressure := SIM_rPressure + (SIM_rTarget - SIM_rPressure) * SIM_PRESSURE_LAG;
    AI_wPressure := REAL_TO_WORD(SIM_rPressure * AI_FULL_SCALE / PRESSURE_RANGE);

    // The clamp open sensor: drops as soon as the valve turns on, comes back a moment after it turns off.
    TON_SIM_OPEN(IN := NOT DO_bClampClose, PT := SIM_OPEN_TIME);
    DI_bClampOpen := TON_SIM_OPEN.Q AND NOT SIM_bOpenSensorStuck;
END_IF
