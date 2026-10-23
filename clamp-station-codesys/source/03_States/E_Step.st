// The steps, a thousand apart, so steps inside a state can be added later without renumbering.
TYPE E_Step :
(
	S0_IDLE      :=    0,	// Idle: powered up and at rest. Goes straight to Not Ready
	S1_NOT_READY := 1000,	// Not Ready: waiting for the clamp to read open, both hands off, Stop not pressed
	S2_RESET     := 2000,	// Reset: clears a fault, waits for Reset to be released
	S3_READY     := 3000,	// Ready: waiting for both hand buttons
	S4_CLAMPING  := 4000,	// Clamping: valve on, setpoint out, waiting for pressure
	S5_OPENING   := 5000,	// Opening: valve off, waiting for the clamp to read open
	S6_FAULT     := 6000 	// Fault: waiting for Reset
) INT;
END_TYPE
