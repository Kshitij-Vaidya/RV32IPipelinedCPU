module ImmediateGenerator
  import Rv32iPackage::*;
(
  input  logic [31:0] instructionWord,
  output logic [31:0] immediateValue
);

  always_comb begin
    case (instructionWord[6:0])
      OPCODE_OP_IMM, OPCODE_LOAD, OPCODE_JALR: begin
        immediateValue = {{20{instructionWord[31]}}, instructionWord[31:20]};
      end
      OPCODE_STORE: begin
        immediateValue = {{20{instructionWord[31]}}, instructionWord[31:25], instructionWord[11:7]};
      end
      OPCODE_BRANCH: begin
        immediateValue = {{19{instructionWord[31]}}, instructionWord[31], instructionWord[7],
                           instructionWord[30:25], instructionWord[11:8], 1'b0};
      end
      OPCODE_LUI, OPCODE_AUIPC: begin
        immediateValue = {instructionWord[31:12], 12'b0};
      end
      OPCODE_JAL: begin
        immediateValue = {{11{instructionWord[31]}}, instructionWord[31], instructionWord[19:12],
                           instructionWord[20], instructionWord[30:21], 1'b0};
      end
      default: begin
        immediateValue = 32'd0;
      end
    endcase
  end

endmodule : ImmediateGenerator
