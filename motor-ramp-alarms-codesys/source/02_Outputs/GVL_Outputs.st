// Raw outputs, in CC100 terminal order. Mapped to the hardware in the CC100's I/O mapping tab.
// Only OUTPUTS writes these.
VAR_GLOBAL
	DO_bMotorRun     : BOOL;	// X5 DO1 Drive run command
	DO_bStackGreen   : BOOL;	// X5 DO2 Stack light green
	DO_bStackRed     : BOOL;	// X5 DO3 Stack light red
	DO_bStackOrange  : BOOL;	// X5 DO4 Stack light orange: the alarm light
	AO_wSpeedRef     : WORD;	// X6 AO1 Speed reference to the drive, 0..32767 = 0..10 V = 0..100 %
END_VAR
