// Named numbers the program uses, so no bare number appears in the logic. Constants are all capitals.
VAR_GLOBAL CONSTANT
	SPEED_10           : INT := 10;	// Ramp speed 1, in %
	SPEED_25           : INT := 25;	// Ramp speed 2, in %
	SPEED_50           : INT := 50;	// Ramp speed 3, in %
	SPEED_75           : INT := 75;	// Ramp speed 4 and running speed, in %
	SPEED_STOPPED      : INT := 2;	// At or below this speed, in %, the motor counts as stopped
	SPEED_DEVIATION    : INT := 10;	// At speed, further than this off the reference, in %, is a deviation
	T_SPEED_DEVIATION  : TIME := T#3S;	// ...if it lasts this long
	T_FLASH            : TIME := T#500MS;	// The orange light's flash: this long on, this long off
	AI_FULL_SCALE      : DINT := 32760;	// CC100 analog input at 10 V, in raw counts (WAGO CC100 manual, 9.4)
	AO_FULL_SCALE      : DINT := 32767;	// CC100 analog output count for 10 V (WAGO CC100 manual, 9.4)
	ALARM_COUNT        : INT := 7;	// Lines in the alarm table (GVL_Alarms)
	ALARM_LINES        : INT := 5;	// Alarm lines on the screen
	PERMISSIVE_COUNT   : INT := 4;	// Lines in the permissive table (GVL_Alarms)
	// Where each alarm sits in the alarm table, ALARM level first, so the worst shows at the top
	ALM_ESTOP            : INT := 1;
	ALM_DRIVE_DROPPED    : INT := 2;
	ALM_DRIVE_LOCAL      : INT := 3;
	ALM_RAMP_TIMEOUT     : INT := 4;
	ALM_STOP_TIMEOUT     : INT := 5;
	ALM_SPEED_DEVIATION  : INT := 6;
	ALM_SIM_MODE         : INT := 7;
	// Where each permissive sits in the permissive table, in the order Not Ready names them
	PERM_DRIVE_READY     : INT := 1;
	PERM_DRIVE_REMOTE    : INT := 2;
	PERM_STOP_RELEASED   : INT := 3;
	PERM_MOTOR_STOPPED   : INT := 4;
END_VAR
