module Rv32iCore
  import Rv32iPackage::*;
(
  input  logic        clock,
  input  logic        reset,
  output logic [31:0] programCounterValue,
  output logic [31:0] instructionWord
);

  logic [31:0] programCounterNextValue;
  logic [31:0] programCounterPlusFour;
  logic [31:0] programCounterPlusImmediate;

  logic [6:0] operationCodeField;
  logic [2:0] functionCodeThreeField;
  logic [6:0] functionCodeSevenField;
  logic [4:0] sourceRegisterOneAddress;
  logic [4:0] sourceRegisterTwoAddress;
  logic [4:0] destinationRegisterAddress;

  control_bus_t controlBus;
  logic [31:0]  immediateValue;
  logic [31:0]  sourceRegisterOneData;
  logic [31:0]  sourceRegisterTwoData;
  logic [3:0]   aluOperationCode;
  logic [31:0]  aluSecondOperand;
  logic [31:0]  arithmeticResult;
  logic         branchTakenFlag;
  logic [31:0]  memoryReadData;
  logic [31:0]  writebackData;
  logic         jumpToRegisterTarget;
  logic [31:0]  jumpTarget;
  logic         branchTaken;

  assign operationCodeField         = instructionWord[6:0];
  assign functionCodeThreeField     = instructionWord[14:12];
  assign functionCodeSevenField     = instructionWord[31:25];
  assign sourceRegisterOneAddress   = instructionWord[19:15];
  assign sourceRegisterTwoAddress   = instructionWord[24:20];
  assign destinationRegisterAddress = instructionWord[11:7];

  ProgramCounterRegister programCounterRegister (
    .clock                    (clock),
    .reset                    (reset),
    .programCounterNextValue  (programCounterNextValue),
    .programCounterValue      (programCounterValue)
  );

  InstructionMemory instructionMemory (
    .programCounterValue  (programCounterValue),
    .instructionWord      (instructionWord)
  );

  RegisterFile registerFile (
    .clock                      (clock),
    .reset                      (reset),
    .sourceRegisterOneAddress   (sourceRegisterOneAddress),
    .sourceRegisterTwoAddress   (sourceRegisterTwoAddress),
    .destinationRegisterAddress (destinationRegisterAddress),
    .destinationRegisterData    (writebackData),
    .registerWriteEnable        (controlBus.registerWriteEnable),
    .sourceRegisterOneData      (sourceRegisterOneData),
    .sourceRegisterTwoData      (sourceRegisterTwoData)
  );

  ImmediateGenerator immediateGenerator (
    .instructionWord (instructionWord),
    .immediateValue  (immediateValue)
  );

  ControlUnit controlUnit (
    .opcode     (operationCodeField),
    .controlBus (controlBus)
  );

  ArithmeticLogicUnitControl arithmeticLogicUnitControl (
    .arithmeticOperationSelect (controlBus.arithmeticOperationSelect),
    .functionCodeThree         (functionCodeThreeField),
    .functionCodeSeven         (functionCodeSevenField),
    .operationCode             (aluOperationCode)
  );

  assign aluSecondOperand = controlBus.secondOperandSelect ? immediateValue : sourceRegisterTwoData;

  ArithmeticLogicUnit arithmeticLogicUnit (
    .firstOperand     (sourceRegisterOneData),
    .secondOperand    (aluSecondOperand),
    .operationCode    (aluOperationCode),
    .branchFunct3     (functionCodeThreeField),
    .arithmeticResult (arithmeticResult),
    .branchTakenFlag  (branchTakenFlag)
  );

  DataMemory dataMemory (
    .clock             (clock),
    .memoryAddress     (arithmeticResult),
    .writeData         (sourceRegisterTwoData),
    .memoryReadEnable  (controlBus.memoryReadEnable),
    .memoryWriteEnable (controlBus.memoryWriteEnable),
    .functionCodeThree (functionCodeThreeField),
    .readData          (memoryReadData)
  );

  assign programCounterPlusFour      = programCounterValue + 32'd4;
  assign programCounterPlusImmediate = programCounterValue + immediateValue;
  assign jumpToRegisterTarget        = controlBus.jumpEnable && (operationCodeField == OPCODE_JALR);
  assign jumpTarget                  = jumpToRegisterTarget ? {arithmeticResult[31:1], 1'b0} : programCounterPlusImmediate;
  assign branchTaken                 = controlBus.branchEnable && branchTakenFlag;

  always_comb begin
    if (controlBus.jumpEnable) begin
      programCounterNextValue = jumpTarget;
    end else if (branchTaken) begin
      programCounterNextValue = programCounterPlusImmediate;
    end else begin
      programCounterNextValue = programCounterPlusFour;
    end
  end

  always_comb begin
    case (controlBus.writebackSourceSelect)
      WRITEBACK_SOURCE_MEMORY_READ_DATA:               writebackData = memoryReadData;
      WRITEBACK_SOURCE_PROGRAM_COUNTER_PLUS_FOUR:      writebackData = programCounterPlusFour;
      WRITEBACK_SOURCE_PROGRAM_COUNTER_PLUS_IMMEDIATE: writebackData = programCounterPlusImmediate;
      WRITEBACK_SOURCE_IMMEDIATE_VALUE:                writebackData = immediateValue;
      default:                                         writebackData = arithmeticResult;
    endcase
  end

endmodule : Rv32iCore
