# DC Motor Mathematical Modeling and Simulation in MATLAB/Simulink

This repository contains a comprehensive **dynamic model of a Separately Excited DC Motor**, implemented as a structural block diagram in Simulink. The project demonstrates the interaction between the electrical armature circuit and the mechanical load system.

## 🚀 Project Overview
The primary goal of this simulation is to analyze the transient response of armature current ($I_a$) and angular velocity ($\omega$) during two critical phases:

* **Soft-Start Phase**: A controlled voltage ramp-up to prevent high inrush currents.
* **Load Impact Phase**: The system's response to a sudden nominal torque ($M_{load}$) application.

### Key Features:
* **Voltage Ramp & Saturation**: Implements a linear voltage increase from $0$ to $400V$ over $3$ seconds, utilizing a Saturation block to maintain steady-state nominal voltage.
* **Structural Modeling**: Built using fundamental integrators and gain blocks to maintain a clear 1:1 relationship with the underlying physics.
* **Dynamic Parameter Integration**: All motor constants ($R_a, L_a, J, \Psi_P, k_w$) are dynamically pulled from the MATLAB Workspace for easy tuning.
* **Load Disturbance Analysis**: Simulates a step-load torque at $t = 7s$ to evaluate speed regulation and current compensation.

## 📊 Mathematical Foundation
The system is governed by the following coupled first-order differential equations:

**Electrical Subsystem:**
$$\frac{dI_a}{dt} = \frac{1}{L_a} (U_a - R_a I_a - \Psi_P \omega)$$

**Mechanical Subsystem:**
$$\frac{d\omega}{dt} = \frac{1}{J} (\Psi_P I_a - M_{load} - k_w \omega)$$

## 🛠️ Usage Instructions
1. **Initialize**: Run the `mjs.m` script to load all variables into the MATLAB Workspace.
2. **Open Model**: Launch `mmodel_dcMotor.slx` in Simulink.
3. **Solver Settings**: Ensure the solver is set to **Fixed-step (ode4)** with a step size of $10\mus$ for high-fidelity results.
4. **Simulate**: Click **Run** and observe the Scope outputs for Current and Speed.

---
**Author:** Annum
**Field:** Computing and Automation (Focus on Component Modeling)
