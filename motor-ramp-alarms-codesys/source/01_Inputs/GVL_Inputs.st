// Raw inputs, in CC100 terminal order. Mapped to the hardware in the CC100's I/O mapping tab.
// A raw tag is its class (DI_, AI_), its type (b, w), then its name. Only INPUTS reads these
// (and SIM writes them in simulation, the way the field would).
VAR_GLOBAL
	DI_bStartPB      : BOOL;	// X12 DI1 Start push button, green, normally open
	DI_bStopPB_NC    : BOOL;	// X12 DI2 Stop push button, red, normally closed: on while nobody presses it
	DI_bResetPB      : BOOL;	// X12 DI3 Reset push button, orange, normally open
	DI_bDriveReady   : BOOL;	// X12 DI4 The drive's Ready relay: on while it is powered and has no fault
	DI_bEStopOK      : BOOL;	// X12 DI5 The safety relay's monitoring contact: on while the E-stop circuit is closed
	DI_bDriveRemote  : BOOL;	// X12 DI6 The drive's Remote relay: on while the drive takes its commands from the PLC
	AI_wSpeedFbk     : WORD;	// X14 AI1 Speed feedback from the drive, 0..32760 = 0..10 V = 0..100 %
END_VAR
