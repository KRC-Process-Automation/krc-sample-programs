PROGRAM STATE_MACHINE
// ---- body ----
// STATE_MACHINE: decides which step the machine is in. One CASE on the step, one branch per step.
// Inside a branch, each exit is one IF: the reason it leaves, then the next step into iNextStep and what
// the machine will be doing, for the HMI. The step only changes on the last line, so every line in one
// scan sees the same step.

// The step timers. Each runs only while its step is active, so it starts from zero every time.
TON_CLAMP(IN := iStep = S4_CLAMPING);
TON_OPEN(IN := iStep = S5_OPENING);

CASE iStep OF

S0_IDLE:
    // Idle: powered up and at rest. Go to Not Ready.
    iNextStep := S1_NOT_READY;
    sStateDescription := 'Not Ready - open the clamp, hands off';

S1_NOT_READY:
    // Not Ready: the clamp reads open, both hands are off, and Stop isn't pressed. Ready.
    // Waiting for both hands off means holding the buttons down can't start the next cycle.
    IF bClampOpen AND NOT bLeftHandPB AND NOT bRightHandPB AND NOT bStopPB THEN
        iNextStep := S3_READY;
        sStateDescription := 'Ready - press both hand buttons';
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
        sStateDescription := 'Not Ready - open the clamp, hands off';
    END_IF

S3_READY:
    // Ready: both hand buttons pressed. Close the clamp.
    IF bLeftHandPB AND bRightHandPB THEN
        iNextStep := S4_CLAMPING;
        sStateDescription := 'Clamping - building pressure';
    END_IF
    // Ready: Stop pressed. Back to Not Ready. Written last, so Stop wins.
    IF bStopPB THEN
        iNextStep := S1_NOT_READY;
        sStateDescription := 'Not Ready - Stop pressed';
    END_IF

S4_CLAMPING:
    // Clamping: the pressure is within the band of the setpoint. Open the clamp.
    IF rPressure >= HMI_rPressureSet - PRESSURE_BAND THEN
        iNextStep := S5_OPENING;
        sStateDescription := 'Opening - at pressure';
    END_IF
    // Clamping: Stop pressed. Open the clamp, no fault.
    IF bStopPB THEN
        iNextStep := S5_OPENING;
        sStateDescription := 'Opening - Stop pressed';
    END_IF
    // Clamping: the timeout ran out and the pressure is still short. Fault.
    IF TON_CLAMP.Q AND rPressure < HMI_rPressureSet - PRESSURE_BAND THEN
        iNextStep := S6_FAULT;
        sStateDescription := 'Fault - pressure not reached in time';
    END_IF
    // Clamping: a hand came off the buttons. Fault. Written last, so it wins.
    IF NOT bLeftHandPB OR NOT bRightHandPB THEN
        iNextStep := S6_FAULT;
        sStateDescription := 'Fault - a hand came off the buttons';
    END_IF

S5_OPENING:
    // Opening: the clamp reads open. Back to Not Ready, which waits for hands off.
    IF bClampOpen THEN
        iNextStep := S1_NOT_READY;
        sStateDescription := 'Not Ready - open the clamp, hands off';
    END_IF
    // Opening: the timeout ran out and the clamp still doesn't read open. Fault.
    IF TON_OPEN.Q AND NOT bClampOpen THEN
        iNextStep := S6_FAULT;
        sStateDescription := 'Fault - clamp did not open in time';
    END_IF

S6_FAULT:
    // Fault: Reset pressed. Go through Reset, then Not Ready.
    IF bResetPB THEN
        iNextStep := S2_RESET;
        sStateDescription := 'Reset - release Reset';
    END_IF
END_CASE

// Take the next step. This is the only place the step changes.
iStep := iNextStep;
