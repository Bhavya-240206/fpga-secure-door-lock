[README.md](https://github.com/user-attachments/files/31435445/README.md)
# FPGA-Based Secure Door Lock System

## Overview

This project implements a password-based secure door lock controller using Verilog HDL. The design is based on a Finite State Machine (FSM) and is simulated using ModelSim.

The system supports password setting and authentication, detects consecutive incorrect password attempts, automatically enters a lockout state after three failed attempts, and remains locked for a configurable number of clock cycles.

The project also includes a system cycle counter for tracking elapsed clock cycles during operation.

---

## Features

- FSM-based password authentication
- 12-bit password storage and comparison
- Password setting functionality
- Failed-attempt counter
- Maximum of three consecutive incorrect attempts
- Automatic lockout after three failed attempts
- Configurable lockout duration
- System cycle counter
- Asynchronous reset
- 7-segment display status indication
- `OPEN`, `FAIL`, `SETP`, and `LOCK` status displays
- Verilog RTL implementation
- ModelSim-based simulation

---

## System Architecture

The major components of the design are:

```text
                 +----------------------+
                 |     Door Lock RTL    |
                 |                      |
                 |   FSM Controller     |
                 +----------+-----------+
                            |
             +--------------+--------------+
             |              |              |
             v              v              v
      Password Logic   Attempt Counter   Lockout Timer
             |              |              |
             +--------------+--------------+
                            |
                     System Cycle Counter
                            |
                            v
                    7-Segment Display
                            |
                            v
                         Unlock
```

---

## FSM Design

The controller consists of six states: `IDLE`, `SETP`, `CHECK`, `OPEN`, `FAIL`, and `LOCKOUT`.

```text
                         +--------+
                         |  IDLE  |
                         +---+----+
                             |
                 +-----------+-----------+
                 |                       |
              set=1                   test=1
                 |                       |
                 v                       v
            +---------+             +---------+
            |  SETP   |             |  CHECK  |
            +----+----+             +----+----+
                 |                  /         \
                 |             Correct       Wrong
                 |                |             |
                 v                v             v
               IDLE           +------+      +------+
                              | OPEN |      | FAIL |
                              +--+---+      +--+---+
                                 |             |
                                 |        Attempt count
                                 |             |
                                 |       +-----+-----+
                                 |       |           |
                                 |   < 3 attempts  3rd attempt
                                 |       |           |
                                 |       v           v
                                 |     IDLE      +----------+
                                 |              | LOCKOUT  |
                                 |              +----+-----+
                                 |                   |
                                 |             Timer expires
                                 |                   |
                                 +-------------------+
                                             |
                                            IDLE
```

### FSM States

| State | Description |
|---|---|
| `IDLE` | Normal waiting state |
| `SETP` | Stores the entered password |
| `CHECK` | Compares entered password with stored password |
| `OPEN` | Correct password; unlock is asserted |
| `FAIL` | Incorrect password; failure count is updated |
| `LOCKOUT` | Authentication is disabled until the timer expires |

---

## Password Authentication

The password consists of four 3-bit inputs:

```text
p0
p1
p2
p3
```

These inputs are concatenated to form a 12-bit entered password:

```verilog
assign entered = {p0,p1,p2,p3};
```

During the `SETP` state, the entered password is stored in the password register.

During the `CHECK` state:

```text
        Entered Password
                |
                v
       +------------------+
       | Compare with     |
       | stored password  |
       +--------+---------+
                |
          +-----+-----+
          |           |
        Match       Mismatch
          |           |
          v           v
        OPEN         FAIL
```

---

## Failed Attempt Protection

The system maintains a failed-attempt counter to prevent unlimited password-guessing attempts.

```text
        Wrong Password #1
                |
                v
              FAIL
                |
                v
        Attempt Count = 1
                |
                v
              IDLE
                |
                |
        Wrong Password #2
                |
                v
              FAIL
                |
                v
        Attempt Count = 2
                |
                v
              IDLE
                |
                |
        Wrong Password #3
                |
                v
              FAIL
                |
                v
        Attempt Count = 3
                |
                v
            +---------+
            | LOCKOUT |
            +---------+
                |
                v
        Lockout Timer Runs
                |
                v
        Timer Expires
                |
                v
              IDLE
```

After three consecutive incorrect passwords, the system enters the `LOCKOUT` state.

While locked out:

- The `unlock` output remains inactive.
- Further authentication attempts are prevented.
- The lockout timer continues counting clock cycles.

After the lockout period expires, the system returns to the `IDLE` state.

A successful authentication resets the failed-attempt counter.

---

## Lockout Timer

The lockout duration is controlled using the parameter:

```verilog
parameter integer LOCKOUT_CYCLES = 20;
```

This allows the lockout duration to be changed easily for simulation or implementation.

For example:

```text
LOCKOUT_CYCLES = 20

LOCKOUT
   |
   v
Cycle 1
   |
   v
Cycle 2
   |
   v
  ...
   |
   v
Cycle 20
   |
   v
IDLE
```

The timer is implemented using the `lockout_count` register.

---

## System Cycle Counter

A system cycle counter tracks the number of clock cycles elapsed since reset.

```verilog
reg [31:0] cycle_count;
```

The counter is reset to zero and incremented on each clock cycle.

Its main purpose is to provide timing information during simulation and debugging.

For example:

```text
Cycle 100  → Password check
Cycle 105  → FAIL
Cycle 110  → Second FAIL
Cycle 115  → Third FAIL
Cycle 116  → LOCKOUT
```

---

## Seven-Segment Display

The four 7-segment outputs provide visual status information.

| FSM State | Display |
|---|---|
| `SETP` | `SETP` |
| `OPEN` | `OPEN` |
| `FAIL` | `FAIL` |
| `LOCKOUT` | `LOCK` |

The `unlock` output is asserted only in the `OPEN` state.

---

## Reset

The design uses an asynchronous reset.

When `res` is asserted:

```text
FSM              → IDLE
Attempt Counter  → 0
Lockout Counter  → 0
Cycle Counter    → 0
```

This provides a known initial state for the system.

---

## Simulation

The design is simulated using **ModelSim**.

### Important Simulation Scenarios

#### 1. Password Setting

```text
IDLE → SETP → IDLE
```

The entered password is stored.

#### 2. Correct Password

```text
IDLE → CHECK → OPEN → IDLE
```

The `unlock` signal becomes active during `OPEN`.

#### 3. First Wrong Password

```text
IDLE → CHECK → FAIL → IDLE
```

The failed-attempt counter increases to 1.

#### 4. Second Wrong Password

```text
IDLE → CHECK → FAIL → IDLE
```

The failed-attempt counter increases to 2.

#### 5. Third Wrong Password

```text
IDLE → CHECK → FAIL → LOCKOUT
```

The system enters the lockout state.

#### 6. Lockout Timeout

```text
LOCKOUT
   |
   v
Lockout counter increments
   |
   v
LOCKOUT_CYCLES reached
   |
   v
IDLE
```

---

## RTL View

The RTL schematic generated from the Verilog design is provided below.

![RTL View](diagrams/rtl_view.png)

---

## FSM Diagram

The FSM diagram for the door-lock controller is provided below.

![FSM Diagram](diagrams/fsm.png)

---

## Simulation Results

The ModelSim waveform demonstrating the lockout functionality is provided below.

![Lockout Simulation](simulation/lockout_simulation.png)

The simulation demonstrates the transition from normal authentication to lockout after three consecutive incorrect passwords and the subsequent return to the `IDLE` state after the configured lockout period.

---

## Tools Used

- **Verilog HDL** — RTL design
- **ModelSim** — RTL simulation and waveform analysis
- **FPGA-oriented digital design concepts** — FSMs, counters, registers, password comparison, and display control

---

## Conclusion

This project demonstrates the design of a secure password-based door-lock controller using Verilog RTL.

The implementation combines:

```text
FSM
 |
 v
Password Authentication
 |
 v
Failed-Attempt Detection
 |
 v
3-Attempt Lockout
 |
 v
Lockout Timer
 |
 v
System Cycle Counter
```

The project demonstrates practical application of finite state machines, counters, registers, password comparison, timing control, and FPGA-oriented RTL design.
