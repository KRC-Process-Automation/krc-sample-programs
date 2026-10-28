// SIMULATION ONLY. Test code: it never goes on a real machine.
VAR_GLOBAL CONSTANT
	SIM_ENABLED      : BOOL := TRUE;	// TRUE in simulation. Set FALSE before downloading to a real CC100
	SIM_RAMP_RATE    : REAL := 0.5;	// How fast the motor's speed changes, in % per scan (25 % a second at 20 ms)
	SIM_STALL_SPEED  : REAL := 20.0;	// With Motor stall, the motor can't get past this speed, in %
	SIM_DROOP        : REAL := 15.0;	// With Speed droop, the motor runs this much slow at speed, in %
END_VAR
VAR_GLOBAL
	SIM_bDriveNotReady : BOOL;	// Break switch: the drive's Ready relay drops (a drive fault)
	SIM_bDriveLocal    : BOOL;	// Break switch: the drive is switched to local (its own keypad)
	SIM_bEStop         : BOOL;	// Break switch: the E-stop is pressed
	SIM_bStall         : BOOL;	// Break switch: the motor stalls at SIM_STALL_SPEED
	SIM_bWontStop      : BOOL;	// Break switch: the motor keeps turning after the run command drops
	SIM_bDroop         : BOOL;	// Break switch: a heavy load, the motor runs SIM_DROOP slow at speed
	SIM_bCutStopWire   : BOOL;	// Break switch: the Stop button's wire is cut
	SIM_bStartStuck    : BOOL;	// Break switch: the Start button is stuck down
	SIM_rTarget        : REAL;	// The speed the drive is heading for, in %
	SIM_rSpeed         : REAL;	// The speed the simulated motor has, in %
END_VAR
