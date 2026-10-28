// SAMPLE PROGRAM: the motor ramp-up state machine, with alarms, timeouts, and diagnostics.
// KRC (Kurtin Robotics), written as a teaching example. The walkthrough's motor, taken further: an alarm
// list with levels, acknowledge and clear; a timeout on every step that waits on the machine; a screen that
// says what is blocking a start; the speed feedback watched the whole time at speed; one-shots where they
// still earn a place; and the naming convention.
// Six programs run in this order, every scan, from MainTask: SIM (simulation only), INPUTS, STATE_MACHINE,
// ALARMS, DEVICES, OUTPUTS. Nothing but INPUTS reads the hardware; nothing but OUTPUTS writes it.
// Hardware: a WAGO CC100, onboard I/O. The E-stop input only watches the safety relay: the safety relay
// itself takes the drive's power, hardwired. This program is not a safety function.
PROGRAM INPUTS
// ---- body ----
// INPUTS: every input is read here and nowhere else, into a variable named like the raw tag with the
// class dropped: DI_bStartPB becomes bStartPB. A button counts as pressed if the panel button OR the HMI
// button is pressed.
bStartPB := DI_bStartPB OR HMI_bStartPB;

// Stop is wired normally closed: the input is on while nobody presses it, so off means pressed, and so
// does a broken wire. This is the only place it gets turned around.
bStopPB := NOT DI_bStopPB_NC OR HMI_bStopPB;

bResetPB := DI_bResetPB OR HMI_bResetPB;

// The drive's two relays and the safety relay's monitoring contact.
bDriveReady := DI_bDriveReady;
bDriveRemote := DI_bDriveRemote;
bEStopOK := DI_bEStopOK;

// Speed feedback: 0 to 10 V from the drive is 0 to 32760 on the CC100 (AI_FULL_SCALE). Times 100,
// divided by the full scale, gives percent, rounded to the nearest percent (the half full scale added
// first), so a reading never lands one short of a step's speed. DINT, because 32760 x 100 doesn't fit
// in an INT.
iSpeedFbk := DINT_TO_INT((WORD_TO_DINT(AI_wSpeedFbk) * 100 + AI_FULL_SCALE / 2) / AI_FULL_SCALE);

// One-shots: each is TRUE for one scan when its button goes down, and not again until it is let go and
// pressed again. Ready starts on the press, so a Start button held down can't restart the motor the moment
// it stops. ACK and Reset acknowledge on the press, so holding one can't acknowledge an alarm nobody has
// seen yet.
rtStart(CLK := bStartPB);
rtReset(CLK := bResetPB);
rtAck(CLK := HMI_bAckPB);
