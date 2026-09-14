module ControlUnit
  import Rv32iPackage::*;
(
  input  logic [6:0]     opcode,
  output control_bus_t    controlBus
);

  always_comb begin
    controlBus.registerWriteEnable       = 1'b0;
    controlBus.memoryReadEnable          = 1'b0;
    controlBus.memoryWriteEnable         = 1'b0;
    controlBus.arithmeticOperationSelect = ARITHMETIC_OPERATION_ADD_FOR_ADDRESS;
    controlBus.secondOperandSelect       = 1'b0;
    controlBus.branchEnable              = 1'b0;
    controlBus.jumpEnable                = 1'b0;
    controlBus.writebackSourceSelect     = WRITEBACK_SOURCE_ARITHMETIC_LOGIC_UNIT_RESULT;

    case (opcode)
      OPCODE_OP: begin
        controlBus.registerWriteEnable       = 1'b1;
        controlBus.arithmeticOperationSelect = ARITHMETIC_OPERATION_FROM_FUNCTION_FIELDS;
      end
      OPCODE_OP_IMM: begin
        controlBus.registerWriteEnable       = 1'b1;
        controlBus.secondOperandSelect       = 1'b1;
        controlBus.arithmeticOperationSelect = ARITHMETIC_OPERATION_FROM_FUNCTION_FIELDS;
      end
      OPCODE_LOAD: begin
        controlBus.registerWriteEnable   = 1'b1;
        controlBus.secondOperandSelect   = 1'b1;
        controlBus.memoryReadEnable      = 1'b1;
        controlBus.writebackSourceSelect = WRITEBACK_SOURCE_MEMORY_READ_DATA;
      end
      OPCODE_STORE: begin
        controlBus.secondOperandSelect = 1'b1;
        controlBus.memoryWriteEnable   = 1'b1;
      end
      OPCODE_BRANCH: begin
        controlBus.branchEnable = 1'b1;
      end
      OPCODE_JAL, OPCODE_JALR: begin
        controlBus.registerWriteEnable   = 1'b1;
        controlBus.secondOperandSelect   = 1'b1;
        controlBus.jumpEnable            = 1'b1;
        controlBus.writebackSourceSelect = WRITEBACK_SOURCE_PROGRAM_COUNTER_PLUS_FOUR;
      end
      OPCODE_LUI: begin
        controlBus.registerWriteEnable   = 1'b1;
        controlBus.writebackSourceSelect = WRITEBACK_SOURCE_IMMEDIATE_VALUE;
      end
      OPCODE_AUIPC: begin
        controlBus.registerWriteEnable   = 1'b1;
        controlBus.writebackSourceSelect = WRITEBACK_SOURCE_PROGRAM_COUNTER_PLUS_IMMEDIATE;
      end
      default: begin
        // MISC-MEM / SYSTEM: no architectural register or memory effect in this phase
      end
    endcase
  end

endmodule : ControlUnit
