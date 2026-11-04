PROGRAM DASHBOARD
VAR
	ipRobot      : NBS.IPv4Address := (ipAddress := ROBOT_IP);	// The robot's address
	fbClient     : NBS.TCP_Client;	// The connection to the robot's Dashboard Server
	fbWrite      : NBS.TCP_Write;	// Sends one line
	fbRead       : NBS.TCP_Read;	// Takes in whatever the robot has sent
	TON_POLL     : TON;	// Paces the questions
	TON_REPLY    : TON;	// The robot's answer is overdue
	TON_RETRY    : TON;	// Still not connected: try again
	bDropped     : BOOL;	// The connection was dropped this scan, so the retry timer starts over
	iDashStep    : INT;	// 0 not connected, 10 waiting for hello, 20 idle, 30 sending, 40 waiting for the answer
	bReconnect   : BOOL;	// Drop the connection for one scan, to connect again
	bAskRemote   : BOOL;	// The question in flight, or the next one, is remote control (the two take turns)
	sOut         : STRING(80);	// The line going out, with its line feed
	abIn         : ARRAY[0..127] OF BYTE;	// The bytes the read brings in
	sLine        : STRING(80);	// The line coming in, put together up to its line feed
	bLineDone    : BOOL;	// A whole line has come in this scan
	sChar        : STRING(1);	// One character, to add to the line
	i            : UDINT;	// Counts through the bytes read
END_VAR
// ---- body ----
// DASHBOARD: the driver for the second connection to the robot, its Dashboard Server. Not EtherNet/IP: one
// line of text over TCP to port 29999, and one line back. It asks the robot two questions, in turn, four times
// a second: what is the program doing ("programState": PLAYING, PAUSED, or STOPPED), and is the robot in
// remote control ("is in remote control": true or false). It leaves the answers in GVL_Link for INPUTS to read.
// (The Dashboard can also play, stop, and pause the program; here the register bits do that.)
// In simulation it doesn't run: SIM plays the robot's answers.
IF SIM_ENABLED THEN
    RETURN;
END_IF

// The connection: always on, except for the one scan it's dropped on purpose because the robot went quiet.
fbClient(xEnable := NOT bReconnect, itfIPAddress := ipRobot, uiPort := DASH_PORT);
bReconnect := FALSE;

// Take in what the robot sent, a byte at a time, until the line feed that ends its answer.
fbRead(xEnable := fbClient.xActive, itfConnection := fbClient.itfConnection, pData := ADR(abIn), udiSize := SIZEOF(abIn));
bLineDone := FALSE;
IF fbRead.xReady AND fbRead.udiCount > 0 THEN
    FOR i := 0 TO fbRead.udiCount - 1 DO
        IF abIn[i] = 10 THEN
            bLineDone := TRUE;
        ELSIF abIn[i] <> 13 AND LEN(sLine) < 80 THEN
            sChar[0] := abIn[i];
            sLine := CONCAT(sLine, sChar);
        END_IF
    END_FOR
END_IF

// Send the line, when there's one to send.
fbWrite(xExecute := iDashStep = 30, itfConnection := fbClient.itfConnection, pData := ADR(sOut), udiSize := INT_TO_UDINT(LEN(sOut)));

// The timers: one paces the questions, one gives up on an answer that doesn't come, and one on a connection that
// doesn't come (a refused or reset connection leaves the client in error until it is dropped and enabled again;
// on the bench, 2026-10-30, after the cable was out for minutes it never came back without this).
TON_POLL(IN := iDashStep = 20 AND NOT TON_POLL.Q, PT := DASH_POLL_TIME);
TON_REPLY(IN := iDashStep = 10 OR iDashStep = 40, PT := DASH_REPLY_TIME);
TON_RETRY(IN := iDashStep = 0 AND NOT fbClient.xActive AND NOT bDropped, PT := DASH_REPLY_TIME);
bDropped := FALSE;

CASE iDashStep OF
0:  // Not connected. When the connection comes up, the robot says hello first, and it can come in on the very
    // scan the connection does (it did on the bench, 2026-10-29): then it's already here, so don't wait for it.
    IF fbClient.xActive AND bLineDone THEN
        sLine := '';
        iDashStep := 20;
    ELSIF fbClient.xActive THEN
        iDashStep := 10;
    ELSE
        sLine := '';
    END_IF

10: // Waiting for hello: "Connected: Universal Robots Dashboard Server".
    IF bLineDone THEN
        sLine := '';
        iDashStep := 20;
    END_IF

20: // Idle. When it's time, the next question.
    IF TON_POLL.Q THEN
        bAskRemote := NOT bAskRemote;
        IF bAskRemote THEN
            sOut := 'is in remote control$N';
        ELSE
            sOut := 'programState$N';
        END_IF
        iDashStep := 30;
    END_IF

30: // Sending. When the line is out, wait for the answer.
    IF fbWrite.xDone THEN
        iDashStep := 40;
    END_IF
    IF fbWrite.xError THEN
        bReconnect := TRUE;
        iDashStep := 0;
    END_IF

40: // Waiting for the answer. Put it where it belongs.
    IF bLineDone THEN
        LINK_sDashReply := sLine;
        IF bAskRemote THEN
            LINK_bRemoteControl := sLine = 'true';
        ELSE
            LINK_sProgramState := sLine;
        END_IF
        sLine := '';
        iDashStep := 20;
    END_IF
END_CASE

// The robot went quiet, or never answered the call: drop the connection and connect again.
IF TON_REPLY.Q OR TON_RETRY.Q THEN
    bReconnect := TRUE;
    bDropped := TRUE;
    iDashStep := 0;
END_IF

// Without the connection, nothing the robot said last still counts.
IF NOT fbClient.xActive THEN
    iDashStep := 0;
    LINK_sProgramState := '';
    LINK_bRemoteControl := FALSE;
END_IF
LINK_bDashConnected := fbClient.xActive AND iDashStep >= 20;
