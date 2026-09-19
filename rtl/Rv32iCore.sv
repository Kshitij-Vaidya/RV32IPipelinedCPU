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

  ifIdRegister_t  ifIdRegisterIn;
  ifIdRegister_t  ifIdRegisterOut;
  idExRegister_t  idExRegisterIn;
  idExRegister_t  idExRegisterOut;
  exMemRegister_t exMemRegisterIn;
  exMemRegister_t exMemRegisterOut;
  memWbRegister_t memWbRegisterIn;
  memWbRegister_t memWbRegisterOut;

  logic        hazardStallRequest;
  logic        pipelineRedirectEnable;
  logic [31:0] pipelineRedirectTarget;

  logic [1:0] forwardSelectOperandOne;
  logic [1:0] forwardSelectOperandTwo;

  logic [6:0]    decodeOperationCodeField;
  logic [2:0]    decodeFunctionCodeThreeField;
  logic [6:0]    decodeFunctionCodeSevenField;
  logic [4:0]    decodeSourceRegisterOneAddress;
  logic [4:0]    decodeSourceRegisterTwoAddress;
  logic [4:0]    decodeDestinationRegisterAddress;
  logic [31:0]   decodeImmediateValue;
  logic [31:0]   decodeSourceRegisterOneData;
  logic [31:0]   decodeSourceRegisterTwoData;
  control_bus_t  decodeControlBus;

  logic [31:0] executeForwardedOperandOne;
  logic [31:0] executeForwardedOperandTwo;
  logic [31:0] executeAluSecondOperand;
  logic [3:0]  executeAluOperationCode;
  logic [31:0] executeArithmeticResult;
  logic        executeBranchTakenFlag;
  logic [31:0] executeProgramCounterPlusImmediate;
  logic        executeJumpToRegisterTarget;
  logic [31:0] executeJumpTarget;
  logic        executeBranchTaken;

  logic [31:0] memoryReadData;

  logic [31:0] writebackData;
  logic [31:0] exMemWritebackValue;

  ProgramCounterRegister programCounterRegister (
    .clock                   (clock),
    .reset                   (reset),
    .programCounterNextValue (programCounterNextValue),
    .programCounterValue     (programCounterValue)
  );

  InstructionMemory instructionMemory (
    .programCounterValue (programCounterValue),
    .instructionWord     (instructionWord)
  );

  assign programCounterPlusFour = programCounterValue + 32'd4;

  always_comb begin
    if (pipelineRedirectEnable) begin
      programCounterNextValue = pipelineRedirectTarget;
    end else if (hazardStallRequest) begin
      programCounterNextValue = programCounterValue;
    end else begin
      programCounterNextValue = programCounterPlusFour;
    end
  end

  assign ifIdRegisterIn.programCounterValue    = programCounterValue;
  assign ifIdRegisterIn.programCounterPlusFour = programCounterPlusFour;
  assign ifIdRegisterIn.instructionWord        = instructionWord;

  IfIdPipelineRegister ifIdPipelineRegister (
    .clock           (clock),
    .reset           (reset),
    .flushRegister   (pipelineRedirectEnable),
    .stallRegister   (hazardStallRequest),
    .registerDataIn  (ifIdRegisterIn),
    .registerDataOut (ifIdRegisterOut)
  );

  assign decodeOperationCodeField         = ifIdRegisterOut.instructionWord[6:0];
  assign decodeFunctionCodeThreeField     = ifIdRegisterOut.instructionWord[14:12];
  assign decodeFunctionCodeSevenField     = ifIdRegisterOut.instructionWord[31:25];
  assign decodeSourceRegisterOneAddress   = ifIdRegisterOut.instructionWord[19:15];
  assign decodeSourceRegisterTwoAddress   = ifIdRegisterOut.instructionWord[24:20];
  assign decodeDestinationRegisterAddress = ifIdRegisterOut.instructionWord[11:7];

  RegisterFile registerFile (
    .clock                      (clock),
    .reset                      (reset),
    .sourceRegisterOneAddress   (decodeSourceRegisterOneAddress),
    .sourceRegisterTwoAddress   (decodeSourceRegisterTwoAddress),
    .destinationRegisterAddress (memWbRegisterOut.destinationRegisterAddress),
    .destinationRegisterData    (writebackData),
    .registerWriteEnable        (memWbRegisterOut.controlBus.registerWriteEnable),
    .sourceRegisterOneData      (decodeSourceRegisterOneData),
    .sourceRegisterTwoData      (decodeSourceRegisterTwoData)
  );

  ImmediateGenerator immediateGenerator (
    .instructionWord (ifIdRegisterOut.instructionWord),
    .immediateValue  (decodeImmediateValue)
  );

  ControlUnit controlUnit (
    .opcode     (decodeOperationCodeField),
    .controlBus (decodeControlBus)
  );

  HazardDetectionUnit hazardDetectionUnit (
    .idStageSourceRegisterOneAddress   (decodeSourceRegisterOneAddress),
    .idStageSourceRegisterTwoAddress   (decodeSourceRegisterTwoAddress),
    .exStageDestinationRegisterAddress (idExRegisterOut.destinationRegisterAddress),
    .exStageMemoryReadEnable           (idExRegisterOut.controlBus.memoryReadEnable),
    .loadUseHazardDetected             (hazardStallRequest)
  );

  assign idExRegisterIn.programCounterValue        = ifIdRegisterOut.programCounterValue;
  assign idExRegisterIn.programCounterPlusFour     = ifIdRegisterOut.programCounterPlusFour;
  assign idExRegisterIn.sourceRegisterOneData      = decodeSourceRegisterOneData;
  assign idExRegisterIn.sourceRegisterTwoData      = decodeSourceRegisterTwoData;
  assign idExRegisterIn.immediateValue             = decodeImmediateValue;
  assign idExRegisterIn.sourceRegisterOneAddress   = decodeSourceRegisterOneAddress;
  assign idExRegisterIn.sourceRegisterTwoAddress   = decodeSourceRegisterTwoAddress;
  assign idExRegisterIn.destinationRegisterAddress = decodeDestinationRegisterAddress;
  assign idExRegisterIn.operationCodeField         = decodeOperationCodeField;
  assign idExRegisterIn.functionCodeThreeField     = decodeFunctionCodeThreeField;
  assign idExRegisterIn.functionCodeSevenField     = decodeFunctionCodeSevenField;
  assign idExRegisterIn.controlBus                 = decodeControlBus;

  IdExPipelineRegister idExPipelineRegister (
    .clock           (clock),
    .reset           (reset),
    .flushRegister   (pipelineRedirectEnable || hazardStallRequest),
    .stallRegister   (1'b0),
    .registerDataIn  (idExRegisterIn),
    .registerDataOut (idExRegisterOut)
  );

  ForwardingUnit forwardingUnit (
    .exStageSourceRegisterOneAddress      (idExRegisterOut.sourceRegisterOneAddress),
    .exStageSourceRegisterTwoAddress      (idExRegisterOut.sourceRegisterTwoAddress),
    .exMemStageDestinationRegisterAddress (exMemRegisterOut.destinationRegisterAddress),
    .exMemStageRegisterWriteEnable        (exMemRegisterOut.controlBus.registerWriteEnable),
    .memWbStageDestinationRegisterAddress (memWbRegisterOut.destinationRegisterAddress),
    .memWbStageRegisterWriteEnable        (memWbRegisterOut.controlBus.registerWriteEnable),
    .forwardSelectOperandOne              (forwardSelectOperandOne),
    .forwardSelectOperandTwo              (forwardSelectOperandTwo)
  );

  always_comb begin
    case (exMemRegisterOut.controlBus.writebackSourceSelect)
      WRITEBACK_SOURCE_PROGRAM_COUNTER_PLUS_FOUR:      exMemWritebackValue = exMemRegisterOut.programCounterPlusFour;
      WRITEBACK_SOURCE_PROGRAM_COUNTER_PLUS_IMMEDIATE: exMemWritebackValue = exMemRegisterOut.programCounterPlusImmediate;
      WRITEBACK_SOURCE_IMMEDIATE_VALUE:                exMemWritebackValue = exMemRegisterOut.immediateValue;
      default:                                         exMemWritebackValue = exMemRegisterOut.arithmeticResult;
    endcase
  end

  always_comb begin
    case (forwardSelectOperandOne)
      FORWARD_SOURCE_EXECUTE_MEMORY_REGISTER:   executeForwardedOperandOne = exMemWritebackValue;
      FORWARD_SOURCE_MEMORY_WRITEBACK_REGISTER: executeForwardedOperandOne = writebackData;
      default:                                  executeForwardedOperandOne = idExRegisterOut.sourceRegisterOneData;
    endcase
  end

  always_comb begin
    case (forwardSelectOperandTwo)
      FORWARD_SOURCE_EXECUTE_MEMORY_REGISTER:   executeForwardedOperandTwo = exMemWritebackValue;
      FORWARD_SOURCE_MEMORY_WRITEBACK_REGISTER: executeForwardedOperandTwo = writebackData;
      default:                                  executeForwardedOperandTwo = idExRegisterOut.sourceRegisterTwoData;
    endcase
  end

  assign executeAluSecondOperand = idExRegisterOut.controlBus.secondOperandSelect ? idExRegisterOut.immediateValue : executeForwardedOperandTwo;

  ArithmeticLogicUnitControl arithmeticLogicUnitControl (
    .arithmeticOperationSelect (idExRegisterOut.controlBus.arithmeticOperationSelect),
    .functionCodeThree         (idExRegisterOut.functionCodeThreeField),
    .functionCodeSeven         (idExRegisterOut.functionCodeSevenField),
    .operationCode             (executeAluOperationCode)
  );

  ArithmeticLogicUnit arithmeticLogicUnit (
    .firstOperand     (executeForwardedOperandOne),
    .secondOperand    (executeAluSecondOperand),
    .operationCode    (executeAluOperationCode),
    .branchFunct3     (idExRegisterOut.functionCodeThreeField),
    .arithmeticResult (executeArithmeticResult),
    .branchTakenFlag  (executeBranchTakenFlag)
  );

  assign executeProgramCounterPlusImmediate = idExRegisterOut.programCounterValue + idExRegisterOut.immediateValue;
  assign executeJumpToRegisterTarget        = idExRegisterOut.controlBus.jumpEnable && (idExRegisterOut.operationCodeField == OPCODE_JALR);
  assign executeJumpTarget                  = executeJumpToRegisterTarget ? {executeArithmeticResult[31:1], 1'b0} : executeProgramCounterPlusImmediate;
  assign executeBranchTaken                 = idExRegisterOut.controlBus.branchEnable && executeBranchTakenFlag;
  assign pipelineRedirectEnable             = idExRegisterOut.controlBus.jumpEnable || executeBranchTaken;
  assign pipelineRedirectTarget             = executeJumpTarget;

  assign exMemRegisterIn.programCounterPlusFour      = idExRegisterOut.programCounterPlusFour;
  assign exMemRegisterIn.programCounterPlusImmediate = executeProgramCounterPlusImmediate;
  assign exMemRegisterIn.arithmeticResult            = executeArithmeticResult;
  assign exMemRegisterIn.sourceRegisterTwoData       = executeForwardedOperandTwo;
  assign exMemRegisterIn.destinationRegisterAddress  = idExRegisterOut.destinationRegisterAddress;
  assign exMemRegisterIn.immediateValue              = idExRegisterOut.immediateValue;
  assign exMemRegisterIn.functionCodeThreeField      = idExRegisterOut.functionCodeThreeField;
  assign exMemRegisterIn.controlBus                  = idExRegisterOut.controlBus;

  ExMemPipelineRegister exMemPipelineRegister (
    .clock           (clock),
    .reset           (reset),
    .flushRegister   (1'b0),
    .stallRegister   (1'b0),
    .registerDataIn  (exMemRegisterIn),
    .registerDataOut (exMemRegisterOut)
  );

  DataMemory dataMemory (
    .clock             (clock),
    .memoryAddress     (exMemRegisterOut.arithmeticResult),
    .writeData         (exMemRegisterOut.sourceRegisterTwoData),
    .memoryReadEnable  (exMemRegisterOut.controlBus.memoryReadEnable),
    .memoryWriteEnable (exMemRegisterOut.controlBus.memoryWriteEnable),
    .functionCodeThree (exMemRegisterOut.functionCodeThreeField),
    .readData          (memoryReadData)
  );

  assign memWbRegisterIn.programCounterPlusFour      = exMemRegisterOut.programCounterPlusFour;
  assign memWbRegisterIn.programCounterPlusImmediate = exMemRegisterOut.programCounterPlusImmediate;
  assign memWbRegisterIn.memoryReadData              = memoryReadData;
  assign memWbRegisterIn.arithmeticResult            = exMemRegisterOut.arithmeticResult;
  assign memWbRegisterIn.immediateValue              = exMemRegisterOut.immediateValue;
  assign memWbRegisterIn.destinationRegisterAddress  = exMemRegisterOut.destinationRegisterAddress;
  assign memWbRegisterIn.controlBus                  = exMemRegisterOut.controlBus;

  MemWbPipelineRegister memWbPipelineRegister (
    .clock           (clock),
    .reset           (reset),
    .flushRegister   (1'b0),
    .stallRegister   (1'b0),
    .registerDataIn  (memWbRegisterIn),
    .registerDataOut (memWbRegisterOut)
  );

  always_comb begin
    case (memWbRegisterOut.controlBus.writebackSourceSelect)
      WRITEBACK_SOURCE_MEMORY_READ_DATA:               writebackData = memWbRegisterOut.memoryReadData;
      WRITEBACK_SOURCE_PROGRAM_COUNTER_PLUS_FOUR:      writebackData = memWbRegisterOut.programCounterPlusFour;
      WRITEBACK_SOURCE_PROGRAM_COUNTER_PLUS_IMMEDIATE: writebackData = memWbRegisterOut.programCounterPlusImmediate;
      WRITEBACK_SOURCE_IMMEDIATE_VALUE:                writebackData = memWbRegisterOut.immediateValue;
      default:                                         writebackData = memWbRegisterOut.arithmeticResult;
    endcase
  end

endmodule : Rv32iCore
