# ================================================================
# Copyright (c) 2016 Bluespec, Inc.  All Rights Reserved.
# This is an example Makefile for the examples in the standard
# Bluespec training session.

# You should only have to edit the variable definitions in the
# following section (or override them from the 'make' command line)

# You should also have performed your standard Bluespec setup, defining
# environment variables BLUESPECDIR, BLUESPEC_HOME and
# BLUESPEC_LICENSE_FILE, and placing $BLUESPEC_HOME/bin in your path
# so that you can invoke 'bsc', the Bluespec compiler.

# ================================================================
# Please modify the following for your installation and setup

# Directory for the specific example you are building
EG ?= Eg02a_HelloWorld

# Directory containing the Bluespec Training distribution directory
DISTRO ?= ..

# Set this to the command that invokes your Verilog simulator
# VSIM ?= iverilog
VSIM ?= cvc
# VSIM ?= cver
# VSIM ?= vcsi
# VSIM ?= vcs
# VSIM ?= modelsim
# VSIM ?= ncsim
# VSIM ?= ncverilog

# ================================================================
# You should not have to change anything below this line

#If you want to perform Synthesis, set the top file as pbox.bsv
#If you want to perform debugging, set the top file as pBoxTB.bsv

TOPFILE   = pBoxTB.bsv
TOPMODULE = mkTb

BSC_COMP_FLAGS = -elab -keep-fires -aggressive-conditions -no-warn-action-shadowing -show-range-conflict
BSC_LINK_FLAGS = -keep-fires


.PHONY: help
help:
	@echo "Current settings"
	@echo "    BLUESPEC_LICENSE_FILE = " $(BLUESPEC_LICENSE_FILE)
	@echo "    BLUESPEC_HOME         = " $(BLUESPEC_HOME)
	@echo "    BLUESPECDIR           = " $(BLUESPECDIR)
	@echo ""
	@echo "    EG                    = " $(EG) " (redefine EG for another example)"
	@echo ""
	@echo "Targets for 'make':"
	@echo "    help                Print this information"
	@echo ""
	@echo "    Bluesim:"
	@echo "        compile         Compile for Bluesim"
	@echo "        link            Link a Bluesim executable"
	@echo "        simulate        Run the Bluesim simulation executable"
	@echo "                            (generates VCD file; remove -V flag to suppress VCD gen)"
	@echo "        all_bsim        Convenience for make compile link simulate"
	@echo ""
	@echo "    Verilog generation and Verilog sim:"
	@echo "        verilog         Compile for Verilog (Verilog files generated in verilog_dir/)"
	@echo "        v_link          Link a Verilog simulation executable"
	@echo "                            (current simulator:" $(VSIM) " (redefine VSIM for other Verilog simulators)"
	@echo "        v_simulate      Run the Verilog simulation executable"
	@echo "        all_vsim        Convenience for make verilog v_link v_simulate"
	@echo "                            (generates VCD file; remove +bscvcd flag to suppress VCD gen)"
	@echo ""
	@echo "    clean               Delete intermediate files in build_bsim/ and build_v/ dirs"
	@echo "    full_clean          Delete all but this Makefile"

# ----------------------------------------------------------------
# Bluesim compile/link/simulate

BSIM_DIRS = -simdir build_bsim -bdir build_bsim -info-dir build_bsim
BSIM_EXE = $(TOPMODULE)_bsim

.PHONY: all_bsim
all_bsim: full_clean  compile  link    simulate

build_bsim:
	mkdir  build_bsim


.PHONY: compile
compile: build_bsim
	@echo Compiling for Bluesim ...
	bsc -u -sim -steps 100000000000 +RTS -K140000M -RTS $(BSIM_DIRS) $(BSC_COMP_FLAGS) -g $(TOPMODULE)  $(TOPFILE) 
	@echo Compiling for Bluesim finished

.PHONY: link
link:
	@echo Linking for Bluesim ...
	bsc -e $(TOPMODULE) -sim -o $(BSIM_EXE) $(BSIM_DIRS) $(BSC_LINK_FLAGS) 
	@echo Linking for Bluesim finished

.PHONY: simulate
simulate:
	@echo Bluesim simulation ...
	./$(BSIM_EXE)  -V
	@echo Bluesim simulation finished

# ----------------------------------------------------------------
# Verilog compile/link/sim

V_DIRS = -vdir verilog_dir -bdir build_v -info-dir build_v
VSIM_EXE = $(TOPMODULE)_vsim

.PHONY: all_vsim
all_vsim: full_clean  verilog  v_link  v_simulate

build_v:
	mkdir  build_v
verilog_dir:
	mkdir  verilog_dir

.PHONY: verilog
verilog: build_v  verilog_dir
	@echo Compiling for Verilog ...
	bsc -u -verilog -steps 100000000000 +RTS -K140000M -RTS $(V_DIRS) $(BSC_COMP_FLAGS) $(BSC_PATHS) -g $(TOPMODULE)  $(TOPFILE)
	@echo Compiling for Verilog finished

.PHONY: v_link
v_link:  build_v  verilog_dir
	@echo Linking for Verilog sim ...
	bsc -e $(TOPMODULE) -verilog -o ./$(VSIM_EXE) $(V_DIRS) -vsim $(VSIM)  verilog_dir/$(TOPMODULE).v \
		$(DISTRO)/Example_Programs/Common/C_imports.c
	@echo Linking for Verilog sim finished

.PHONY: v_simulate
v_simulate:
	@echo Verilog simulation...
	./$(VSIM_EXE)  +bscvcd
	@echo Verilog simulation finished

# ----------------------------------------------------------------

.PHONY: clean
clean:
	rm -f  build_bsim/*  build_v/*    *~

.PHONY: full_clean
full_clean:
	rm -r -f  build_bsim  build_v  verilog_dir  *~
	rm -f  *$(TOPMODULE)*  *.vcd

.PHONY: testTopLevel
testTopLevel: 
	@rm -f *.out 
	@make verilog
	@bsc -e $(TOPMODULE) verilog_dir/$(TOPMODULE).v
	@./a.out
