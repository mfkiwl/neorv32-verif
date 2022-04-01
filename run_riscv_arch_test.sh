#!/usr/bin/env bash

# Abort if any command returns != 0
set -e

cd $(dirname "$0")

header() {
  echo "--------------------------------------------------------------------------"
  echo "> $@..."
  echo "--------------------------------------------------------------------------"
}

RISCV_PREFIX="${RISCV_PREFIX:-riscv32-unknown-elf-}"

header "Checking RISC-V GCC toolchain"
"$RISCV_PREFIX"gcc -v

header "Checking submodules"
git submodule update --init

header "Copying neorv32-specific test-target port into riscv-arch-test framework"
(
  target_device='riscv-arch-test/riscv-target/neorv32'
  if [ -d "$target_device" ]; then rm -rf "$target_device"; fi
  cp -vr riscv-arch-test-port "$target_device"
  cp -f riscv-arch-test-port/riscv-test-suite/rv32i_m/C/references/* riscv-arch-test/riscv-test-suite/rv32i_m/C/references
  cp -f riscv-arch-test-port/riscv-test-suite/rv32i_m/privilege/references/* riscv-arch-test/riscv-test-suite/rv32i_m/privilege/references 
)

header "Making local copy of NEORV32 'rtl' and 'sim' folders"

export NEORV32_LOCAL_RTL=${NEORV32_LOCAL_RTL:-$(pwd)/neorv32/sim/work}

rm -rf "$NEORV32_LOCAL_RTL"
cp -r neorv32/rtl "$NEORV32_LOCAL_RTL"
rm -f $NEORV32_LOCAL_RTL/core/mem/*.legacy.vhd

header "Starting RISC-V architecture tests"

./neorv32/sim/simple/ghdl.setup.sh

# work in progress FIXME
printf "\n"
printf "\e[1;33m[WARNING] 'I/jal-01' test is currently disabled (GHDL simulation issue)! \e[0m\n"
printf "\e[1;33m[WARNING] Overwriting default 'C/cebreak' and 'privilege/ebreak' test references! \e[0m\n"
printf "\n"
sleep 2


makeArgs="-C $(pwd)/riscv-arch-test NEORV32_VERIF_ROOT=$(pwd)/. NEORV32_ROOT=$(pwd)/neorv32/. XLEN=32 RISCV_TARGET=neorv32"
makeTargets='clean build run verify'

[ -n "$1" ] && SUITES="$@" || SUITES='I C M privilege Zifencei'

for suite in $SUITES; do
  case "$suite" in
    I) make --silent $makeArgs SIM_TIME=200us RISCV_DEVICE=I clean build;
       make --silent $makeArgs SIM_TIME=600us RISCV_DEVICE=I RISCV_TEST='add-01' run;
       make --silent $makeArgs SIM_TIME=600us RISCV_DEVICE=I RISCV_TEST='addi-01' run;
       make --silent $makeArgs SIM_TIME=600us RISCV_DEVICE=I RISCV_TEST='and-01' run;
       make --silent $makeArgs SIM_TIME=600us RISCV_DEVICE=I RISCV_TEST='andi-01' run;
       make --silent $makeArgs SIM_TIME=600us RISCV_DEVICE=I RISCV_TEST='auipc-01' run;
       make --silent $makeArgs SIM_TIME=850us RISCV_DEVICE=I RISCV_TEST='beq-01' run;
       make --silent $makeArgs SIM_TIME=850us RISCV_DEVICE=I RISCV_TEST='bge-01' run;
       make --silent $makeArgs SIM_TIME=850us RISCV_DEVICE=I RISCV_TEST='bgeu-01' run;
       make --silent $makeArgs SIM_TIME=850us RISCV_DEVICE=I RISCV_TEST='blt-01' run;
       make --silent $makeArgs SIM_TIME=850us RISCV_DEVICE=I RISCV_TEST='bltu-01' run;
       make --silent $makeArgs SIM_TIME=850us RISCV_DEVICE=I RISCV_TEST='bne-01' run;
#      make --silent $makeArgs SIM_TIME=850us RISCV_DEVICE=I RISCV_TEST='jal-01' run;
       make --silent $makeArgs SIM_TIME=850us RISCV_DEVICE=I RISCV_TEST='jalr-01' run;
       make --silent $makeArgs SIM_TIME=200us RISCV_DEVICE=I RISCV_TEST='lb-align-01' run;
       make --silent $makeArgs SIM_TIME=200us RISCV_DEVICE=I RISCV_TEST='lbu-align-01' run;
       make --silent $makeArgs SIM_TIME=200us RISCV_DEVICE=I RISCV_TEST='lh-align-01' run;
       make --silent $makeArgs SIM_TIME=200us RISCV_DEVICE=I RISCV_TEST='lhu-align-01' run;
       make --silent $makeArgs SIM_TIME=200us RISCV_DEVICE=I RISCV_TEST='lui-01' run;
       make --silent $makeArgs SIM_TIME=200us RISCV_DEVICE=I RISCV_TEST='lw-align-01' run;
       make --silent $makeArgs SIM_TIME=600us RISCV_DEVICE=I RISCV_TEST='or-01' run;
       make --silent $makeArgs SIM_TIME=600us RISCV_DEVICE=I RISCV_TEST='ori-01' run;
       make --silent $makeArgs SIM_TIME=200us RISCV_DEVICE=I RISCV_TEST='sb-align-01' run;
       make --silent $makeArgs SIM_TIME=200us RISCV_DEVICE=I RISCV_TEST='sh-align-01' run;
       make --silent $makeArgs SIM_TIME=600us RISCV_DEVICE=I RISCV_TEST='sll-01' run;
       make --silent $makeArgs SIM_TIME=600us RISCV_DEVICE=I RISCV_TEST='slli-01' run;
       make --silent $makeArgs SIM_TIME=600us RISCV_DEVICE=I RISCV_TEST='slt-01' run;
       make --silent $makeArgs SIM_TIME=600us RISCV_DEVICE=I RISCV_TEST='slti-01' run;
       make --silent $makeArgs SIM_TIME=600us RISCV_DEVICE=I RISCV_TEST='sltiu-01' run;
       make --silent $makeArgs SIM_TIME=600us RISCV_DEVICE=I RISCV_TEST='sltu-01' run;
       make --silent $makeArgs SIM_TIME=600us RISCV_DEVICE=I RISCV_TEST='sra-01' run;
       make --silent $makeArgs SIM_TIME=600us RISCV_DEVICE=I RISCV_TEST='srai-01' run;
       make --silent $makeArgs SIM_TIME=600us RISCV_DEVICE=I RISCV_TEST='srl-01' run;
       make --silent $makeArgs SIM_TIME=600us RISCV_DEVICE=I RISCV_TEST='srli-01' run;
       make --silent $makeArgs SIM_TIME=600us RISCV_DEVICE=I RISCV_TEST='sub-01' run;
       make --silent $makeArgs SIM_TIME=200us RISCV_DEVICE=I RISCV_TEST='sw-align-01' run;
       make --silent $makeArgs SIM_TIME=600us RISCV_DEVICE=I RISCV_TEST='xor-01' run;
       make --silent $makeArgs SIM_TIME=600us RISCV_DEVICE=I RISCV_TEST='xori-01' run;
       make --silent $makeArgs SIM_TIME=200us RISCV_DEVICE=I RISCV_TEST='fence-01' run;
       make --silent $makeArgs SIM_TIME=200us RISCV_DEVICE=I RISCV_TEST='fence-01' verify;;
    C) make --silent $makeArgs SIM_TIME=400us RISCV_DEVICE=C $makeTargets;;
    M) make --silent $makeArgs SIM_TIME=800us RISCV_DEVICE=M $makeTargets;;
    privilege) make --silent $makeArgs SIM_TIME=200us RISCV_DEVICE=privilege $makeTargets;;
    Zifencei) make --silent $makeArgs SIM_TIME=200us RISCV_DEVICE=Zifencei RISCV_TARGET_FLAGS=-DNEORV32_NO_DATA_INIT $makeTargets;;

    rv32e_C) make --silent $makeArgs SIM_TIME=200us RISCV_DEVICE=../rv32e_unratified/C $makeTargets;;
    rv32e_E) make --silent $makeArgs SIM_TIME=200us RISCV_DEVICE=../rv32e_unratified/E $makeTargets;;
    rv32e_M) make --silent $makeArgs SIM_TIME=200us RISCV_DEVICE=../rv32e_unratified/M $makeTargets;;
  esac
done

printf "\nRISC-V architecture tests completed successfully!\n"
