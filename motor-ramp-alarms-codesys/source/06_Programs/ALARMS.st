PROGRAM ALARMS
VAR
	i            : INT;	// The alarm being looked at
	bAnyAlarm    : BOOL;	// Rollup while the list is scanned
	bAnyWarning  : BOOL;	// Rollup while the list is scanned
	bAnyUnacked  : BOOL;	// Rollup while the list is scanned
END_VAR
// ---- body ----
// ALARMS: times every step that waits on the machine, wires each alarm's trigger, and runs the alarm
// list. It runs after STATE_MACHINE, so it times the step the machine is in now. Reset is handled here: its
// press acknowledges the alarms, and once no ALARM-level alarm is left on the list, the state machine
// leaves Fault on its next scan.

// The step timeouts. If a step waits on the machine, it gets a timeout; if it waits on a person (Not
// Ready, Ready), it doesn't. Each timer runs only while its step is active, so it starts from zero
// every time the step starts.
TON_RAMP_10(IN := iStep = S4_RAMP_10, PT := T#1S * HMI_iRampTimeout);
TON_RAMP_25(IN := iStep = S4_RAMP_25, PT := T#1S * HMI_iRampTimeout);
TON_RAMP_50(IN := iStep = S4_RAMP_50, PT := T#1S * HMI_iRampTimeout);
TON_RAMP_75(IN := iStep = S4_RAMP_75, PT := T#1S * HMI_iRampTimeout);
TON_STOPPING(IN := iStep = S5_STOPPING, PT := T#1S * HMI_iStopTimeout);

// The speed feedback, watched the whole time the motor is at speed, not just on the way up: further off
// the reference than SPEED_DEVIATION, for T_SPEED_DEVIATION.
TON_SpeedDeviation(IN := iStep = S4_AT_SPEED AND ABS(iSpeedRef - iSpeedFbk) > SPEED_DEVIATION,
                   PT := T_SPEED_DEVIATION);

// Each alarm's trigger: one line each, the condition right now, written against the value it watches.
aAlarms[ALM_ESTOP].bTriggered := NOT bEStopOK;
aAlarms[ALM_DRIVE_DROPPED].bTriggered := NOT bDriveReady AND iStep >= S4_RAMP_10 AND iStep <= S5_STOPPING;
aAlarms[ALM_DRIVE_LOCAL].bTriggered := NOT bDriveRemote AND iStep >= S4_RAMP_10 AND iStep <= S5_STOPPING;
aAlarms[ALM_RAMP_TIMEOUT].bTriggered := (TON_RAMP_10.Q AND iSpeedFbk < SPEED_10)
                                     OR (TON_RAMP_25.Q AND iSpeedFbk < SPEED_25)
                                     OR (TON_RAMP_50.Q AND iSpeedFbk < SPEED_50)
                                     OR (TON_RAMP_75.Q AND iSpeedFbk < SPEED_75);
aAlarms[ALM_STOP_TIMEOUT].bTriggered := TON_STOPPING.Q AND iSpeedFbk > SPEED_STOPPED;
aAlarms[ALM_SPEED_DEVIATION].bTriggered := TON_SpeedDeviation.Q;
aAlarms[ALM_SIM_MODE].bTriggered := SIM_ENABLED;

// The alarm list. Every alarm lives the same way: it goes on the list when it triggers, the press of ACK
// or Reset acknowledges it, and it comes off once it is acknowledged AND its trigger is gone.
bAnyAlarm := FALSE;
bAnyWarning := FALSE;
bAnyUnacked := FALSE;
FOR i := 1 TO ALARM_COUNT DO
    // On: it triggered and isn't on the list yet. Not acknowledged, and it keeps the step it came on in
    // (the step the scan started in, before an override sent the machine to Fault).
    IF aAlarms[i].bTriggered AND NOT aAlarms[i].bOnList THEN
        aAlarms[i].bOnList := TRUE;
        aAlarms[i].bAcked := FALSE;
        aAlarms[i].iStepRaised := iStepAtScanStart;
    END_IF
    // Acknowledged: on the press of ACK or Reset (the one-shots).
    IF aAlarms[i].bOnList AND (rtAck.Q OR rtReset.Q) THEN
        aAlarms[i].bAcked := TRUE;
    END_IF
    // Off: acknowledged and the trigger gone.
    IF aAlarms[i].bOnList AND aAlarms[i].bAcked AND NOT aAlarms[i].bTriggered THEN
        aAlarms[i].bOnList := FALSE;
    END_IF
    // What the rest of the program needs to know about the list.
    bAnyAlarm := bAnyAlarm OR (aAlarms[i].bOnList AND aAlarms[i].eLevel = LVL_ALARM);
    bAnyWarning := bAnyWarning OR (aAlarms[i].bOnList AND aAlarms[i].eLevel = LVL_WARNING);
    bAnyUnacked := bAnyUnacked OR (aAlarms[i].bOnList AND NOT aAlarms[i].bAcked AND aAlarms[i].eLevel >= LVL_WARNING);
END_FOR
bAlarmOnList := bAnyAlarm;
bWarningOnList := bAnyWarning;
bUnacknowledged := bAnyUnacked;
