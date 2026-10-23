// Named numbers the program uses, so no bare number appears in the logic.
VAR_GLOBAL CONSTANT
	AI_FULL_SCALE    : REAL := 32760.0;	// CC100 analog input raw count at 10 V (WAGO manual, section 9.4)
	AO_FULL_SCALE    : REAL := 32767.0;	// CC100 analog output raw count for 10 V (WAGO manual, section 9.4)
	PRESSURE_RANGE   : REAL := 100.0;	// psi at 10 V, for the sensor and the regulator
	PRESSURE_BAND    : REAL := 2.0;	// psi: within this much of the setpoint counts as at pressure
END_VAR
