// The HMI side. The screen writes the HMI inputs and only reads the HMI outputs.
VAR_GLOBAL
	HMI_bStopPB      : BOOL;	// HMI input: Stop button on the screen
	HMI_bResetPB     : BOOL;	// HMI input: Reset button on the screen
	HMI_bStopLamp    : BOOL;	// HMI output: Stop button lit
	HMI_bResetLamp   : BOOL;	// HMI output: Reset button lit
	HMI_bStackGreen  : BOOL;	// HMI output: stack light green
	HMI_bStackRed    : BOOL;	// HMI output: stack light red
	HMI_bStackOrange : BOOL;	// HMI output: stack light orange
	HMI_rPressure    : REAL;	// HMI output: clamp pressure in psi
	HMI_sState       : STRING;	// HMI output: what the machine is doing
END_VAR
// Operator settings, kept through a power cycle, each with a sane starting value: a 0 setpoint after a
// power loss would pass the pressure check on the first scan.
VAR_GLOBAL RETAIN
	HMI_rPressureSet  : REAL := 60.0;	// HMI input: clamp pressure setpoint in psi, 10 to 90 on the screen
	HMI_iClampTimeout : INT := 5;	// HMI input: seconds Clamping may take to reach pressure
	HMI_iOpenTimeout  : INT := 3;	// HMI input: seconds Opening may take to read open
END_VAR
