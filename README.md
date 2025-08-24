# 🧠 8-Bit Custom CPU on FPGA

A from-scratch implementation of a fully functional 8-bit CPU in Verilog, synthesized and running on a Digilent Basys 3 FPGA board. This project demonstrates the core principles of computer architecture and digital design.

## ✨ Features

- **🧠 Custom 8-bit Architecture**: Designed from the ground up with a custom ISA.
- **📋 16-Instruction Set**: Supports arithmetic, logic, memory access, and program flow control.
- **💾 Harvard Architecture**: Separate instruction (ROM) and data (RAM) memory spaces.
- **⚡ Fully Synthesizable**: Clean, latch-free Verilog with no timing violations.
- **🎯 Real Hardware Execution**: Runs on a Basys 3 FPGA with visual feedback via LEDs and 7-segment displays.
- **🔧 Complete Toolchain**: Includes constraints, testing programs, and documentation.

## 🏗️ Architecture Overview

### Block Diagram
```
+---------------------------------------+
|               CPU CORE                |
|  +----------------+  +-------------+  |
|  |   CONTROL UNIT |  |   DATAPATH  |  |
|  |   (State       |  |   (Registers|  |
|  |    Machine)    |  |    ALU)     |  |
|  +----------------+  +-------------+  |
+---------------------------------------+
         |                  |
         | Control Signals  | Data/Address
         v                  v
+---------------------------------------+
|             MEMORY SYSTEM             |
|  +-------------+  +----------------+  |
|  |   64B RAM   |  |   192B ROM     |  |
|  |  (Data)     |  |  (Program)     |  |
|  +-------------+  +----------------+  |
+---------------------------------------+
```

### CPU Registers
- **ACC**: 8-bit Accumulator (Primary working register)
- **PC**: 8-bit Program Counter
- **IR**: 8-bit Instruction Register
- **MAR**: Memory Address Register
- **MDR**: Memory Data Register

## 📖 Instruction Set Architecture (ISA)

### Format
All instructions are 8 bits: `[OPCODE (4 bits) | OPERAND (4 bits)]`

| Mnemonic | Opcode | Description | Operation |
| :--- | :--- | :--- | :--- |
| **NOP** | `0x0` | No Operation | `PC ← PC + 1` |
| **ADD** | `0x1` | Add | `ACC ← ACC + RAM[operand]` |
| **SUB** | `0x2` | Subtract | `ACC ← ACC - RAM[operand]` |
| **AND** | `0x3` | Bitwise AND | `ACC ← ACC & RAM[operand]` |
| **LOAD** | `0x4` | Load from Memory | `ACC ← RAM[operand]` |
| **STORE** | `0x5` | Store to Memory | `RAM[operand] ← ACC` |
| **NOT** | `0x6` | Bitwise NOT | `ACC ← ~ACC` |
| **SHL** | `0x7` | Shift Left | `ACC ← ACC << 1` |
| **SHR** | `0x8` | Shift Right | `ACC ← ACC >> 1` |
| **JMP** | `0x9` | Unconditional Jump | `PC ← operand` |
| **JZ** | `0xA` | Jump if Zero | `if (ACC==0) PC ← operand` |
| **JC** | `0xB` | Jump if Carry | `if (CARRY==1) PC ← operand` |

## specifications :

- 8-bit data bus, 8-bit address bus

- 16-instruction custom ISA

- Harvard architecture with separate instruction/data memory

- 64-byte RAM + 192-byte ROM

- 7-segment display and LED debugging interface

## 🚀 Getting Started

### Prerequisites
- **Xilinx Vivado** (2022.x or compatible)
- **Digilent Basys 3** FPGA board
- USB cable for programming

### Installation & Synthesis
1. Clone the repository:
   ```bash
   git clone https://github.com/your-username/8bit-cpu-fpga.git
   cd 8bit-cpu-fpga
   ```

