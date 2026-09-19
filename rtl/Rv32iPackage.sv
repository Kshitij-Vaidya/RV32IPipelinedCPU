package Rv32iPackage;

  parameter int unsigned XLEN = 32;
  parameter logic [31:0] RESET_VECTOR = 32'h0000_0000;

  localparam logic [6:0] OPCODE_LUI      = 7'b0110111;
  localparam logic [6:0] OPCODE_AUIPC    = 7'b0010111;
  localparam logic [6:0] OPCODE_JAL      = 7'b1101111;
  localparam logic [6:0] OPCODE_JALR     = 7'b1100111;
  localparam logic [6:0] OPCODE_BRANCH   = 7'b1100011;
  localparam logic [6:0] OPCODE_LOAD     = 7'b0000011;
  localparam logic [6:0] OPCODE_STORE    = 7'b0100011;
  localparam logic [6:0] OPCODE_OP_IMM   = 7'b0010011;
  localparam logic [6:0] OPCODE_OP       = 7'b0110011;
  localparam logic [6:0] OPCODE_MISC_MEM = 7'b0001111;
  localparam logic [6:0] OPCODE_SYSTEM   = 7'b1110011;

  localparam logic [2:0] FUNCT3_ADD_SUB                      = 3'b000;
  localparam logic [2:0] FUNCT3_SHIFT_LEFT_LOGICAL           = 3'b001;
  localparam logic [2:0] FUNCT3_SET_LESS_THAN                = 3'b010;
  localparam logic [2:0] FUNCT3_SET_LESS_THAN_UNSIGNED       = 3'b011;
  localparam logic [2:0] FUNCT3_XOR                          = 3'b100;
  localparam logic [2:0] FUNCT3_SHIFT_RIGHT                  = 3'b101;
  localparam logic [2:0] FUNCT3_OR                           = 3'b110;
  localparam logic [2:0] FUNCT3_AND                          = 3'b111;

  localparam logic [2:0] FUNCT3_BRANCH_EQUAL                  = 3'b000;
  localparam logic [2:0] FUNCT3_BRANCH_NOT_EQUAL              = 3'b001;
  localparam logic [2:0] FUNCT3_BRANCH_LESS_THAN              = 3'b100;
  localparam logic [2:0] FUNCT3_BRANCH_GREATER_EQUAL          = 3'b101;
  localparam logic [2:0] FUNCT3_BRANCH_LESS_THAN_UNSIGNED     = 3'b110;
  localparam logic [2:0] FUNCT3_BRANCH_GREATER_EQUAL_UNSIGNED = 3'b111;

  localparam logic [2:0] FUNCT3_LOAD_BYTE              = 3'b000;
  localparam logic [2:0] FUNCT3_LOAD_HALFWORD          = 3'b001;
  localparam logic [2:0] FUNCT3_LOAD_WORD              = 3'b010;
  localparam logic [2:0] FUNCT3_LOAD_BYTE_UNSIGNED     = 3'b100;
  localparam logic [2:0] FUNCT3_LOAD_HALFWORD_UNSIGNED = 3'b101;

  localparam logic [2:0] FUNCT3_STORE_BYTE     = 3'b000;
  localparam logic [2:0] FUNCT3_STORE_HALFWORD = 3'b001;
  localparam logic [2:0] FUNCT3_STORE_WORD     = 3'b010;

  localparam logic [6:0] FUNCT7_DEFAULT   = 7'b0000000;
  localparam logic [6:0] FUNCT7_ALTERNATE = 7'b0100000;

  // arithmeticOperationSelect: which category of arithmeticOperationCode ArithmeticLogicUnitControl derives
  localparam logic [1:0] ARITHMETIC_OPERATION_ADD_FOR_ADDRESS        = 2'b00;
  localparam logic [1:0] ARITHMETIC_OPERATION_FROM_FUNCTION_FIELDS   = 2'b01;

  // operationCode: the arithmetic logic unit's actual operation, expanded by ArithmeticLogicUnitControl
  localparam logic [3:0] ALU_OPERATION_ADD  = 4'b0000;
  localparam logic [3:0] ALU_OPERATION_SUB  = 4'b0001;
  localparam logic [3:0] ALU_OPERATION_SLL  = 4'b0010;
  localparam logic [3:0] ALU_OPERATION_SLT  = 4'b0011;
  localparam logic [3:0] ALU_OPERATION_SLTU = 4'b0100;
  localparam logic [3:0] ALU_OPERATION_XOR  = 4'b0101;
  localparam logic [3:0] ALU_OPERATION_SRL  = 4'b0110;
  localparam logic [3:0] ALU_OPERATION_SRA  = 4'b0111;
  localparam logic [3:0] ALU_OPERATION_OR   = 4'b1000;
  localparam logic [3:0] ALU_OPERATION_AND  = 4'b1001;

  // writebackSourceSelect: what value the write-back mux presents to RegisterFile.destinationRegisterData
  localparam logic [2:0] WRITEBACK_SOURCE_ARITHMETIC_LOGIC_UNIT_RESULT   = 3'b000;
  localparam logic [2:0] WRITEBACK_SOURCE_MEMORY_READ_DATA               = 3'b001;
  localparam logic [2:0] WRITEBACK_SOURCE_PROGRAM_COUNTER_PLUS_FOUR      = 3'b010;
  localparam logic [2:0] WRITEBACK_SOURCE_PROGRAM_COUNTER_PLUS_IMMEDIATE = 3'b011;
  localparam logic [2:0] WRITEBACK_SOURCE_IMMEDIATE_VALUE                = 3'b100;

  typedef struct packed {
    logic       registerWriteEnable;
    logic       memoryReadEnable;
    logic       memoryWriteEnable;
    logic [1:0] arithmeticOperationSelect;
    logic       secondOperandSelect;
    logic       branchEnable;
    logic       jumpEnable;
    logic [2:0] writebackSourceSelect;
  } control_bus_t;

  // forwardSourceSelect: which pipeline stage the ForwardingUnit steers into an ALU operand
  localparam logic [1:0] FORWARD_SOURCE_REGISTER_FILE             = 2'b00;
  localparam logic [1:0] FORWARD_SOURCE_EXECUTE_MEMORY_REGISTER   = 2'b01;
  localparam logic [1:0] FORWARD_SOURCE_MEMORY_WRITEBACK_REGISTER = 2'b10;

  typedef struct packed {
    logic [31:0] programCounterValue;
    logic [31:0] programCounterPlusFour;
    logic [31:0] instructionWord;
  } ifIdRegister_t;

  typedef struct packed {
    logic [31:0]   programCounterValue;
    logic [31:0]   programCounterPlusFour;
    logic [31:0]   sourceRegisterOneData;
    logic [31:0]   sourceRegisterTwoData;
    logic [31:0]   immediateValue;
    logic [4:0]    sourceRegisterOneAddress;
    logic [4:0]    sourceRegisterTwoAddress;
    logic [4:0]    destinationRegisterAddress;
    logic [6:0]    operationCodeField;
    logic [2:0]    functionCodeThreeField;
    logic [6:0]    functionCodeSevenField;
    control_bus_t  controlBus;
  } idExRegister_t;

  typedef struct packed {
    logic [31:0]   programCounterPlusFour;
    logic [31:0]   programCounterPlusImmediate;
    logic [31:0]   arithmeticResult;
    logic [31:0]   sourceRegisterTwoData;
    logic [4:0]    destinationRegisterAddress;
    logic [31:0]   immediateValue;
    logic [2:0]    functionCodeThreeField;
    control_bus_t  controlBus;
  } exMemRegister_t;

  typedef struct packed {
    logic [31:0]   programCounterPlusFour;
    logic [31:0]   programCounterPlusImmediate;
    logic [31:0]   memoryReadData;
    logic [31:0]   arithmeticResult;
    logic [31:0]   immediateValue;
    logic [4:0]    destinationRegisterAddress;
    control_bus_t  controlBus;
  } memWbRegister_t;

endpackage : Rv32iPackage
