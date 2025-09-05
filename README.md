#  RISC-V ALU with Integrated IEEE-754 Floating Point Unit (FPU)



This repository contains a modified `ALU` module for a RISC-V based CPU design. Unlike traditional ALUs which only support integer arithmetic, this version supports both **integer** and **IEEE-754 single-precision floating-point operations**. It is seamlessly integrated into a RISC-V 5-stage pipeline CPU to enable mixed arithmetic workloads, reflecting real-world processor needs.

---

🧠 Motivation

In today’s compute-heavy workloads, floating-point operations are crucial — especially for AI, signal processing, and graphics. This project integrates IEEE-754 floating point support directly into a RISC-V pipeline CPU to provide a more realistic and versatile design experience while strengthening RTL design skills.

---

## 🚀 Key Features

- ✅ **Dual-Mode ALU**: Performs either integer or floating-point arithmetic based on the `type_op_ctrl_i` signal.
- ✅ **IEEE-754 Compliant Operations**:
  - Floating-point Addition
  - Floating-point Subtraction
  - Floating-point Multiplication (with normalization + rounding)
  - Floating-point Division (with normalization + rounding)
- ✅ **Mantissa Alignment** for Add/Sub
- ✅ **GRS Rounding (Guard, Round, Sticky)** in MUL/DIV
- ✅ Compatible with existing 5-stage RISC-V pipeline design
- ✅ No structural hazard introduced — can plug directly into EX stage

---

## 🧩 Module Interface

### ALU Ports

```verilog
module ALU (
  input clk_i,
  input [31:0] data1_i,     // Operand A
  input [31:0] data2_i,     // Operand B
  input [2:0]  ALUCtrl_i,   // Operation Selector (e.g., ADD, SUB, etc.)
  input        type_op_ctrl_i, // 0 = FPU, 1 = Integer ALU
  output reg [31:0] data_o,    // Result
  output reg Zero_o           // Zero flag (used in branching)
);
```
## ⚙️ Operation Modes

- **Integer Mode** (`type_op_ctrl_i = 1`)
  - Supports traditional operations:
    - ADD
    - SUB
    - MUL
    - DIV

- **Floating Point Mode** (`type_op_ctrl_i = 0`)
  - Performs IEEE-754 compliant operations using:
    - Mantissa extraction
    - Exponent comparison and alignment
    - 24-bit multiplication
    - Normalization using leading-one detection
    - GRS rounding logic
    - Reconstructs final 32-bit IEEE-754 output

## 🔁 Pipeline Integration

This ALU is integrated into a RISC-V 5-stage pipeline CPU with the following structure:

IF → ID → EX (ALU/FPU) → MEM → WB

- The ALU is instantiated in the **EX** stage.
- Switching between integer and floating-point operations is dynamically controlled using the `type_op_ctrl_i` signal.

## 🧪 Debug & Verification

Each operation includes `$display` logs to trace the following:

- Mantissas before and after alignment
- Raw and normalized products
- Rounding decisions
- Final IEEE-754 output
- 

🏗️ Future Plans
 Add exception support for NaNs, Infinities, subnormals

 Extend to support Double Precision (64-bit)

 Design a standalone FPU co-processor (decoupled from ALU)

 Add branch prediction unit to CPU

 Run mixed FPU + ALU instruction tests
