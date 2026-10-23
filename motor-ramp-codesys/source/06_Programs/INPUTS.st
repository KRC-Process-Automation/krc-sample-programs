// SAMPLE PROGRAM: motor ramp-up state machine. KRC (Kurtin Robotics), written as a teaching example.
// The scenario: a motor on a variable speed drive. A panel with three lit push buttons, Start (green),
// Stop (red) and Reset (orange), the same three buttons on an HMI screen, and a stack light with red,
// orange and green. Press Start and the motor ramps up through 10, 25, 50 and 75 % speed, one step at
// a time. Each step waits for the drive's speed feedback to reach the new speed. If that takes longer
// than the ramp timeout (set on the HMI, 10 seconds to start with), the machine faults. Press Stop and
// the motor ramps back down. Press Reset to clear a fault.
// How it is laid out: four programs run in this order, every scan, from MainTask. INPUTS reads every
// input into a program tag. STATE_MACHINE decides which step the machine is in. DEVICES sets every
// output from the step. OUTPUTS writes every output to the hardware and to the HMI. Nothing else reads
// the hardware or writes it.
// Hardware: a WAGO CC100. It has 4 discrete outputs, so 4 are used, the same as the ladder version.
// The Stop and Reset lamps and the orange stack light show on the HMI only.
PROGRAM INPUTS
// ---- body ----
// Rung 1. INPUTS: every input is read here and nowhere else. A button counts as pressed if the panel
// button OR the HMI button is pressed, so the rest of the program never has to ask which one it was.
// Start button: the panel button or the HMI button.
bStartPB := DI_bStartPB OR HMI_bStartPB;

// Rung 2. Stop button: the panel button or the HMI button.
bStopPB := DI_bStopPB OR HMI_bStopPB;

// Rung 3. Reset button: the panel button or the HMI button.
bResetPB := DI_bResetPB OR HMI_bResetPB;

// Rung 4. Speed feedback: the drive sends 0 to 10 V for 0 to 100 % speed. The CC100 reads that as
// 0 to 32760 (AI_FULL_SCALE). Times 100, divided by the full scale, gives percent, so the rest of the
// program works in %. The math is done in DINT: 32760 times 100 does not fit in an INT.
iSpeedFbk := DINT_TO_INT(WORD_TO_DINT(AI_wSpeedFbk) * 100 / AI_FULL_SCALE);

// Rung 5. Ramp timeout, set on the HMI in seconds. Every step timer below uses it as its preset.
// An IEC timer takes a TIME, so one second times the setting.
TON_RAMP_10.PT := T#1S * HMI_iRampTimeout;
TON_RAMP_25.PT := T#1S * HMI_iRampTimeout;
TON_RAMP_50.PT := T#1S * HMI_iRampTimeout;
TON_RAMP_75.PT := T#1S * HMI_iRampTimeout;
TON_STOPPING.PT := T#1S * HMI_iRampTimeout;
