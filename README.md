# Finite-State-Machine-based-Elevator-Controller
This project implements a Finite State Machine(FSM)-based elevator controller🛗 for a 3-floor elevator system. It is designed in VHDL and I might do it in verilog in the near future 😉.

I am currently writing a testbench in VHDL to test the FSM and make it better.

## More about the controller
- The controller manages
  - Motor direction control(Up/Down/Stop)
  - Safe dooe operations at each floor
  - Request handling from both call buttons(outside) and cabin buttons(inside)
  - Scheduling of requests for multiple ones
- I tried to imitate the real world scenarios by using all these.

## Features
- 8 FSM states : Idle at each floor, Moving up, Moving down and Door-open at each floor
- Door Timer : Keeps doors open for a fixed duration before resuming operations
- Motor Control : 2-bit motor signal ( 00 = stop, 10 = up, 01 = down)

## FSM Design📈
         ┌──────────┐
         │  IDLE_0  │◄────────────┐
         └────┬─────┘             │
              │ Request Up         │
              ▼                    │
         ┌──────────┐              │
         │MOVING_UP │              │
         └────┬─────┘              │
              │ Arrive Floor 1     │
              ▼                    │
        ┌────────────┐             │
        │ DOOR_OPEN_1│             │
        └────┬───────┘             │
             │ Timer Expired       │
             ▼                     │
         ┌──────────┐              │
         │  IDLE_1  │◄─────────────┘
         └────┬─────┘
              │ Request Down
              ▼
         ┌──────────┐
         │MOVING_DOWN│
         └────┬─────┘
              │ Arrive Floor 0
              ▼
         ┌──────────┐
         │ DOOR_OPEN_0│
         └───────────┘
👉 There are many more transitions like this!!

## Learnings
- FSM design and hardware modelling in VHDL
- Request scheduling for real-world systems

## Author
Sai Vishal Reddy Malireddy
 
-- Undergrad, ⚡Electrical Major, IIT Bombay
