// SIM: SIMULATION ONLY. Test code: it never goes on a real machine.
// It plays the drive, the motor, and the panel's wiring, so the program can be tested with nothing wired.
// It runs first, before INPUTS, and writes only the raw inputs, the way the field would. SIM_ENABLED
// (GVL_Sim) turns it off.
PROGRAM SIM
// ---- body ----
IF SIM_ENABLED THEN
    // The panel's wiring and the drive's relays, healthy unless a break switch says otherwise.
    DI_bStartPB := SIM_bStartStuck;
    DI_bStopPB_NC := NOT SIM_bCutStopWire;
    DI_bDriveReady := NOT SIM_bDriveNotReady;
    DI_bDriveRemote := NOT SIM_bDriveLocal;
    DI_bEStopOK := NOT SIM_bEStop;

    // The drive: it turns the motor toward the speed reference while it has its run command, is ready,
    // and the E-stop circuit is closed (the safety relay takes its power otherwise).
    IF DO_bMotorRun AND DI_bDriveReady AND DI_bEStopOK THEN
        SIM_rTarget := DINT_TO_REAL(WORD_TO_DINT(AO_wSpeedRef)) * 100.0 / DINT_TO_REAL(AO_FULL_SCALE);
    ELSE
        SIM_rTarget := 0.0;
    END_IF
    IF SIM_bStall THEN
        SIM_rTarget := MIN(SIM_rTarget, SIM_STALL_SPEED);
    END_IF
    IF SIM_bDroop AND SIM_rTarget > 70.0 THEN
        SIM_rTarget := SIM_rTarget - SIM_DROOP;
    END_IF

    // The motor: speeds up or slows down toward the target at SIM_RAMP_RATE a scan. With Won't stop, it
    // never slows down.
    IF SIM_rSpeed < SIM_rTarget THEN
        SIM_rSpeed := MIN(SIM_rSpeed + SIM_RAMP_RATE, SIM_rTarget);
    ELSIF NOT SIM_bWontStop THEN
        SIM_rSpeed := MAX(SIM_rSpeed - SIM_RAMP_RATE, SIM_rTarget);
    END_IF
    AI_wSpeedFbk := REAL_TO_WORD(SIM_rSpeed * DINT_TO_REAL(AI_FULL_SCALE) / 100.0);
END_IF
