// The link to the robot: every word on the wire, both ways. Two connections, each doing what it's good at.
//
// EtherNet/IP: the CC100 is the scanner, the robot the adapter (Ethernet > EtherNet_IP_Scanner > UR_Robot).
// Every 10 ms the PLC sends the robot's output assembly (112) and gets its input assembly (100). Each word
// below is mapped to its channel in UR_Robot's I/O mapping tab. The registers are the robot's general purpose
// registers 0 to 23, the ones set aside for fieldbus: the PLC writes the robot's INPUT registers, the robot
// writes its OUTPUT registers. Start, Stop, and Pause are input bit registers 0 to 2, set up on the robot as
// I/O actions (Installation > I/O Setup), so a bit going on starts, stops, or pauses the robot program.
//
// The Dashboard: a line of text over TCP, port 29999 (the DASHBOARD program). It's how the PLC knows whether
// the robot program is playing, paused, or stopped, and whether the robot is in remote control. EtherNet/IP
// only says running or not running, and a paused program and a stopped one look the same.
//
// Only INPUTS reads the robot's words and only OUTPUTS writes the PLC's. (In simulation, SIM plays the robot.)
VAR_GLOBAL
	LINK_adiToRobot    : ARRAY[0..3] OF DINT;	// DINT Input Register 0 to 3, the PLC's words to the robot
	LINK_dwToRobotBits : DWORD;	// Bit Input Registers 0-31: bit 0 Start, bit 1 Stop, bit 2 Pause
	LINK_adiFromRobot  : ARRAY[0..5] OF DINT;	// DINT Output Register 0 to 5, the robot program's words to the PLC
	LINK_siRobotMode   : SINT;	// Robot Mode: 7 is Running (arm powered, brakes released). SINT, as the robot's channel is
	LINK_dwRobotBits   : DWORD;	// RobotBits: bit 0 power on, bit 1 program running
	LINK_dwSafetyBits  : DWORD;	// SafetyBits: bit 2 protective stop, 4 safeguard stop, 5 to 7 emergency stops
	LINK_bCommError    : BOOL;	// The scanner can't reach the robot (UR_Robot's connection is down). SIM plays it

	LINK_bDashConnected : BOOL;	// The Dashboard connection is up and the robot said hello
	LINK_sProgramState  : STRING(80);	// The answer to programState: PLAYING, PAUSED, or STOPPED, then the program's name
	LINK_bRemoteControl : BOOL;	// The answer to "is in remote control" was true
	LINK_sDashReply     : STRING(80);	// The robot's last answer, word for word
END_VAR
