# DC Motor Mathematical Modeling and Simulation in MATLAB/Simulink

This repository contains a comprehensive **dynamic model of a Separately Excited DC Motor**, implemented as a structural block diagram in Simulink. The project demonstrates the interaction between the electrical armature circuit and the mechanical load system.

## 🚀 Project Overview
The primary goal of this simulation is to analyze the transient response of armature current (I_a) and angular velocity (w) during two critical phases:

* **Soft-Start Phase**: A controlled voltage ramp-up to prevent high inrush currents.
* **Load Impact Phase**: The system's response to a sudden nominal torque (M_load) application.

### Key Features:
* **Voltage Ramp & Saturation**: Implements a linear voltage increase from 0 to 400V over 3 seconds, utilizing a Saturation block to maintain steady-state nominal voltage.
* **Structural Modeling**: Built using fundamental integrators and gain blocks to maintain a clear 1:1 relationship with the underlying physics.
* **Dynamic Parameter Integration**: All motor constants (R_a, L_a, J, \Psi_P, k_w) are dynamically pulled from the MATLAB Workspace for easy tuning.
* **Load Disturbance Analysis**: Simulates a step-load torque at t = 7s to evaluate speed regulation and current compensation.

## 📊 Mathematical Foundation
The system is governed by the following coupled first-order differential equations:

**Electrical Subsystem:**
dI_a/dt = 1/L_a * (U_a - R_a*I_a - flux_p * w)

**Mechanical Subsystem:**
dw/dt = 1/J*(flux_p*I_a - M_load - k*w)

## 🛠️ Usage Instructions
1. **Initialize**: Run the `mjs.m` script to load all variables into the MATLAB Workspace.
2. **Open Model**: Launch `mmodel_dcMotor.slx` in Simulink.
3. **Solver Settings**: Ensure the solver is set to **Fixed-step (ode4)** with a step size of 10micro-sec for high-fidelity results.
4. **Simulate**: Click **Run** and observe the Scope outputs for Current and Speed.
