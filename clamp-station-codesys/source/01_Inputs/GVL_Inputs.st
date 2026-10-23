// Raw inputs, in CC100 terminal order. Mapped to the hardware in the CC100's I/O mapping tab.
// Only INPUTS reads these. (In simulation, SIM writes them, the way the field would.)
VAR_GLOBAL
	DI_bLeftHandPB   : BOOL;	// X12.DI1 Left hand button, normally open
	DI_bRightHandPB  : BOOL;	// X12.DI2 Right hand button, normally open
	DI_bStopPB_NC    : BOOL;	// X12.DI3 Stop push button, normally closed: TRUE while nobody presses it
	DI_bResetPB      : BOOL;	// X12.DI4 Reset push button, normally open
	DI_bClampOpen    : BOOL;	// X12.DI5 Clamp open sensor, a reed switch on the cylinder
	AI_wPressure     : WORD;	// X14.AI1 Clamp pressure, 0..10 V = 0..32760 = 0..100 psi
END_VAR
