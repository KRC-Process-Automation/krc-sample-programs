// Buffered inputs, buffered outputs, the state machine, and the step timers.
VAR_GLOBAL
	iStep             : E_Step := S0_IDLE;	// The step the machine is in
	iNextStep         : E_Step := S0_IDLE;	// The step it goes to at the end of this scan
	sStateDescription : STRING := 'Idle';	// What the machine is doing, in words, for the HMI
	bStartPB          : BOOL;		// Start pressed, on the panel or the HMI
	bStopPB           : BOOL;		// Stop pressed, on the panel or the HMI
	bResetPB          : BOOL;		// Reset pressed, on the panel or the HMI
	iSpeedFbk         : INT;		// Motor speed feedback in %
	bMotorRun         : BOOL;		// Motor run command
	iSpeedRef         : INT;		// Motor speed reference in %
	bStackGreen       : BOOL;		// Stack light green
	bStackRed         : BOOL;		// Stack light red
	bStackOrange      : BOOL;		// Stack light orange
	bStartLamp        : BOOL;		// Start button lamp
	bStopLamp         : BOOL;		// Stop button lamp
	bResetLamp        : BOOL;		// Reset button lamp
	TON_RAMP_10       : TON;		// On-delay timer: timeout for the ramp to 10 %
	TON_RAMP_25       : TON;		// On-delay timer: timeout for the ramp to 25 %
	TON_RAMP_50       : TON;		// On-delay timer: timeout for the ramp to 50 %
	TON_RAMP_75       : TON;		// On-delay timer: timeout for the ramp to 75 %
	TON_STOPPING      : TON;		// On-delay timer: timeout for the motor to stop
END_VAR
