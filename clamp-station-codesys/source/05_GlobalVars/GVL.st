// Buffered inputs, buffered outputs, the state machine, and the step timers.
VAR_GLOBAL
	iStep             : E_Step := S0_IDLE;	// The step the machine is in
	iNextStep         : E_Step := S0_IDLE;	// The step it goes to at the end of this scan
	sStateDescription : STRING := 'Idle';	// What the machine is doing, in words, for the HMI
	bLeftHandPB       : BOOL;		// Left hand button pressed
	bRightHandPB      : BOOL;		// Right hand button pressed
	bStopPB           : BOOL;		// Stop pressed, on the panel or the HMI (or the Stop wire cut)
	bResetPB          : BOOL;		// Reset pressed, on the panel or the HMI
	bClampOpen        : BOOL;		// The clamp reads open
	rPressure         : REAL;		// Clamp pressure in psi
	bClampClose       : BOOL;		// Clamp valve on
	rPressureSet      : REAL;		// Pressure setpoint going to the regulator, in psi
	bStackGreen       : BOOL;		// Stack light green
	bStackRed         : BOOL;		// Stack light red
	bStackOrange      : BOOL;		// Stack light orange
	bStopLamp         : BOOL;		// Stop button lamp
	bResetLamp        : BOOL;		// Reset button lamp
	TON_CLAMP         : TON;		// On-delay timer: timeout for Clamping to reach pressure
	TON_OPEN          : TON;		// On-delay timer: timeout for Opening to read open
END_VAR
