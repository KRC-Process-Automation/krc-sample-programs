PROGRAM DEVICES
// ---- body ----
// Rung 1. DEVICES: every output is set here, once, from the step. Nothing below reads a button or
// another output.
//
// How an output is written: each one is assigned its condition, every scan, like a coil. bStackGreen
// := (condition); is TRUE while the condition is true and FALSE as soon as it isn't, so no
// IF ... ELSE is needed. An IF with no ELSE would only ever write TRUE and leave the bit on (a latch).
// The speed reference rungs below do use IF, like the ladder's copy rungs: between them they cover
// every step, so iSpeedRef always gets written.
//
// Motor run: on while running and while stopping, so the drive brings the motor down under control.
bMotorRun := iStep >= S4_RAMP_10 AND iStep <= S5_STOPPING;

// Rung 2. Speed reference 10 %: ramp to 10 %.
IF iStep = S4_RAMP_10 THEN
    iSpeedRef := SPEED_10;
END_IF

// Rung 3. Speed reference 25 %: ramp to 25 %.
IF iStep = S4_RAMP_25 THEN
    iSpeedRef := SPEED_25;
END_IF

// Rung 4. Speed reference 50 %: ramp to 50 %.
IF iStep = S4_RAMP_50 THEN
    iSpeedRef := SPEED_50;
END_IF

// Rung 5. Speed reference 75 %: ramp to 75 %.
IF iStep = S4_RAMP_75 THEN
    iSpeedRef := SPEED_75;
END_IF

// Rung 6. Speed reference 75 %: at speed.
IF iStep = S4_AT_SPEED THEN
    iSpeedRef := SPEED_75;
END_IF

// Rung 7. Speed reference 0 below Running.
IF iStep < S4_RAMP_10 THEN
    iSpeedRef := 0;
END_IF

// Rung 8. Speed reference 0 from Stopping up. In Stopping the drive ramps down to 0.
IF iStep >= S5_STOPPING THEN
    iSpeedRef := 0;
END_IF

// Rung 9. Stack light green: running.
bStackGreen := iStep >= S4_RAMP_10 AND iStep <= S4_AT_SPEED;

// Rung 10. Stack light red: not running, so below Running or from Stopping up. Written from the steps,
// like every output, never from another output.
bStackRed := iStep < S4_RAMP_10 OR iStep >= S5_STOPPING;

// Rung 11. Stack light orange: faulted.
bStackOrange := iStep = S6_FAULT;

// Rung 12. Start lamp: lit when Start can be pressed, in Ready.
bStartLamp := iStep = S3_READY;

// Rung 13. Stop lamp: lit when Stop can be pressed, while running. It goes out once Stop has been
// pressed.
bStopLamp := iStep >= S4_RAMP_10 AND iStep <= S4_AT_SPEED;

// Rung 14. Reset lamp: lit when the machine is faulted and needs a reset.
bResetLamp := iStep = S6_FAULT;
