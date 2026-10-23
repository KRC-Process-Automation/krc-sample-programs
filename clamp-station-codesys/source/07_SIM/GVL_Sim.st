// SIMULATION ONLY. Test code: it never goes on a real machine.
VAR_GLOBAL CONSTANT
	SIM_ENABLED      : BOOL := TRUE;	// TRUE in simulation. Set FALSE before downloading to a real CC100
	SIM_PRESSURE_LAG : REAL := 0.03;	// Share of the gap to the setpoint the pressure closes each scan
	SIM_STUCK_SHARE  : REAL := 0.5;	// With Regulator stuck, the pressure only gets this share of the way
	SIM_OPEN_TIME    : TIME := T#500MS;	// How long the clamp takes to read open after the valve drops
END_VAR
VAR_GLOBAL
	SIM_bLeftHand         : BOOL;	// Screen switch: left hand on its button
	SIM_bRightHand        : BOOL;	// Screen switch: right hand on its button
	SIM_bRegulatorStuck   : BOOL;	// Break switch: the pressure stops short of the setpoint
	SIM_bOpenSensorStuck  : BOOL;	// Break switch: the clamp never reads open
	SIM_bCutStopWire      : BOOL;	// Break switch: the Stop button's wire is cut
	SIM_rPressure         : REAL;	// The pressure the simulated clamp has, in psi
	SIM_rTarget           : REAL;	// The pressure the regulator is heading for, in psi
	TON_SIM_OPEN          : TON;	// The clamp opening after the valve drops
END_VAR
