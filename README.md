# SystemVerilog 1-to-4 Packet Switch with FIFO Buffer

## 📌 Project Overview
This project implements a digital packet switch capable of routing data from a single input source to one of four output devices. It utilizes an internal FIFO (First-In-First-Out) buffer to handle data flow and decouple the input timing from the output processing.

The design is written in **SystemVerilog** and is suitable for FPGA implementation or ASIC prototyping.

## ⚙️ Architecture

The system consists of two main modules:

1.  **FIFO Buffer (`fifo.sv`)**:
    * [cite_start]Configurable depth (Default: 4 words) and width (Default: 8 bits)[cite: 1].
    * [cite_start]Handles `full` and `empty` flags to prevent overflow/underflow[cite: 8, 10].
    * [cite_start]Uses circular pointer logic for read/write operations[cite: 15, 18].

2.  **Switch Logic (`switch.sv`)**:
    * [cite_start]Reads data from the FIFO when valid data is available and the destination is ready[cite: 29].
    * **Packet Structure**: The 8-bit input data is split into:
        * [cite_start]**Header (2 MSB)**: Address bits `[7:6]` used to select the output device (0-3)[cite: 31].
        * [cite_start]**Payload (6 LSB)**: The actual data bits `[5:0]` sent to the device[cite: 32].
    * [cite_start]**Routing**: Routes the payload to `device0`, `device1`, `device2`, or `device3` based on the header [cite: 37-42].

## 📊 Simulation Results

The design was verified using a testbench (`tb_switch.sv`) which generates random traffic with incrementing payloads and target addresses.

**Waveform Output:**
Below is the simulation result showing the distribution of packets to different devices based on the address bits.
![Simulation Waveform](docs/waveform.png)
*(Note: As seen in the waveform, input data like `11000100` is routed to Device 3 because the MSB is `11`)*.

## 🛠️ Interface Signals

| Signal | Direction | Width | Description |
| :--- | :--- | :--- | :--- |
| `clk_i` | Input | 1 | System Clock |
| `rst_i` | Input | 1 | Active Low Reset |
| `valid_i` | Input | 1 | Input Data Valid |
| `data_in` | Input | 8 | Input Packet (Addr + Data) |
| `ready_o` | Output | 1 | Switch Ready (FIFO not full) |
| `device0-3`| Output | 6 | Output Payloads |
| `valid_out`| Output | 4 | Valid flags for each channel |

## 🚀 How to Run
1.  Clone the repository.
2.  Open the files in your preferred simulator (ModelSim, Vivado, Questasim, EDA Playground).
3.  Compile `fifo.sv`, `switch.sv`, and `tb_switch.sv`.
4.  Run the simulation for 100ns+.

## 📜 License
MIT License
