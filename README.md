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

FSM Design
                    +------+
                    | IDLE |
                    +--+---+
                       |
          +------------+------------+
          |                         |
       SET=1                     TEST=1
          |                         |
          v                         v
      +-------+                +---------+
      | SETP  |                |  CHECK  |
      +---+---+                +----+----+
          |                    /         \
          |              Correct        Wrong
          |                  /             \
          v                 v               v
        IDLE             +------+        +------+
                         | OPEN |        | FAIL |
                         +--+---+        +--+---+
                            |               |
                            v          Failure count
                           IDLE             |
                                            |
                                      3rd failure
                                            |
                                            v
                                      +----------+
                                      | LOCKOUT  |
                                      +----+-----+
                                           |
                                     Timer expires
                                           |
                                           v
                                         IDLE
Failed Attempt Protection:
                                 Wrong Password #1
                                         ↓
                                        FAIL

                                 Wrong Password #2
                                          ↓
                                        FAIL

                                 Wrong Password #3
                                          ↓
                                       LOCKOUT
