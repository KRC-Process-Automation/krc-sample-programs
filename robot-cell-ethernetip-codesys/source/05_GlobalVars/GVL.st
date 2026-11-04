// Buffered inputs, buffered outputs, the state machine, and the timers.
VAR_GLOBAL
	iStep             : E_Step := S0_IDLE;	// The step the cell is in
	iNextStep         : E_Step := S0_IDLE;	// The step it goes to at the end of this scan
	sStateDescription : STRING := 'Idle';	// What the cell is doing, in words, for the HMI
	iPausedStep       : E_Step := S0_IDLE;	// The step Pause came from, to go back to on Start
	sPausedDescription : STRING;		// What the cell was doing when Pause came, to say again on Start
	// Buffered inputs
	bStartPB          : BOOL;		// Start pressed, on the panel or the HMI
	bStartPressed     : BOOL;		// Start just pressed: on for the one scan Start goes on
	bStartLast        : BOOL;		// Start, last scan
	bStopPB           : BOOL;		// Stop pressed, on the panel or the HMI (or the Stop wire cut)
	bResetPB          : BOOL;		// Reset pressed, on the panel or the HMI
	bPausePB          : BOOL;		// Pause pressed, on the HMI
	bClampOpen        : BOOL;		// The clamp reads open
	bPartPresent      : BOOL;		// A part is in the fixture
	rPressure         : REAL;		// Clamp pressure in psi
	bLinkError        : BOOL;		// The PLC can't reach the robot over the network
	bRobotAlive       : BOOL;		// The robot's heartbeat is still changing
	bRobotReady       : BOOL;		// The robot program is at home, waiting for a command
	bRobotRunning     : BOOL;		// The robot reports mode Running
	bRobotProtStop    : BOOL;		// The robot is in a protective stop
	bRobotEStop       : BOOL;		// The robot is in an emergency stop
	diRobotAck        : DINT;		// The command the robot acknowledged
	diRobotDone       : DINT;		// The command the robot finished
	diRobotFault      : DINT;		// The robot's fault code, 0 when none
	diRobotHeartbeat  : DINT;		// The robot's heartbeat count
	diRobotBeatLast   : DINT;		// The robot's heartbeat count last scan
	diRobotStep       : DINT;		// The robot step: what the robot program is doing or waiting on
	bHandshakeClear   : BOOL;		// The robot's acknowledge and done are both back to 0
	bProgramRunning   : BOOL;		// The robot program is running (EtherNet/IP, RobotBits bit 1)
	bDashConnected    : BOOL;		// The Dashboard connection is up
	bProgramPlaying   : BOOL;		// The Dashboard says the robot program is playing
	bProgramPaused    : BOOL;		// The Dashboard says the robot program is paused
	bProgramStopped   : BOOL;		// The Dashboard says the robot program is stopped
	bRemoteControl    : BOOL;		// The robot is in remote control, so it takes Start, Stop, and Pause
	// Buffered outputs
	bClampClose       : BOOL;		// Clamp valve on
	rPressureSet      : REAL;		// Pressure setpoint going to the regulator, in psi
	bStackGreen       : BOOL;		// Stack light green
	bStackRed         : BOOL;		// Stack light red
	bStackOrange      : BOOL;		// Stack light orange
	bStartLamp        : BOOL;		// Start button lamp
	bStopLamp         : BOOL;		// Stop button lamp
	bResetLamp        : BOOL;		// Reset button lamp
	bPauseLamp        : BOOL;		// Pause button lamp
	diCommand         : DINT;		// The command to the robot
	bFixtureClear     : BOOL;		// The robot may reach into the fixture
	diPlcHeartbeat    : DINT;		// The PLC's heartbeat count
	bRobotStart       : BOOL;		// Start the robot program: input bit register 0
	bRobotStop        : BOOL;		// Stop the robot program: input bit register 1
	bRobotPause       : BOOL;		// Pause the robot program: input bit register 2
	// Timers
	TON_START         : TON;		// Timeout: the robot program starting or resuming
	TON_PAUSE         : TON;		// Timeout: the robot program pausing
	TON_ACK           : TON;		// Timeout: the robot acknowledging a command
	TON_MOVE          : TON;		// Timeout: the robot loading or unloading
	TON_CLEAR         : TON;		// Timeout: the robot clearing its answer
	TON_CLAMP         : TON;		// Timeout: Clamping reaching pressure
	TON_HOLD          : TON;		// The hold time at pressure
	TON_OPEN          : TON;		// Timeout: Opening reading open
	TON_BEAT_LOST     : TON;		// The robot's heartbeat hasn't changed
	TON_PLC_BEAT      : TON;		// Paces the PLC's heartbeat
END_VAR
