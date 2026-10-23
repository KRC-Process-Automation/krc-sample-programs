// SAMPLE PROGRAM: two-hand clamp station state machine. KRC (Kurtin Robotics), written as a teaching example.
// The machine: the operator holds both hand buttons and the clamp closes. A proportional regulator sets
// how hard it squeezes, from a pressure setpoint on the HMI; a pressure sensor reads what it gets. At the
// setpoint, the clamp opens and the cycle is done. It faults if a hand comes off while clamping, if the
// pressure isn't reached in time, or if the clamp doesn't read open in time. Stop while clamping opens
// it without a fault; Reset clears a fault.
// NOT A SAFETY FUNCTION. On a real clamp that can catch a hand, the two-hand control is a safety-rated
// two-hand device or a safety controller, not this logic.
// How it is laid out: MainTask calls SIM (simulation only), then INPUTS, STATE_MACHINE, DEVICES, OUTPUTS,
// every scan. INPUTS reads every input into a program tag. STATE_MACHINE decides the step. DEVICES sets
// every output from the step. OUTPUTS writes every output to the hardware and to the HMI.
PROGRAM INPUTS
// ---- body ----
// INPUTS: every input is read here and nowhere else.
// Hand buttons.
bLeftHandPB := DI_bLeftHandPB;
bRightHandPB := DI_bRightHandPB;

// Stop is wired normally closed: the input is on while nobody presses it, so a broken wire reads the
// same as pressing Stop. This is the only place it gets turned around. Or the Stop button on the HMI.
bStopPB := NOT DI_bStopPB_NC OR HMI_bStopPB;

// Reset: the panel button or the HMI button.
bResetPB := DI_bResetPB OR HMI_bResetPB;

// Clamp open sensor.
bClampOpen := DI_bClampOpen;

// Pressure: the CC100 reads 0 to 10 V as 0 to 32760. Scaled once, here, to psi, so the rest of the
// program works in psi. Done as a REAL, because 32760 x 100 is too big for a 16-bit number.
rPressure := WORD_TO_REAL(AI_wPressure) * PRESSURE_RANGE / AI_FULL_SCALE;

// The two timeouts from the HMI, in seconds, as each timer's preset.
TON_CLAMP.PT := T#1S * HMI_iClampTimeout;
TON_OPEN.PT := T#1S * HMI_iOpenTimeout;
