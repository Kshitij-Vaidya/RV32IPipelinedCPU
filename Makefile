IVERILOG = iverilog
VVP      = vvp
SURFER  = surfer
SV2V     = sv2v
YOSYS    = yosys

RTL_SOURCES = rtl/Rv32iPackage.sv \
              rtl/ProgramCounterRegister.sv \
              mem/InstructionMemory.sv \
              rtl/RegisterFile.sv \
              rtl/ImmediateGenerator.sv \
              rtl/ControlUnit.sv \
              rtl/ArithmeticLogicUnitControl.sv \
              rtl/ArithmeticLogicUnit.sv \
              mem/DataMemory.sv \
              rtl/IfIdPipelineRegister.sv \
              rtl/IdExPipelineRegister.sv \
              rtl/ExMemPipelineRegister.sv \
              rtl/MemWbPipelineRegister.sv \
              rtl/HazardDetectionUnit.sv \
              rtl/ForwardingUnit.sv \
              rtl/Rv32iCore.sv

TB_SOURCES = tb/Rv32iCoreTestbench.sv

SIM_BINARY = build/Rv32iCoreTestbench.vvp

SYN_DIR         = build/synth
SYN_VERILOG     = $(SYN_DIR)/Rv32iCore.v
SYN_NETLIST_JSON = $(SYN_DIR)/Rv32iCore.json

.PHONY: sim wave clean synth-verilog synth-view synth synth-analyze

sim: $(SIM_BINARY)
	$(VVP) $(SIM_BINARY)

$(SIM_BINARY): $(RTL_SOURCES) $(TB_SOURCES)
	mkdir -p build
	$(IVERILOG) -g2012 -o $(SIM_BINARY) $(RTL_SOURCES) $(TB_SOURCES)

wave: sim
	$(SURFER) build/phase2_waveform.vcd

synth-verilog: $(RTL_SOURCES)
	mkdir -p $(SYN_DIR)
	$(SV2V) $(RTL_SOURCES) -w $(SYN_VERILOG)

synth-view: synth-verilog
	mkdir -p $(SYN_DIR)/hierarchy
	$(YOSYS) syn/view_hierarchy.ys
	for dotFile in $(SYN_DIR)/hierarchy/*.dot; do dot -Tsvg "$$dotFile" -o "$${dotFile%.dot}.svg"; done
	open $(SYN_DIR)/hierarchy/Rv32iCore.svg

synth: synth-verilog
	$(YOSYS) syn/synth.ys

synth-analyze: synth
	python3 syn/analyze_netlist.py $(SYN_NETLIST_JSON)

clean:
	rm -rf build
