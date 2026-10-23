// Raw inputs, in CC100 terminal order. Mapped to the hardware in the CC100's I/O mapping tab.
// Only INPUTS reads these.
VAR_GLOBAL
	DI_bStartPB      : BOOL;	// X12 DI1 Start push button, green, normally open
	DI_bStopPB       : BOOL;	// X12 DI2 Stop push button, red, normally open
	DI_bResetPB      : BOOL;	// X12 DI3 Reset push button, orange, normally open
	AI_wSpeedFbk     : WORD;	// X14 AI1 Motor speed feedback from the drive, 0..32760 = 0..10 V = 0..100 %
END_VAR
