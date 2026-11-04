// The HMI side. The screen writes the HMI inputs and only reads the HMI outputs.
VAR_GLOBAL
	HMI_bStartPB      : BOOL;	// HMI input: Start button on the screen
	HMI_bStopPB       : BOOL;	// HMI input: Stop button on the screen
	HMI_bResetPB      : BOOL;	// HMI input: Reset button on the screen
	HMI_bPausePB      : BOOL;	// HMI input: Pause button on the screen
	HMI_bStartLamp    : BOOL;	// HMI output: Start button lit, Start does something
	HMI_bStopLamp     : BOOL;	// HMI output: Stop button lit
	HMI_bResetLamp    : BOOL;	// HMI output: Reset button lit
	HMI_bPauseLamp    : BOOL;	// HMI output: Pause button lit, Pause does something
	HMI_bStackGreen   : BOOL;	// HMI output: stack light green
	HMI_bStackRed     : BOOL;	// HMI output: stack light red
	HMI_bStackOrange  : BOOL;	// HMI output: stack light orange
	HMI_rPressure     : REAL;	// HMI output: clamp pressure in psi
	HMI_sState        : STRING;	// HMI output: what the cell is doing
	HMI_sRobot        : STRING;	// HMI output: what the robot program is doing, from the robot step
	HMI_bLinkUp       : BOOL;	// HMI output: lamp, the link is up and the robot's heartbeat is ticking
	HMI_bDashUp       : BOOL;	// HMI output: lamp, the Dashboard connection is up
	HMI_bRemote       : BOOL;	// HMI output: lamp, the robot is in remote control
	HMI_bProgramRunning : BOOL;	// HMI output: lamp, the robot program is running
	HMI_bRobotReady   : BOOL;	// HMI output: lamp, the robot program is ready for a command
	HMI_bRobotRunning : BOOL;	// HMI output: lamp, the robot reports mode Running
	HMI_bRobotStopped : BOOL;	// HMI output: lamp, the robot is in a protective or emergency stop
	HMI_bPartPresent  : BOOL;	// HMI output: lamp, a part is in the fixture
	HMI_iToRobot      : ARRAY[0..4] OF DINT;	// HMI output: the four words to the robot and its Start/Stop/Pause bits
	HMI_iFromRobot    : ARRAY[0..5] OF DINT;	// HMI output: the six words from the robot, as numbers
END_VAR
// Operator settings, kept through a power cycle, each with a sane starting value.
VAR_GLOBAL RETAIN
	HMI_rPressureSet  : REAL := 60.0;	// HMI input: clamp pressure setpoint in psi, 10 to 90 on the screen
	HMI_iHoldTime     : INT := 2;	// HMI input: seconds the clamp holds at pressure
	HMI_iClampTimeout : INT := 5;	// HMI input: seconds Clamping may take to reach pressure
	HMI_iOpenTimeout  : INT := 3;	// HMI input: seconds Opening may take to read open
	HMI_iAckTimeout   : INT := 2;	// HMI input: seconds the robot may take to acknowledge or clear a command
	HMI_iMoveTimeout  : INT := 15;	// HMI input: seconds the robot may take to load or unload
	HMI_bContinuous   : BOOL;	// HMI input: run part after part until Stop or Pause; off, one part per Start
END_VAR