2. Open the project in Vivado:
   ```bash
   vivado 8bit_cpu.xpr
   ```

3. Run synthesis and implementation:
   - Open the project
   - Click "Generate Bitstream"
   - Program the Basys 3 board

### Running the Demo Program
The ROM comes pre-loaded with a demo program that calculates `10 + 5 = 15`:

```asm
LOAD #1    ; Load value from RAM[1]
DATA 10    ; Value 10 stored here
ADD #2     ; Add value from RAM[2] 
DATA 5     ; Value 5 stored here
STORE #3   ; Store result in RAM[3]
JMP #0     ; Loop forever
```

## 📊 Hardware Interface

On the Basys 3:
- **LEDs 0-7**: Display Accumulator (ACC) value
- **LEDs 8-15**: Display current Address bus value
- **7-Segment Display**: Shows Program Counter (PC) value
- **btnC**: Reset button (active high)
- **btnU**: Single-step clock (optional)

## 🗂️ Project Structure

```
8bit-cpu-fpga/
├── src/
│   ├── cpu_8bit.v          # Top-level CPU module
│   ├── control_unit.v      # Finite state machine
│   ├── datapath.v          # Registers and ALU
│   ├── top_basys3.v        # FPGA top module
│   ├── clock_divider.v     # Clock management
│   └── display_7seg.v      # Output display driver
├── constraints/
│   └── basys3.xdc          # Pin constraints
└──  sim/
    └── testbench.v         # Verification testbench

```

## 🔧 Custom Programming

To write your own programs:

1. Modify the ROM in `top_basys3.v`:
   ```verilog
   always @(*) begin
       if (cpu_address >= ROM_BASE) begin
           case (cpu_address)
               ROM_BASE + 0: rom_data = 8'b01000001; // LOAD #1
               ROM_BASE + 1: rom_data = 8'h0A;       // DATA 10
               // Add your instructions here...
   ```

2. Resynthesize and program the FPGA:
   ```tcl
   launch_runs impl_1 -to_step write_bitstream
   program_hw_device
   ```

## 📈 Performance & Resource Usage

| Resource | Utilization | Available | Utilization % |
| :--- | :--- | :--- | :--- |
| **LUTs** | **301** | 20,800 | **~1.45%** |
| **Flip-Flops** | ~609 | 41,600 | ~1.46% |
| **Block RAM** | 1 | 50 | 2% |
| **Timing (WNS)** | +5.64 ns | N/A | ✅ Met |

## 🧪 Testing & Verification

The design includes:
- **Comprehensive testbench** for simulation
- **Timing closure** achieved (WNS > 0)
- **Zero DRC violations**
- **Hardware-verified** on Basys 3

Run the testbench:
```bash
cd sim
xvlog *.v
xelab testbench
xsim testbench
```

## 🚧 Future Enhancements

- [ ] Interrupt controller
- [ ] Stack pointer for subroutine support
- [ ] Expanded instruction set
- [ ] UART interface for program loading
- [ ] VGA output for visual debugging

## 📚 Learnings

This project demonstrates:
- Computer architecture fundamentals
- Verilog RTL design best practices
- FPGA synthesis and timing constraints
- Hardware-software co-design
- Debugging and validation techniques

## 📜 License

This project is licensed under the MIT License - see the [LICENSE.md](LICENSE.md) file for details.

## 🙏 Acknowledgments

- **Digilent** for the excellent Basys 3 platform
- **Xilinx** for Vivado design tools
- The open-source hardware community for inspiration and guidance

---

## 📞 Contact

**daksh vaishnav** - https://www.linkedin.com/in/daksh-vaishnav-3bba94327/ - dakshvaishnavx@gmail.com

Project Link: [https://github.com/prormrxcn/8bit-cpu-fpga](https://github.com/your-username/8bit-cpu-fpga)

---

**⭐️ If you found this project helpful, please give it a star on GitHub!**
