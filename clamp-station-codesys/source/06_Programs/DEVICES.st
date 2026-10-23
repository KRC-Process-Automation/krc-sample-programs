PROGRAM DEVICES
// ---- body ----
// DEVICES: every output is set here, once, from the step. Nothing here reads a button or another output.
// Each bit is written like a coil: TRUE while its condition is true, FALSE as soon as it isn't.

// Clamp valve: on in Clamping.
bClampClose := iStep = S4_CLAMPING;

// Pressure setpoint to the regulator: the HMI setpoint in Clamping, 0 the rest of the time.
IF iStep = S4_CLAMPING THEN
    rPressureSet := HMI_rPressureSet;
ELSE
    rPressureSet := 0.0;
END_IF

// Stack light green: ready or cycling.
bStackGreen := iStep = S3_READY OR iStep = S4_CLAMPING OR iStep = S5_OPENING;

// Stack light red: not ready to cycle. Written from the steps, never as "not green".
bStackRed := iStep = S0_IDLE OR iStep = S1_NOT_READY OR iStep = S2_RESET OR iStep = S6_FAULT;

// Stack light orange: faulted.
bStackOrange := iStep = S6_FAULT;

// Stop lamp: lit when Stop does something, in Clamping.
bStopLamp := iStep = S4_CLAMPING;

// Reset lamp: lit when the machine is faulted and needs a reset.
bResetLamp := iStep = S6_FAULT;
