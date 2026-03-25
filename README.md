# DSP48A1-Spartan-6
# Custom Spartan-6 FPGA DSP Slice

A configurable Digital Signal Processing (DSP) block implemented in Verilog, inspired by the **DSP48A1** architecture found in Xilinx Spartan-6 FPGAs. The design supports addition, subtraction, and multiplication with flexible data routing via multiplexing and multi-stage pipelining.

---

## Overview

This project constructs a pipelined arithmetic unit that mirrors the structure of the DSP48A1 primitive. The datapath is split into multiple pipeline stages to maximize throughput and reflect realistic hardware design practices.

The design was simulated in **QuestaSim**, linted with **QuestaLint**, and synthesized using **Xilinx Vivado** targeting the `xc7a200tffg1156-3` device.

---

## Project Structure

```
├── pipeline_reg.v       # Parameterizable pipeline register (Phase 1)
├── dsp_parent.v         # Top-level DSP block (Phase 2)
├── pipeline_tb.v        # Testbench for pipeline register
├── dsp_parent_tb.v      # Testbench for parent DSP block
├── run_pipeline.do      # QuestaSim DO file for Phase 1 simulation
├── run_dsp.do           # QuestaSim DO file for Phase 2 simulation
└── constraints.xdc      # Vivado timing constraints (100 MHz clock on W5)
```

---

## Design Phases

### Phase 1 — Pipeline Register (`pipeline_reg`)

A parameterizable register module with the following features:

| Parameter | Default | Description |
|-----------|---------|-------------|
| `WIDTH`   | 48      | Data bus width |
| `RSTTYPE` | `"SYNC"` | Reset type: `"SYNC"` or `"ASYNC"` |

**Ports:** `clk`, `rst`, `EN` (clock enable), `sel` (bypass/register select), `in`, `out`

**Behavior:**
- `sel = 1` → registered output (data passes through flip-flops)
- `sel = 0` → bypass mode (combinational pass-through)
- `EN = 0` → register holds its last value
- `RSTTYPE = "ASYNC"` → reset takes effect immediately, mid-cycle
- `RSTTYPE = "SYNC"` → reset is captured only on the next rising clock edge

### Phase 2 — Parent DSP Block (`dsp_parent`)

The top-level module instantiates multiple `pipeline_reg` instances and connects them with arithmetic and mux logic to form the full DSP datapath.

**Key inputs:**

| Signal | Width | Description |
|--------|-------|-------------|
| `A`, `B`, `D` | 18-bit | Primary data inputs |
| `C` | 48-bit | Cascade/accumulator input |
| `OPMODE_in` | 8-bit | Operation mode selector |
| `PCIN` | 48-bit | P-cascade input |
| `BCIN` | 18-bit | B-cascade input |
| `CARRYIN` | 1-bit | Carry input |

**Key outputs:**

| Signal | Width | Description |
|--------|-------|-------------|
| `P` | 48-bit | Post-adder/subtractor output |
| `M` | 36-bit | Multiplier output |
| `PCOUT` | 48-bit | P-cascade output |
| `BCOUT` | 18-bit | B-cascade output |
| `CARRYOUT` | 1-bit | Carry output |

**Datapath stages (controlled by `OPMODE`):**

```
Pre-Adder/Subtractor  →  Multiplier  →  X/Z Mux  →  Post-Adder/Subtractor  →  P Register
      (D ± B0)              (A1×B1)                      (X + Z ± CIN)
```

**Configurable parameters:**

```verilog
parameter A0REG = 0, A1REG = 1, B0REG = 0, B1REG = 1,
          CREG = 1, DREG = 1, MREG = 1, PREG = 1,
          CARRYINREG = 1, CARRYOUTREG = 1, OPMODEREG = 1;
parameter CARRYINSEL = "OPMODE5"; // or "CARRYIN"
parameter B_INPUT    = "DIRECT";  // or "CASCADE"
parameter RSTTYPE    = "SYNC";    // or "ASYNC"
```

---

## Simulation

### Phase 1 Test Cases

| # | Test | Expected Result |
|---|------|----------------|
| 1 | Reset assertion (sync & async) | Output clears to 0; async reacts mid-cycle |
| 2 | Clock enable (`EN`) | Register holds value when `EN=0` |
| 3 | Bypass select (`sel=0`) | Output follows input combinationally |
| 4 | Async vs Sync reset comparison | Async clears immediately; sync waits for rising edge |

### Phase 2 Test Cases

| # | OPMODE | Operation | Expected Outputs |
|---|--------|-----------|-----------------|
| 1 | `8'b11011101` | Full datapath: pre-add, multiply, accumulate | `BCOUT=0x32`, `M=0x12c`, `P=0x32` |
| 2 | `8'b00010000` | Pass-through / zeroed paths | `BCOUT=0x23`, `M=0x2bc`, `P=0` |
| 3 | `8'b00001010` | Alternate Z-mux path | `BCOUT=0xa`, `M=0xc8`, `P=0` |
| 4 | `8'b10100111` | PCIN accumulation with carry | `P=0xfe6fffec0bb1`, `CARRYOUT=1` |

Run simulation in QuestaSim:
```tcl
do run_dsp.do
```

---

## Synthesis (Vivado)

- **Target device:** `xc7a200tffg1156-3` (Artix-7 200T)
- **Clock constraint:** 100 MHz on pin W5
- **Timing result:** All user-specified constraints met (WNS = 4.813 ns)
- **DSP utilization:** 1 × DSP48E1 primitive inferred
- **LUT utilization:** 231 Slice LUTs (< 1% of device)

> Timing warnings for missing I/O delay constraints (`no_input_delay`, `no_output_delay`) are expected and do not affect functional correctness — external I/O timing is outside the scope of this design.

---

## Tools Used

| Tool | Purpose |
|------|---------|
| Xilinx Vivado | Synthesis, implementation, timing analysis |
| QuestaSim | RTL simulation and waveform analysis |
| QuestaLint | Static RTL linting (Quality Score: **99.1%**) |

---

## Author

**Abdulrahman Mahmoud Rady**
