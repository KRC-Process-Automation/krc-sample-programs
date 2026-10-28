// The alarm table and the permissive table: every alarm and every permissive, with its words, in one
// place. Adding an alarm is a line here, a constant in CONSTANTS, and its trigger line in ALARMS.
VAR_GLOBAL
	aAlarms : ARRAY[1..ALARM_COUNT] OF ST_Alarm := [
		(eLevel := LVL_ALARM,   sText := 'E-stop pressed: the safety circuit is open'),
		(eLevel := LVL_ALARM,   sText := 'Drive dropped out while running'),
		(eLevel := LVL_ALARM,   sText := 'Drive switched to local while running'),
		(eLevel := LVL_ALARM,   sText := 'Ramp timeout: speed not reached in time'),
		(eLevel := LVL_ALARM,   sText := 'Stop timeout: the motor did not stop in time'),
		(eLevel := LVL_WARNING, sText := 'Speed deviation: more than 10 % off'),
		(eLevel := LVL_INFO,    sText := 'Simulation mode: SIM is playing the machine')];
	aPermissives : ARRAY[1..PERMISSIVE_COUNT] OF ST_Permissive := [
		(sText := 'Drive ready'),
		(sText := 'Drive in remote'),
		(sText := 'Stop released'),
		(sText := 'Motor stopped')];
	bAlarmOnList     : BOOL;	// Any ALARM-level alarm on the list (ALARMS)
	bWarningOnList   : BOOL;	// Any WARNING on the list (ALARMS)
	bUnacknowledged  : BOOL;	// Any ALARM or WARNING on the list not yet acknowledged (ALARMS)
	bPermissivesOK   : BOOL;	// Every permissive met (STATE_MACHINE)
END_VAR
