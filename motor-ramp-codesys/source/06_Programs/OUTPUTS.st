PROGRAM OUTPUTS
// ---- body ----
// Rung 1. OUTPUTS: every output is written here and nowhere else. First the hardware, in terminal
// order. Motor drive run command.
DO_bMotorRun := bMotorRun;

// Rung 2. Stack light green.
DO_bStackGreen := bStackGreen;

// Rung 3. Stack light red.
DO_bStackRed := bStackRed;

// Rung 4. Start button lamp.
DO_bStartLamp := bStartLamp;

// Rung 5. Speed reference to the drive: 0 to 100 % becomes 0 to 32767 (AO_FULL_SCALE) on the CC100,
// 0 to 10 V. The math is done in DINT, as in INPUTS.
AO_wSpeedRef := DINT_TO_WORD(INT_TO_DINT(iSpeedRef) * AO_FULL_SCALE / 100);

// Rung 6. Then the HMI. The screen only reads these. Start button lit.
HMI_bStartLamp := bStartLamp;

// Rung 7. Stop button lit.
HMI_bStopLamp := bStopLamp;

// Rung 8. Reset button lit.
HMI_bResetLamp := bResetLamp;

// Rung 9. Stack light green.
HMI_bStackGreen := bStackGreen;

// Rung 10. Stack light orange.
HMI_bStackOrange := bStackOrange;

// Rung 11. Stack light red.
HMI_bStackRed := bStackRed;

// Rung 12. Motor running.
HMI_bMotorRun := bMotorRun;

// Rung 13. Speed reference and feedback for the speed bar, and the state in words.
HMI_iSpeedRef := iSpeedRef;
HMI_iSpeedFbk := iSpeedFbk;
HMI_sState := sStateDescription;
