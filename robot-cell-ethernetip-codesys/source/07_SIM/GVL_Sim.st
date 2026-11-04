// SIMULATION ONLY. Test code: it never goes on a real machine.
VAR_GLOBAL CONSTANT
	SIM_ENABLED      : BOOL := TRUE;	// TRUE in simulation. Set FALSE before downloading to a real CC100
	SIM_STATION      : BOOL := FALSE;	// The bench: TRUE with SIM_ENABLED FALSE plays only the clamp station; the robot is real
	SIM_PRESSURE_LAG : REAL := 0.03;	// Share of the gap to the setpoint the pressure closes each scan
	SIM_STUCK_SHARE  : REAL := 0.5;	// With Regulator stuck, the pressure only gets this share of the way
	SIM_OPEN_TIME    : TIME := T#500MS;	// How long the clamp takes to read open after the valve drops
	SIM_ACK_TIME     : TIME := T#300MS;	// How long the robot takes to answer a command
	SIM_MOVE_TIME    : TIME := T#1500MS;	// How long the robot takes to load or unload
	SIM_BEAT_TIME    : TIME := T#250MS;	// How often the robot counts its heartbeat
	SIM_START_TIME   : TIME := T#1S;	// How long the robot program takes to start and check it's at home
END_VAR
VAR_GLOBAL
	// Break switches on the screen
	SIM_bUnplugCable      : BOOL;	// The network cable to the robot is pulled
	SIM_bProgramStopped   : BOOL;	// The robot program stops on its own (from the pendant, or an error): no heartbeat, no answers
	SIM_bProtStop         : BOOL;	// The robot is in a protective stop
	SIM_bIgnoreCommands   : BOOL;	// The robot never acknowledges a command
	SIM_bGripperMiss      : BOOL;	// The robot's gripper misses the part and it reports a fault
	SIM_bPartStuck        : BOOL;	// The part stays in the fixture after the robot unloads it
	SIM_bLocalMode        : BOOL;	// The pendant is switched to local control: the robot ignores Start, Stop, and Pause
	SIM_bAwayFromHome     : BOOL;	// The robot is away from home (stopped mid-move); off once it's jogged home
	// More break switches, for the tests
	SIM_bEStop            : BOOL;	// The robot's emergency stop is pressed
	SIM_bArmNotRunning    : BOOL;	// The robot arm isn't Running (powered off or idle)
	SIM_bRobotSlow        : BOOL;	// The robot never finishes a move
	SIM_bNoClear          : BOOL;	// The robot never clears its acknowledge and done
	SIM_bPartNotPlaced    : BOOL;	// The robot says it loaded, but no part lands in the fixture
	SIM_bRegulatorStuck   : BOOL;	// The pressure stops short of the setpoint
	SIM_bOpenSensorStuck  : BOOL;	// The clamp never reads open
	SIM_bCutStopWire      : BOOL;	// The Stop button's wire is cut
	SIM_bDashboardDown    : BOOL;	// The Dashboard connection is down (the Modbus link is fine)
	// The simulated robot and machine
	SIM_iProgram          : INT;	// The robot program: 0 stopped, 1 playing, 2 paused
	SIM_dwBitsSeen        : DWORD;	// The Start, Stop, and Pause bits as the robot last saw them
	SIM_dwBitsLast        : DWORD;	// The same, last scan, to see a bit turn on
	SIM_bProgramStoppedLast : BOOL;	// Robot program stopped, last scan
	SIM_iRobotStep        : INT;	// 5 starting, 8 stopped away from home, 0 at home, 1 answered, 2 moving, 3 done, 9 faulted
	SIM_diRobotCommand    : DINT;	// The command the robot is working on
	SIM_adiPlcSeen        : ARRAY[0..3] OF DINT;	// The PLC's words as the robot last saw them
	SIM_diRobotBeat       : DINT;	// The robot's heartbeat count
	SIM_bPartStuckLast    : BOOL;	// Part stuck, last scan
	SIM_rPressure         : REAL;	// The pressure the simulated clamp has, in psi
	SIM_rTarget           : REAL;	// The pressure the regulator is heading for, in psi
	TON_SIM_OPEN          : TON;	// The clamp opening after the valve drops
	TON_SIM_ACK           : TON;	// The robot answering a command
	TON_SIM_MOVE          : TON;	// The robot's move
	TON_SIM_BEAT          : TON;	// Paces the robot's heartbeat
	TON_SIM_START         : TON;	// The robot program starting
END_VAR
