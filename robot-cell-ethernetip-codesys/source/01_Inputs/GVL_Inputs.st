// Raw inputs, in CC100 terminal order. Mapped to the hardware in the CC100's I/O mapping tab.
// Only INPUTS reads these. (In simulation, SIM writes them, the way the field would.)
VAR_GLOBAL
	DI_bStartPB      : BOOL;	// X12.DI1 Cycle Start push button, normally open
	DI_bStopPB_NC    : BOOL;	// X12.DI2 Stop push button, normally closed: TRUE while nobody presses it
	DI_bResetPB      : BOOL;	// X12.DI3 Reset push button, normally open
	DI_bClampOpen    : BOOL;	// X12.DI4 Clamp open sensor, a reed switch on the cylinder
	DI_bPartPresent  : BOOL;	// X12.DI5 Part present in the fixture, a proximity sensor
	AI_wPressure     : WORD;	// X14.AI1 Clamp pressure, 0..10 V = 0..32760 = 0..100 psi
END_VAR
