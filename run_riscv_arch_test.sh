#!/usr/bin/env bash

# Abort if any command returns != 0
set -e

cd $(dirname "$0")

header() {
  echo "--------------------------------------------------------------------------"
  echo "> $@"
  echo "--------------------------------------------------------------------------"
}

RISCV_PREFIX="${RISCV_PREFIX:-riscv32-unknown-elf-}"

header "Checking RISC-V GCC toolchain..."
"$RISCV_PREFIX"gcc -v

header "Checking submodules..."
git submodule update --init

header "NEORV32 Processor Version"
grep -rni 'neorv32/rtl/core/neorv32_package.vhd' -e 'hw_version_c'
sleep 2

header "Copying neorv32-specific test-target port into riscv-arch-test framework..."
(
  target_device='riscv-arch-test/riscv-target/neorv32'
  if [ -d "$target_device" ]; then rm -rf "$target_device"; fi
  cp -vr riscv-arch-test-port "$target_device"
  cp -f riscv-arch-test-port/riscv-test-suite/rv32i_m/C/references/* riscv-arch-test/riscv-test-suite/rv32i_m/C/references
  cp -f riscv-arch-test-port/riscv-test-suite/rv32i_m/privilege/references/* riscv-arch-test/riscv-test-suite/rv32i_m/privilege/references 
)

header "Making local copy of NEORV32 'rtl' and 'sim' folders..."

export NEORV32_LOCAL_RTL=${NEORV32_LOCAL_RTL:-$(pwd)/neorv32/sim/work}

rm -rf "$NEORV32_LOCAL_RTL"
cp -r neorv32/rtl "$NEORV32_LOCAL_RTL"
rm -f $NEORV32_LOCAL_RTL/core/mem/*.legacy.vhd

header "Starting RISC-V architecture tests..."

./neorv32/sim/simple/ghdl.setup.sh

# work in progress FIXME
printf "\n"
printf "\e[1;33m[WARNING] Overwriting default 'C/cebreak' and 'privilege/ebreak' test references! \e[0m\n"
printf "\n"
sleep 2


makeArgs="-C $(pwd)/riscv-arch-test NEORV32_VERIF_ROOT=$(pwd)/. NEORV32_ROOT=$(pwd)/neorv32/. XLEN=32 RISCV_TARGET=neorv32"
makeTargets='clean build run verify'

[ -n "$1" ] && SUITES="$@" || SUITES='I C M privilege Zifencei'

for suite in $SUITES; do
  case "$suite" in
    I) make --silent $makeArgs SIM_TIME=850us RISCV_DEVICE=I $makeTargets;;
    C) make --silent $makeArgs SIM_TIME=400us RISCV_DEVICE=C $makeTargets;;
    M) make --silent $makeArgs SIM_TIME=800us RISCV_DEVICE=M $makeTargets;;
    privilege) make --silent $makeArgs SIM_TIME=200us RISCV_DEVICE=privilege $makeTargets;;
    Zifencei) make --silent $makeArgs SIM_TIME=200us RISCV_DEVICE=Zifencei RISCV_TARGET_FLAGS=-DNEORV32_NO_DATA_INIT $makeTargets;;

    rv32e_C) make --silent $makeArgs SIM_TIME=200us RISCV_DEVICE=../rv32e_unratified/C $makeTargets;;
    rv32e_E) make --silent $makeArgs SIM_TIME=200us RISCV_DEVICE=../rv32e_unratified/E $makeTargets;;
    rv32e_M) make --silent $makeArgs SIM_TIME=200us RISCV_DEVICE=../rv32e_unratified/M $makeTargets;;
  esac
done

header "RISC-V architecture tests completed!"
