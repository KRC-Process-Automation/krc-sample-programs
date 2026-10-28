// The steps. The thousands give the state, the hundreds give the sub-step inside it
// (the four ramp steps and At Speed all belong to Running).
TYPE E_Step :
(
	S0_IDLE      :=    0,	// Idle: powered up and at rest. Goes straight to Not Ready
	S1_NOT_READY := 1000,	// Not Ready: waiting for every permissive, and says which one it is waiting for
	S3_READY     := 3000,	// Ready: waiting for Start
	S4_RAMP_10   := 4000,	// Running: ramping to 10 %
	S4_RAMP_25   := 4100,	// Running: ramping to 25 %
	S4_RAMP_50   := 4200,	// Running: ramping to 50 %
	S4_RAMP_75   := 4300,	// Running: ramping to 75 %
	S4_AT_SPEED  := 4400,	// Running: at speed, 75 %
	S5_STOPPING  := 5000,	// Stopping: speed reference 0, waiting for the motor to stop
	S6_FAULT     := 6000 	// Fault: waiting for the alarm list to clear (Reset clears what it can), then Not Ready
) INT;
END_TYPE
