PROGRAM OUTPUTS
VAR
	i       : INT;	// The line, or the alarm, being looked at
	iLines  : INT;	// How many alarms are on the list, up to ALARM_LINES
	aShown  : ARRAY[1..ALARM_LINES] OF INT;	// Which alarm each line shows
	sLevel  : STRING(10);	// The line's level, in words
END_VAR
// ---- body ----
// OUTPUTS: every output is written here and nowhere else. First the hardware, in terminal order.
DO_bMotorRun := bMotorRun;
DO_bStackGreen := bStackGreen;
DO_bStackRed := bStackRed;
DO_bStackOrange := bStackOrange;

// Speed reference to the drive: 0 to 100 % becomes 0 to 32767 (AO_FULL_SCALE), 0 to 10 V, rounded to the
// nearest count.
AO_wSpeedRef := DINT_TO_WORD((INT_TO_DINT(iSpeedRef) * AO_FULL_SCALE + 50) / 100);

// Then the HMI. The screen only reads these.
HMI_bStartLamp := bStartLamp;
HMI_bStopLamp := bStopLamp;
HMI_bResetLamp := bResetLamp;
HMI_bAckLamp := bAckLamp;
HMI_bStackGreen := bStackGreen;
HMI_bStackOrange := bStackOrange;
HMI_bStackRed := bStackRed;
HMI_bMotorRun := bMotorRun;
HMI_iSpeedRef := iSpeedRef;
HMI_iSpeedFbk := iSpeedFbk;
HMI_sState := sStateDescription;

// The permissive lamps.
FOR i := 1 TO PERMISSIVE_COUNT DO
    HMI_abPermissive[i] := aPermissives[i].bSatisfied;
END_FOR

// The alarm lines: the alarms on the list, in table order (ALARM level first), up to ALARM_LINES. Each
// line is the level, the words, and the step the machine was in when it came on.
iLines := 0;
FOR i := 1 TO ALARM_COUNT DO
    IF aAlarms[i].bOnList AND iLines < ALARM_LINES THEN
        iLines := iLines + 1;
        aShown[iLines] := i;
    END_IF
END_FOR
FOR i := 1 TO ALARM_LINES DO
    IF i <= iLines THEN
        CASE aAlarms[aShown[i]].eLevel OF
        LVL_ALARM:
            sLevel := 'ALARM';
        LVL_WARNING:
            sLevel := 'WARNING';
        ELSE
            sLevel := 'INFO';
        END_CASE
        HMI_asAlarmLine[i] := CONCAT(CONCAT(sLevel, '   '), CONCAT(aAlarms[aShown[i]].sText,
                              CONCAT('   (step ', CONCAT(INT_TO_STRING(aAlarms[aShown[i]].iStepRaised), ')'))));
        HMI_abAlarmUnacked[i] := NOT aAlarms[aShown[i]].bAcked;
    ELSE
        HMI_asAlarmLine[i] := '';
        HMI_abAlarmUnacked[i] := FALSE;
    END_IF
END_FOR
