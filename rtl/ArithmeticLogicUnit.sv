module ArithmeticLogicUnit
  import Rv32iPackage::*;
(
  input  logic [31:0] firstOperand,
  input  logic [31:0] secondOperand,
  input  logic [3:0]  operationCode,
  input  logic [2:0]  branchFunct3,
  output logic [31:0] arithmeticResult,
  output logic        branchTakenFlag
);

  always_comb begin
    case (operationCode)
      ALU_OPERATION_ADD:  arithmeticResult = firstOperand + secondOperand;
      ALU_OPERATION_SUB:  arithmeticResult = firstOperand - secondOperand;
      ALU_OPERATION_SLL:  arithmeticResult = firstOperand << secondOperand[4:0];
      ALU_OPERATION_SLT:  arithmeticResult = {31'd0, ($signed(firstOperand) < $signed(secondOperand))};
      ALU_OPERATION_SLTU: arithmeticResult = {31'd0, (firstOperand < secondOperand)};
      ALU_OPERATION_XOR:  arithmeticResult = firstOperand ^ secondOperand;
      ALU_OPERATION_SRL:  arithmeticResult = firstOperand >> secondOperand[4:0];
      ALU_OPERATION_SRA:  arithmeticResult = $signed(firstOperand) >>> secondOperand[4:0];
      ALU_OPERATION_OR:   arithmeticResult = firstOperand | secondOperand;
      ALU_OPERATION_AND:  arithmeticResult = firstOperand & secondOperand;
      default:            arithmeticResult = 32'd0;
    endcase
  end

  always_comb begin
    case (branchFunct3)
      FUNCT3_BRANCH_EQUAL:                  branchTakenFlag = (firstOperand == secondOperand);
      FUNCT3_BRANCH_NOT_EQUAL:              branchTakenFlag = (firstOperand != secondOperand);
      FUNCT3_BRANCH_LESS_THAN:              branchTakenFlag = ($signed(firstOperand) < $signed(secondOperand));
      FUNCT3_BRANCH_GREATER_EQUAL:          branchTakenFlag = ($signed(firstOperand) >= $signed(secondOperand));
      FUNCT3_BRANCH_LESS_THAN_UNSIGNED:     branchTakenFlag = (firstOperand < secondOperand);
      FUNCT3_BRANCH_GREATER_EQUAL_UNSIGNED: branchTakenFlag = (firstOperand >= secondOperand);
      default:                              branchTakenFlag = 1'b0;
    endcase
  end

endmodule : ArithmeticLogicUnit
