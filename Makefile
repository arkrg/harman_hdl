#Makefile

TARGET ?= uart
MODE ?= rtl
TB ?= tb_$(TARGET)

SIM_DIR = sim

BUILD_DIR = build/$(TARGET)_$(MODE)_$(TB)/
IFS_DIR = ifs 

.PHONY: run compile sim wave all clean
compile:
	mkdir -p $(BUILD_DIR)
	cd $(BUILD_DIR) && vivado -mode batch \
	-source ../../$(SIM_DIR)/compile.tcl \
	-tclargs $(TARGET) $(MODE) $(TB)\

sim:
	mkdir -p $(BUILD_DIR)
	cd $(BUILD_DIR) && xsim $(TB) -tclbatch ../../$(SIM_DIR)/sim.tcl 

wave:
	gtkwave $(BUILD_DIR)/*.vcd &

run: compile sim

all: compile sim wave

clean: 
	cd $(BUILD_DIR) && rm -rf  *jou *.log *.pb *.dir
