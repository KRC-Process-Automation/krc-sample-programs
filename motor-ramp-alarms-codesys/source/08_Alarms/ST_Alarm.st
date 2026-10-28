// One line of the alarm table. The level and the text are filled in where the table is declared
// (GVL_Alarms). bTriggered is wired by one line per alarm in ALARMS; the rest belongs to the alarm
// list in ALARMS.
TYPE ST_Alarm :
STRUCT
	eLevel      : E_AlarmLevel;	// INFO, WARNING or ALARM (set in the table)
	sText       : STRING(60);	// What happened, in words, for the screen (set in the table)
	bTriggered  : BOOL;	// The condition, right now (ALARMS, one line per alarm)
	bOnList     : BOOL;	// On the list: from when it triggers until it is acknowledged and gone (ALARMS)
	bAcked      : BOOL;	// Acknowledged with ACK or Reset (ALARMS)
	iStepRaised : INT;	// The step the machine was in when it came on (ALARMS)
END_STRUCT
END_TYPE
