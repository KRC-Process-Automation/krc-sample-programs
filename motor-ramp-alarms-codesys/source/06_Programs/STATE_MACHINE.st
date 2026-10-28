PROGRAM STATE_MACHINE
VAR
	i            : INT;	// The permissive being looked at
	bAllMet      : BOOL;	// Rollup while the permissives are scanned
	sWaitingFor  : STRING(30);	// The first permissive not met
END_VAR
// ---- body ----
// STATE_MACHINE: decides which step the machine is in. The steps are the values of the enum E_Step
// (03_States). iStep is the step the machine is in; each exit puts the next step into iNextStep, and the
// step only changes on the last line, so every line in one scan sees the same step.

// The permissives: everything Ready waits for, one line each in the permissive table (GVL_Alarms), each
// wired in DEVICES. This rollup ANDs them, and keeps the first one not met so Not Ready can name it.
bAllMet := TRUE;
sWaitingFor := '';
FOR i := 1 TO PERMISSIVE_COUNT DO
    IF bAllMet AND NOT aPermissives[i].bSatisfied THEN
        sWaitingFor := aPermissives[i].sText;
    END_IF
    bAllMet := bAllMet AND aPermissives[i].bSatisfied;
END_FOR
bPermissivesOK := bAllMet;

// Every state writes what it is doing, in words, for the screen.
CASE iStep OF

S0_IDLE:
    // Idle: powered up and at rest. Go to Not Ready.
    sStateDescription := 'Idle';
    iNextStep := S1_NOT_READY;

S1_NOT_READY:
    // Not Ready never just says Not Ready: it names the first permissive it is waiting for.
    IF bPermissivesOK THEN
        sStateDescription := 'Not Ready - every permissive met';
    ELSE
        sStateDescription := CONCAT('Not Ready - waiting for: ', sWaitingFor);
    END_IF
    // Every permissive met: ready.
    IF bPermissivesOK THEN
        iNextStep := S3_READY;
    END_IF

S3_READY:
    sStateDescription := 'Ready - press Start';
    // Start pressed: the one-shot, so a held Start doesn't count. Start the motor at 10 %.
    IF rtStart.Q THEN
        iNextStep := S4_RAMP_10;
    END_IF
    // A permissive dropped: back to Not Ready, which says which one. Last, so it wins over Start.
    IF NOT bPermissivesOK THEN
        iNextStep := S1_NOT_READY;
    END_IF

S4_RAMP_10:
    sStateDescription := 'Running - ramping to 10 %';
    // The speed feedback has reached 10 %: next step. Its timeout is an alarm now (ALARMS).
    IF iSpeedFbk >= SPEED_10 THEN
        iNextStep := S4_RAMP_25;
    END_IF

S4_RAMP_25:
    sStateDescription := 'Running - ramping to 25 %';
    IF iSpeedFbk >= SPEED_25 THEN
        iNextStep := S4_RAMP_50;
    END_IF

S4_RAMP_50:
    sStateDescription := 'Running - ramping to 50 %';
    IF iSpeedFbk >= SPEED_50 THEN
        iNextStep := S4_RAMP_75;
    END_IF

S4_RAMP_75:
    sStateDescription := 'Running - ramping to 75 %';
    IF iSpeedFbk >= SPEED_75 THEN
        iNextStep := S4_AT_SPEED;
    END_IF

S4_AT_SPEED:
    // At speed: no exit of its own. It holds here until Stop, below.
    sStateDescription := 'Running - at speed, 75 %';

S5_STOPPING:
    sStateDescription := 'Stopping - waiting for the motor to stop';
    // The motor has stopped. Back to Not Ready.
    IF iSpeedFbk <= SPEED_STOPPED THEN
        iNextStep := S1_NOT_READY;
    END_IF

S6_FAULT:
    // Fault: the alarm list says why. The state machine carries no alarm text, only what it is doing.
    sStateDescription := 'Fault - see the alarm list, then press Reset';
    // Reset is handled in ALARMS: its press tries to clear every latched alarm. One whose cause is gone
    // comes off the list; one still latched means its fault is still active. Once no ALARM-level alarm is
    // left, Fault is over: straight to Not Ready, which checks every permissive again before Ready.
    IF NOT bAlarmOnList THEN
        iNextStep := S1_NOT_READY;
    END_IF

ELSE
    // A step that isn't in the list can't happen, but if it ever does, fail safe.
    sStateDescription := 'Fault - unknown step';
    iNextStep := S6_FAULT;
END_CASE

// Stop, out of any running step: written once for the whole Running state, not in every ramp step.
IF iStep >= S4_RAMP_10 AND iStep <= S4_AT_SPEED AND bStopPB THEN
    iNextStep := S5_STOPPING;
END_IF

// The global overrides, after everything else, so they always win the scan.
// 1. The E-stop circuit is open.
IF NOT bEStopOK THEN
    iNextStep := S6_FAULT;
END_IF
// 2. An ALARM-level alarm is on the list. It holds the machine in Fault until it is acknowledged and gone.
IF bAlarmOnList THEN
    iNextStep := S6_FAULT;
END_IF

// Take the next step. This is the only place the step changes. ALARMS runs after this, so keep the step
// the scan started in: an alarm's line names where the machine was, not the Fault it was just sent to.
iStepAtScanStart := iStep;
iStep := iNextStep;
