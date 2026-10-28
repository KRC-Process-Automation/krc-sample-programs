// One line of the permissive table: something Ready waits for. The text is filled in where the table
// is declared (GVL_Alarms); bSatisfied is wired by one line per permissive in DEVICES.
TYPE ST_Permissive :
STRUCT
	sText       : STRING(30);	// What Ready waits for, in words (set in the table)
	bSatisfied  : BOOL;	// Met, right now (DEVICES, one line per permissive)
END_STRUCT
END_TYPE
