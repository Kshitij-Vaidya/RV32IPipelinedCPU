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

  localparam logic [2:0] FUNCT3_BRANCH_EQUAL                 = 3'b000;
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

  typedef struct packed {
    logic       registerWriteEnable;
    logic       memoryReadEnable;
    logic       memoryWriteEnable;
    logic [1:0] arithmeticOperationSelect;
    logic       secondOperandSelect;
    logic       branchEnable;
    logic       jumpEnable;
    logic [1:0] writebackSourceSelect;
  } control_bus_t;

endpackage : Rv32iPackage
