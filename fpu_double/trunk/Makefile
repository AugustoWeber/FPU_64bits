# ----------------------------------------------------------------------------
# Copyright (c) 2020-2025 RVX contributors
#
# This work is licensed under the MIT License, see LICENSE file for details.
# SPDX-License-Identifier: MIT
# ----------------------------------------------------------------------------

MAKEFLAGS += --no-print-directory

RTL_LIST  = ../fpupack.vhd 
RTL_LIST += ../comppack.vhd 
RTL_LIST += ../fpu_round.vhd 
RTL_LIST += ../fpu_div.vhd 
RTL_LIST += ../fpu_mul.vhd 
RTL_LIST += ../fpu_sub.vhd 
RTL_LIST += ../fpu_exceptions.vhd 
RTL_LIST += ../fpu_add.vhd 
RTL64_LIST = ${RTL_LIST} ../fpu_double.vhd ../fpu_double_TB.vhd 
RTL16_LIST = ${RTL_LIST} ../my_fpu_double.vhd ../my_fpu_double_TB.sv
XRUN_ARGS = -top fpu_double_TB -v2019 -64bit -access +rw -gui 
XRUN_ARGS_PWR = ${XRUN_ARGS} -lps_1801 ../fpu_double.upf -lps_logfile lps.log -lps_verbose 3 -lps_psn_verbose 2
all: sim16

sim16:
	@cd sim_16 && xrun -clean && xrun ${RTL16_LIST} ${XRUN_ARGS}

sim16-pwr:
	@cd sim_16-pwr && xrun -clean && xrun ${RTL16_LIST} ${XRUN_ARGS_PWR}

sim64:
	@cd sim_64 && xrun -clean && xrun ${RTL64_LIST} ${XRUN_ARGS}

clean:
# 	@rm -rf build dump
# 	@echo "Build directory deleted."
# 	@rm -rf sim

.PHONY: sim16 sim16-pwr sim64
