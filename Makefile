#Makefile

TARGET ?= target

SRC_DIR = $(TARGET)/src
SIM_DIR = sim
TB_DIR = $(TARGET)/tb

BUILD_DIR = build/$(TARGET)
IFS_DIR = ifs

.PHONY: compile sim wave all clean

compile:
	mkdir -p $(BUILD_DIR)
	cd $(BUILD_DIR) && vivado -mode batch \
	-source ../../$(SIM_DIR)/compile.tcl -tclargs $(TARGET) \
	-log vivado.log

sim:
	cd $(BUILD_DIR) && xsim tb_$(TARGET) -tclbatch ../../$(SIM_DIR)/sim.tcl

wave:
	gtkwave $(BUILD_DIR)/*.vcd &

all: compile sim wave

run: compile sim
