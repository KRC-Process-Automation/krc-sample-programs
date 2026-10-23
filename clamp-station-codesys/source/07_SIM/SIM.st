// SIM: SIMULATION ONLY. Test code: it never goes on a real machine.
// It plays the machine, so the program can be tested with nothing wired. It runs first, before INPUTS,
// and writes only the raw inputs, the way the field would. SIM_ENABLED (GVL_Sim) turns it off.
PROGRAM SIM
// ---- body ----
IF SIM_ENABLED THEN
    // The operator's hands, from the two switches on the screen. A mouse can't hold two buttons at once.
    DI_bLeftHandPB := SIM_bLeftHand;
    DI_bRightHandPB := SIM_bRightHand;

    // The Stop wire: healthy, so the normally closed input is on, unless it's cut.
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
