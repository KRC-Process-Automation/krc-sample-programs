// Raw outputs, in CC100 terminal order. Mapped to the hardware in the CC100's I/O mapping tab.
// Only OUTPUTS writes these.
VAR_GLOBAL
	DO_bClampClose   : BOOL;	// X5.DO1 Clamp valve: on closes the clamp, off lets the spring open it
	DO_bStackGreen   : BOOL;	// X5.DO2 Stack light green
	DO_bStackRed     : BOOL;	// X5.DO3 Stack light red
	DO_bStackOrange  : BOOL;	// X5.DO4 Stack light orange
	AO_wPressureSet  : WORD;	// X6.AO1 Pressure setpoint to the regulator, 0..32767 = 0..10 V = 0..100 psi
END_VAR
