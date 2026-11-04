// The steps, a thousand apart for the states, a hundred apart for the steps inside a state.
TYPE E_Step :
(
	S0_IDLE           :=    0,	// Idle: powered up and at rest. Goes straight to Not Ready
	S1_NOT_READY      := 1000,	// Not Ready: waiting for the link, the robot, an empty fixture, Stop not pressed
	S2_RESET          := 2000,	// Reset: clears a fault or a stop, waits for Reset to be released
	S3_READY          := 3000,	// Ready: waiting for Start
	S3_STARTING       := 3100,	// Ready: Start pressed, the robot program is starting (play)
	S4_LOAD_REQUEST   := 4000,	// Load: command 1 out, waiting for the robot to acknowledge
	S4_LOADING        := 4100,	// Load: the robot is putting a part in the fixture
	S4_LOAD_CLEAR     := 4200,	// Load: command back to 0, waiting for the robot to clear its answer
	S5_CLAMPING       := 5000,	// Clamping: valve on, setpoint out, waiting for pressure
	S5_HOLDING        := 5100,	// Clamping: at pressure, holding for the hold time
	S6_OPENING        := 6000,	// Opening: valve off, waiting for the clamp to read open
	S7_UNLOAD_REQUEST := 7000,	// Unload: command 2 out, waiting for the robot to acknowledge
	S7_UNLOADING      := 7100,	// Unload: the robot is taking the part out
	S7_UNLOAD_CLEAR   := 7200,	// Unload: command back to 0, waiting for the robot to clear its answer
	S8_FAULT          := 8000,	// Fault: waiting for Reset
	S8_STOPPED        := 8100,	// Stopped: Stop pressed, the robot program stopped (stop), waiting for Reset
	S9_PAUSED         := 9000,	// Paused: Pause pressed, the robot program paused (pause), waiting for Start
	S9_RESUMING       := 9100 	// Paused: Start pressed, the robot program resuming (play)
) INT;
END_TYPE
