PROGRAM OUTPUTS
// ---- body ----
// OUTPUTS: every output is written here and nowhere else. First the hardware, in terminal order.
DO_bClampClose := bClampClose;
DO_bStackGreen := bStackGreen;
DO_bStackRed := bStackRed;
DO_bStackOrange := bStackOrange;

// Pressure setpoint to the regulator: the same scaling as the input, run backwards. psi in, raw count out,
// 0 to 32767 for 0 to 10 V on the CC100.
AO_wPressureSet := REAL_TO_WORD(rPressureSet * AO_FULL_SCALE / PRESSURE_RANGE);

// Then the HMI. The screen only reads these.
HMI_bStopLamp := bStopLamp;
HMI_bResetLamp := bResetLamp;
HMI_bStackGreen := bStackGreen;
HMI_bStackRed := bStackRed;
HMI_bStackOrange := bStackOrange;
HMI_rPressure := rPressure;
HMI_sState := sStateDescription;
