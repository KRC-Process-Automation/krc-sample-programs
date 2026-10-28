PROGRAM DEVICES
// ---- body ----
// DEVICES: every output is set here, once, from the step, like a coil: assigned its condition every scan,
// TRUE while the condition is true and FALSE as soon as it isn't.

// The permissives: one line each, what each one waits for.
aPermissives[PERM_DRIVE_READY].bSatisfied := bDriveReady;
aPermissives[PERM_DRIVE_REMOTE].bSatisfied := bDriveRemote;
aPermissives[PERM_STOP_RELEASED].bSatisfied := NOT bStopPB;
aPermissives[PERM_MOTOR_STOPPED].bSatisfied := iSpeedFbk <= SPEED_STOPPED;

// Motor run: on while running and while stopping, so the drive brings the motor down under control.
bMotorRun := iStep >= S4_RAMP_10 AND iStep <= S5_STOPPING;

// Speed reference: one CASE, so it is written in one place and every step gets a value.
CASE iStep OF
S4_RAMP_10:
    iSpeedRef := SPEED_10;
S4_RAMP_25:
    iSpeedRef := SPEED_25;
S4_RAMP_50:
    iSpeedRef := SPEED_50;
S4_RAMP_75, S4_AT_SPEED:
    iSpeedRef := SPEED_75;
ELSE
    iSpeedRef := 0;
END_CASE

// Stack light green: running.
bStackGreen := iStep >= S4_RAMP_10 AND iStep <= S4_AT_SPEED;

// Stack light red: not running. Written from the steps, never from another output.
bStackRed := iStep < S4_RAMP_10 OR iStep >= S5_STOPPING;

// The flasher: a timer that restarts itself. Its done bit is on for one scan every T_FLASH, and each
// time it is, the flash flips.
TON_Flash(IN := NOT TON_Flash.Q, PT := T_FLASH);
IF TON_Flash.Q THEN
    bFlash := NOT bFlash;
END_IF

// Stack light orange, the alarm light: flashing while an alarm or warning hasn't been acknowledged,
// steady while one is still on the list.
bStackOrange := (bUnacknowledged AND bFlash) OR ((bAlarmOnList OR bWarningOnList) AND NOT bUnacknowledged);

// The button lamps: lit when the button can be pressed.
bStartLamp := iStep = S3_READY;
bStopLamp := iStep >= S4_RAMP_10 AND iStep <= S4_AT_SPEED;
bResetLamp := iStep = S6_FAULT;
bAckLamp := bUnacknowledged;
