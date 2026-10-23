// The HMI side. The screen writes the HMI inputs and only reads the HMI outputs.
VAR_GLOBAL
	HMI_bStartPB     : BOOL;	// HMI input: Start button on the screen
	HMI_bStopPB      : BOOL;	// HMI input: Stop button on the screen
	HMI_bResetPB     : BOOL;	// HMI input: Reset button on the screen
	HMI_bStartLamp   : BOOL;	// HMI output: Start button lit
	HMI_bStopLamp    : BOOL;	// HMI output: Stop button lit
	HMI_bResetLamp   : BOOL;	// HMI output: Reset button lit
	HMI_bStackGreen  : BOOL;	// HMI output: stack light green
	HMI_bStackOrange : BOOL;	// HMI output: stack light orange
	HMI_bStackRed    : BOOL;	// HMI output: stack light red
	HMI_bMotorRun    : BOOL;	// HMI output: motor running
	HMI_iSpeedRef    : INT;	// HMI output: speed reference in %
	HMI_iSpeedFbk    : INT;	// HMI output: speed feedback in %
	HMI_sState       : STRING;	// HMI output: what the machine is doing
END_VAR
VAR_GLOBAL RETAIN
	HMI_iRampTimeout : INT := 10;	// HMI input: ramp timeout in seconds, kept through a power cycle
END_VAR
