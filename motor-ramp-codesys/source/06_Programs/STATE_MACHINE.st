PROGRAM STATE_MACHINE
// ---- body ----
// STATE_MACHINE: decides which step the machine is in. The steps are the values of the enum E_Step
// (03_States), listed here:
// S0_IDLE = 0   Idle: powered up and at rest. Goes straight to Not Ready
// S1_NOT_READY = 1000   Not Ready: waiting for the motor to be stopped
// S2_RESET = 2000   Reset: clears a fault, waits for Reset to be released
// S3_READY = 3000   Ready: waiting for Start
// S4_RAMP_10 = 4000   Running: ramping to 10 %
// S4_RAMP_25 = 4100   Running: ramping to 25 %
// S4_RAMP_50 = 4200   Running: ramping to 50 %
// S4_RAMP_75 = 4300   Running: ramping to 75 %
// S4_AT_SPEED = 4400   Running: at speed, 75 %
// S5_STOPPING = 5000   Stopping: speed reference 0, waiting for the motor to stop
// S6_FAULT = 6000   Fault: waiting for Reset iStep is the step the machine is in. The CASE below has
// one branch per step. Inside a branch, each exit is one IF: the reason it leaves, then the next step
// into iNextStep (and what the machine will be doing, for the HMI). The step only changes on the last
// line, so every rung in one scan sees the same step.

// The step timers, one per timed step. Each runs only while its step is active, so it starts from zero
// every time the step starts. Called here, every scan, so it resets when the step ends. (In the ladder
// each timer sits on a branch of its exit rung: rungs 7, 9, 11, 13, 16.)
TON_RAMP_10(IN := iStep = S4_RAMP_10);
TON_RAMP_25(IN := iStep = S4_RAMP_25);
TON_RAMP_50(IN := iStep = S4_RAMP_50);
TON_RAMP_75(IN := iStep = S4_RAMP_75);
TON_STOPPING(IN := iStep = S5_STOPPING);

CASE iStep OF

S0_IDLE:
    // Rung 1. Idle: powered up and at rest. Go to Not Ready.
    iNextStep := S1_NOT_READY;
    sStateDescription := 'Not Ready - waiting for the motor to stop';

S1_NOT_READY:
    // Rung 2. Not Ready: the motor is stopped, so the machine is ready.
    IF iSpeedFbk <= SPEED_STOPPED THEN
        iNextStep := S3_READY;
        sStateDescription := 'Ready - press Start';
    END_IF
    // Rung 3. Not Ready: Reset pressed. Go through Reset.
    IF bResetPB THEN
        iNextStep := S2_RESET;
        sStateDescription := 'Reset - release Reset';
    END_IF

S2_RESET:
    // Rung 4. Reset: Reset released. Back to Not Ready, which checks the motor again before Ready.
    IF NOT bResetPB THEN
        iNextStep := S1_NOT_READY;
        sStateDescription := 'Not Ready - waiting for the motor to stop';
    END_IF

S3_READY:
    // Rung 5. Ready: Start pressed. Start the motor at 10 %.
    IF bStartPB THEN
        iNextStep := S4_RAMP_10;
        sStateDescription := 'Running - ramping to 10 %';
    END_IF

S4_RAMP_10:
    // Rung 6. Ramp to 10 %: the speed feedback has reached 10 %. Next step.
    IF iSpeedFbk >= SPEED_10 THEN
        iNextStep := S4_RAMP_25;
        sStateDescription := 'Running - ramping to 25 %';
    END_IF
    // Rung 7. Ramp to 10 %: the timeout ran out and the speed is still below 10 %. Fault.
    IF TON_RAMP_10.Q AND iSpeedFbk < SPEED_10 THEN
        iNextStep := S6_FAULT;
        sStateDescription := 'Fault - 10 % not reached in time';
    END_IF

S4_RAMP_25:
    // Rung 8. Ramp to 25 %: the speed feedback has reached 25 %. Next step.
    IF iSpeedFbk >= SPEED_25 THEN
        iNextStep := S4_RAMP_50;
        sStateDescription := 'Running - ramping to 50 %';
    END_IF
    // Rung 9. Ramp to 25 %: the timeout ran out and the speed is still below 25 %. Fault.
    IF TON_RAMP_25.Q AND iSpeedFbk < SPEED_25 THEN
        iNextStep := S6_FAULT;
        sStateDescription := 'Fault - 25 % not reached in time';
    END_IF

S4_RAMP_50:
    // Rung 10. Ramp to 50 %: the speed feedback has reached 50 %. Next step.
    IF iSpeedFbk >= SPEED_50 THEN
        iNextStep := S4_RAMP_75;
        sStateDescription := 'Running - ramping to 75 %';
    END_IF
    // Rung 11. Ramp to 50 %: the timeout ran out and the speed is still below 50 %. Fault.
    IF TON_RAMP_50.Q AND iSpeedFbk < SPEED_50 THEN
        iNextStep := S6_FAULT;
        sStateDescription := 'Fault - 50 % not reached in time';
    END_IF

S4_RAMP_75:
    // Rung 12. Ramp to 75 %: the speed feedback has reached 75 %. The motor stays here until Stop.
    IF iSpeedFbk >= SPEED_75 THEN
        iNextStep := S4_AT_SPEED;
        sStateDescription := 'Running - at speed, 75 %';
    END_IF
    // Rung 13. Ramp to 75 %: the timeout ran out and the speed is still below 75 %. Fault.
    IF TON_RAMP_75.Q AND iSpeedFbk < SPEED_75 THEN
        iNextStep := S6_FAULT;
        sStateDescription := 'Fault - 75 % not reached in time';
    END_IF

S4_AT_SPEED:
    // At speed: no exit of its own. It holds here until Stop (rung 14, after the CASE).
    ;

S5_STOPPING:
    // Rung 15. Stopping: the motor has stopped. Back to Not Ready.
    IF iSpeedFbk <= SPEED_STOPPED THEN
        iNextStep := S1_NOT_READY;
        sStateDescription := 'Not Ready - waiting for the motor to stop';
    END_IF
    // Rung 16. Stopping: timed out and the motor is still turning. Fault.
    IF TON_STOPPING.Q AND iSpeedFbk > SPEED_STOPPED THEN
        iNextStep := S6_FAULT;
        sStateDescription := 'Fault - motor did not stop in time';
    END_IF

S6_FAULT:
    // Rung 17. Fault: Reset pressed. Go through Reset, then Not Ready.
    IF bResetPB THEN
        iNextStep := S2_RESET;
        sStateDescription := 'Reset - release Reset';
    END_IF
END_CASE

// Rung 14. Running, any ramp step or at speed: Stop pressed. Ramp down. This rung comes after the ramp
// rungs, so Stop wins if both happen in the same scan.
IF iStep >= S4_RAMP_10 AND iStep <= S4_AT_SPEED AND bStopPB THEN
    iNextStep := S5_STOPPING;
    sStateDescription := 'Stopping - waiting for the motor to stop';
END_IF

// Rung 18. Take the next step. This is the only place the step changes.
iStep := iNextStep;
