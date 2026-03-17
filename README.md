# Assembly – DV1493 Datorteknik (BTH)

Assembly language labs from the course **DV1493 – Datorteknik** at Blekinge Tekniska Högskola.

## Labs

### Lab 1 – Recursive Factorial (ARM)
Recursive subroutine in ARMv7 assembly that computes n! for n = 1–10. Runs in the [CPUlator](https://cpulator.01xz.net/?sys=arm-de1soc) simulator. 

### Lab 2 – Interrupt Handling (ARM)
Interrupt-driven counter on the DE1-SoC (CPUlator). Push buttons trigger IRQ interrupts that increment/decrement a hex digit (0–F) shown on a 7-segment display. Covers the GIC, interrupt vector table, and CPSR manipulation.

### Lab 3 – I/O Library (Intel x64)
A small I/O library in x64 AT&T assembly, callable from C. Provides buffered input/output routines (`inImage`, `outImage`, `getInt`, `putInt`, `getText`, `putText`, `getChar`, `putChar`, etc.)

## Build & Run

- **ARM labs (1 & 2):** Paste source into [CPUlator](https://cpulator.01xz.net/?sys=arm-de1soc) and run.
- **x64 lab (3):** Compile and link with gcc on a Linux x86-64 system:
  ```bash
  gcc -no-pie -o test Mprov64.s io_library.s
  ./test
  ```
