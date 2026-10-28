// How serious an alarm is.
TYPE E_AlarmLevel :
(
	LVL_INFO    := 1,	// Shows on the alarm list. Nothing else
	LVL_WARNING := 2,	// Lights the orange light. The machine keeps running
	LVL_ALARM   := 3 	// Stops the machine: the state machine goes to Fault until it is cleared
) INT;
END_TYPE
