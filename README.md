# NEORV32 RISC-V Architecture Test

[![riscv-arch-test](https://img.shields.io/github/workflow/status/stnolting/neorv32-verif/riscv-arch-test/main?longCache=true&style=flat-square&label=riscv-arch-test&logo=Github%20Actions&logoColor=fff)](https://github.com/stnolting/neorv32-verif/actions?query=workflow%3Ariscv-arch-test)

This repository is used to test the [NEORV32 Processor](https://github.com/stnolting/neorv32)
for compatibility to the RISC-V ISA specs. by running the official
[RISC-V Architecture Test Framework](https://github.com/riscv-non-isa/riscv-arch-test).
Currently, the following tests are supported:

- [x] `rv32i_m/C` - compressed instructions
- [x] `rv32i_m/I` - base integer ISA
- [x] `rv32i_m/M` - integer multiplication and division
- [x] `rv32i_m/privilege` - privileged architecture (traps/exceptions)
- [x] `rv32i_m/Zifencei` - instruction stream synchronization

The test results can be found in the [Actions](https://github.com/stnolting/neorv32-verif/actions) logs.

Running the tests requires _all_ submodules from this repository, a
[RISC-V GCC toolchain](https://github.com/stnolting/riscv-gcc-prebuilt) and
[GHDL](https://github.com/ghdl/ghdl) for RTL simulation.


## NEORV32 Port of the RISC-V Architecture Test Framework

All tests are run via the `./sim/run_riscv_arch_test.sh` script. A specific test suite (like `C`) can be
passed as argument. Once started, the script performs the following operations prior to running the actual
tests:

* Make a local copy of the NEORV32 RTL folder in `neorv32/sim/work`.
* Install (copy) the NEORV32-specific test target port files from `sw/isa-test/port-neorv32` to the
test suite's target folder `work/riscv-arch-test/riscv-target/neorv32`.
* Override the default frameworks reference data for `C/cebreak-01` and `privilege/ebreak` tests
  ([PR #289](https://github.com/stnolting/neorv32/pull/289)).
  * This is required as the NEORV32 sets `mtval` CSR to zero on software breakpoints.
* Run the actual tests.

For each test suite (like `rv32i_m/C`) the following steps are executed by the device makefile:

* Replace the original processor's IMEM rtl file by a simulation-optimized IMEM (ROM!).
* `sed` command is used to modify the default "simple" testbench `neorv32/sim/simple/neorv32_tb.simple.vhd`:
  * Set the according CPU ISA extension configuration generics.
  * Set the processor memory configuration (IMEM & DMEM).
* Compile test code and install application image to processor's RTL folder:
  * Compilation uses the `link.imem_rom.ld` linker script as default; the test code is executed
    from a simulation-optimized IMEM (which is read-only) RTL module; data including signature is stored to DMEM.
  * Certain areas in the DMEM are initialized using port code in `model_test.h` (`RVTEST` = `0xbabecafe` and
    `SIGNATURE` = `0xdeadbeef`); this can be disabled using `RISCV_TARGET_FLAGS=-DNEORV32_NO_DATA_INIT`
  * The `sw/example/blink_led` software project is used to create a final executable.
* The results are dumped via the SIM_MODE feature of UART0.
  * The according code can be found in the `RVMODEL_HALT` macro in `model_test.h`.
  * The data output (= "signature") is zero-padded to be always a multiple of 16 bytes.


## Notes

:warning: The default RISC-V architecture tests will be superseded by the RISCOF test framework.
I am planning to make a port for this new test framework.

:warning: Simulating all the test cases takes quite some time. Some tests use an optimized description
of IMEM (`neorv32_imem.simple.vhd`), but others require the original because they execute self-modifying code.

:warning: If the simulation of a test does not generate any signature output at all or if the signature
is truncated, try increasing the simulation time by modifying the `SIM_TIME` variable when calling the
test makefiles in `run_riscv_arch_test.sh`.

:information_source: The `Zifencei` test requires the r/w/e capabilities of the original IMEM rtl file.
Hence, the original file is restored for this test. Also, this test uses `link.imem_ram.ld` as linker script since the
IMEM is used as RAM to allow self-modifying code.

:information_source: The `RVMODEL_BOOT` macro in `model_test.h` provides a simple "dummy trap handler" that just advances
to the next instruction. This trap handler is required for some `C` tests as the NEORV32 will raise an illegal instruction
exception for **all** unimplemented instructions. The trap handler can be overridden (by changing `mtval` CSR) if a test
uses the default trap handler of the test framework.
