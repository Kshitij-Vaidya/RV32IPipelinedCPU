module ArithmeticLogicUnitControl
  import Rv32iPackage::*;
(
  input  logic [1:0] arithmeticOperationSelect,
  input  logic [2:0] functionCodeThree,
  input  logic [6:0] functionCodeSeven,
  output logic [3:0] operationCode
);

  always_comb begin
    case (arithmeticOperationSelect)
      ARITHMETIC_OPERATION_FROM_FUNCTION_FIELDS: begin
        case (functionCodeThree)
          FUNCT3_ADD_SUB: begin
            operationCode = (functionCodeSeven == FUNCT7_ALTERNATE) ? ALU_OPERATION_SUB : ALU_OPERATION_ADD;
          end
          FUNCT3_SHIFT_LEFT_LOGICAL:     operationCode = ALU_OPERATION_SLL;
          FUNCT3_SET_LESS_THAN:          operationCode = ALU_OPERATION_SLT;
          FUNCT3_SET_LESS_THAN_UNSIGNED: operationCode = ALU_OPERATION_SLTU;
          FUNCT3_XOR:                    operationCode = ALU_OPERATION_XOR;
          FUNCT3_SHIFT_RIGHT: begin
            operationCode = (functionCodeSeven == FUNCT7_ALTERNATE) ? ALU_OPERATION_SRA : ALU_OPERATION_SRL;
          end
          FUNCT3_OR:  operationCode = ALU_OPERATION_OR;
          FUNCT3_AND: operationCode = ALU_OPERATION_AND;
          default:    operationCode = ALU_OPERATION_ADD;
        endcase
      end
      default: begin // ARITHMETIC_OPERATION_ADD_FOR_ADDRESS
        operationCode = ALU_OPERATION_ADD;
      end
    endcase
  end

endmodule : ArithmeticLogicUnitControl
