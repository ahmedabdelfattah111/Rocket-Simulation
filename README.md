# Rocket Systems & Trajectory Simulation Engine 🚀

An advanced MATLAB GUI-based simulation system for analyzing missile performance, calculating trajectories, and visualizing 3D flight paths.

---

## 📌 Features & GUI Architecture

The application is structured into 5 core GUI windows:

1. **Window 1 (Missile Category Selection):** Select from ballistic missile categories (SRBM, MRBM, IRBM, ICBM) with operational range descriptions and progress indicators.
2. **Window 2 (Rocket Selection & Specifications):** View dynamic technical parameters (dry mass, warhead mass, specific impulse, diameter, mass flow rate) for selected missiles (e.g., Iskander-M, DF-15, Shahab-3, Hyunmoo-5).
3. **Window 3 (Target Designation):** Select authorized targets with live coordinate panel (latitude, longitude, distance, bearing) and operational range validation.
4. **Window 4 (Trajectory Physics Simulation):** Execute physics-based trajectory simulation considering mission parameters (heading angle, ambient temperature, fuel mass) with real-time 10-second telemetry logging.
5. **Window 5 (3D Trajectory Visualization):** Animated 3D flight trajectory scene, live HUD telemetry panel, 6DOF attitude display, and multi-axis performance plots (altitude, velocity, pitch, yaw).

---

## 🛠️ Tech Stack

* **Language:** MATLAB
* **GUI Engine:** MATLAB App Designer / GUIDE
* **Simulation & Math:** MATLAB Aerospace & Control Toolbox / Numerical Integration

---

## 📁 Repository Structure

* `window1.m` to `window5.m`: MATLAB GUI interface code for all 5 program windows.
* `presentation final (2).pptx`: Final project presentation and design documentation.
