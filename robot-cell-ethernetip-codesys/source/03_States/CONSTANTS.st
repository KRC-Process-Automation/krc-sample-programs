// Named numbers the program uses, so no bare number appears in the logic.
VAR_GLOBAL CONSTANT
	AI_FULL_SCALE    : REAL := 32760.0;	// CC100 analog input raw count at 10 V (WAGO manual, section 9.4)
	AO_FULL_SCALE    : REAL := 32767.0;	// CC100 analog output raw count for 10 V (WAGO manual, section 9.4)
	PRESSURE_RANGE   : REAL := 100.0;	// psi at 10 V, for the sensor and the regulator
	PRESSURE_BAND    : REAL := 2.0;	// psi: within this much of the setpoint counts as at pressure

	// The link: where each word sits in the GVL_Link arrays (the robot's register in the comment).
	TO_HEARTBEAT     : INT := 0;	// Input register 0: PLC heartbeat
	TO_COMMAND       : INT := 1;	// Input register 1: command
	TO_FIXTURE_CLEAR : INT := 2;	// Input register 2: fixture clear
	TO_PLC_STEP      : INT := 3;	// Input register 3: PLC step, for the pendant
	FROM_HEARTBEAT   : INT := 0;	// Output register 0: robot heartbeat
	FROM_READY       : INT := 1;	// Output register 1: robot ready
	FROM_ACK         : INT := 2;	// Output register 2: acknowledge, the command the robot accepted
	FROM_DONE        : INT := 3;	// Output register 3: done, the command the robot finished
	FROM_FAULT       : INT := 4;	// Output register 4: robot fault code
	FROM_ROBOT_STEP  : INT := 5;	// Output register 5: robot step, what the robot program is doing or waiting on
	BIT_START        : INT := 0;	// Input bit register 0: Start (I/O action on the robot)
	BIT_STOP         : INT := 1;	// Input bit register 1: Stop (I/O action on the robot)
	BIT_PAUSE        : INT := 2;	// Input bit register 2: Pause (I/O action on the robot)

	CMD_NONE         : DINT := 0;	// Command: nothing
	CMD_LOAD         : DINT := 1;	// Command: put a part in the fixture
	CMD_UNLOAD       : DINT := 2;	// Command: take the part out
	ROBOT_RUNNING    : SINT := 7;	// Robot mode 7: arm powered, brakes released
	ROBOT_NOT_HOME   : DINT := 900;	// Robot step 900: the program was started away from home and refused to move
	HEARTBEAT_TIME   : TIME := T#250MS;	// How often the PLC counts its heartbeat
	HEARTBEAT_LOST   : TIME := T#1S;	// No change in the robot's heartbeat this long: it's gone
	ROBOT_START_TIME : TIME := T#10S;	// How long the robot program may take to start or resume and be ready
	ROBOT_HOME_CHECK : TIME := T#2S;	// Long enough after Start for the robot program to have written its first step
	ROBOT_PAUSE_TIME : TIME := T#3S;	// How long the robot program may take to pause

	// The Dashboard: the robot's command port.
	ROBOT_IP         : STRING(15) := '192.168.1.10';	// The robot's address (Q2 in the program design), also set in UR_Robot
	DASH_PORT        : UINT := 29999;	// UR's Dashboard Server port
	DASH_POLL_TIME   : TIME := T#250MS;	// How often the PLC asks the robot a question
	DASH_REPLY_TIME  : TIME := T#2S;	// No answer this long: drop the connection and connect again
END_VAR
