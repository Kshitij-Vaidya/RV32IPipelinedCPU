IVERILOG = iverilog
VVP      = vvp
SURFER  = surfer

RTL_SOURCES = rtl/Rv32iPackage.sv \
              rtl/ProgramCounterRegister.sv \
              mem/InstructionMemory.sv \
              rtl/Rv32iCore.sv

TB_SOURCES = tb/Rv32iCoreTestbench.sv

SIM_BINARY = build/Rv32iCoreTestbench.vvp

.PHONY: sim wave clean

sim: $(SIM_BINARY)
	$(VVP) $(SIM_BINARY)

$(SIM_BINARY): $(RTL_SOURCES) $(TB_SOURCES)
	mkdir -p build
	$(IVERILOG) -g2012 -o $(SIM_BINARY) $(RTL_SOURCES) $(TB_SOURCES)

wave: sim
	$(SURFER) build/phase0_waveform.vcd

clean:
	rm -rf build
