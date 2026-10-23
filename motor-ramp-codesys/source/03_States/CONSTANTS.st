// Named numbers the program uses, so no bare number appears in the logic.
VAR_GLOBAL CONSTANT
	SPEED_10       : INT := 10;	// Ramp speed 1, in %
	SPEED_25       : INT := 25;	// Ramp speed 2, in %
	SPEED_50       : INT := 50;	// Ramp speed 3, in %
	SPEED_75       : INT := 75;	// Ramp speed 4 and running speed, in %
	SPEED_STOPPED  : INT := 2;	// At or below this speed, in %, the motor counts as stopped
	AI_FULL_SCALE  : DINT := 32760;	// CC100 analog input at 10 V, in raw counts (WAGO CC100 manual, 9.4)
	AO_FULL_SCALE  : DINT := 32767;	// CC100 analog output count for 10 V (WAGO CC100 manual, 9.4)
END_VAR
