// Raw outputs, in CC100 terminal order. Mapped to the hardware in the CC100's I/O mapping tab.
// Only OUTPUTS writes these.
VAR_GLOBAL
	DO_bMotorRun     : BOOL;	// X5 DO1 Motor drive run command
	DO_bStackGreen   : BOOL;	// X5 DO2 Stack light green
	DO_bStackRed     : BOOL;	// X5 DO3 Stack light red
	DO_bStartLamp    : BOOL;	// X5 DO4 Start push button lamp
	AO_wSpeedRef     : WORD;	// X6 AO1 Motor speed reference to the drive, 0..32767 = 0..10 V = 0..100 %
END_VAR
