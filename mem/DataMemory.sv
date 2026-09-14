module DataMemory
  import Rv32iPackage::*;
#(
  parameter int unsigned MemoryByteCount = 1024
) (
  input  logic        clock,
  input  logic [31:0] memoryAddress,
  input  logic [31:0] writeData,
  input  logic        memoryReadEnable,
  input  logic        memoryWriteEnable,
  input  logic [2:0]  functionCodeThree,
  output logic [31:0] readData
);

  logic [7:0] memoryArray [0:MemoryByteCount-1];

  always_ff @(posedge clock) begin
    if (memoryWriteEnable) begin
      case (functionCodeThree)
        FUNCT3_STORE_BYTE: begin
          memoryArray[memoryAddress] <= writeData[7:0];
        end
        FUNCT3_STORE_HALFWORD: begin
          memoryArray[memoryAddress]     <= writeData[7:0];
          memoryArray[memoryAddress + 1] <= writeData[15:8];
        end
        default: begin // FUNCT3_STORE_WORD
          memoryArray[memoryAddress]     <= writeData[7:0];
          memoryArray[memoryAddress + 1] <= writeData[15:8];
          memoryArray[memoryAddress + 2] <= writeData[23:16];
          memoryArray[memoryAddress + 3] <= writeData[31:24];
        end
      endcase
    end
  end

  logic [7:0] byteZero;
  logic [7:0] byteOne;
  logic [7:0] byteTwo;
  logic [7:0] byteThree;

  always_comb begin
    byteZero  = memoryArray[memoryAddress];
    byteOne   = memoryArray[memoryAddress + 1];
    byteTwo   = memoryArray[memoryAddress + 2];
    byteThree = memoryArray[memoryAddress + 3];

    if (!memoryReadEnable) begin
      readData = 32'd0;
    end else begin
      case (functionCodeThree)
        FUNCT3_LOAD_BYTE:              readData = {{24{byteZero[7]}}, byteZero};
        FUNCT3_LOAD_HALFWORD:          readData = {{16{byteOne[7]}}, byteOne, byteZero};
        FUNCT3_LOAD_WORD:              readData = {byteThree, byteTwo, byteOne, byteZero};
        FUNCT3_LOAD_BYTE_UNSIGNED:     readData = {24'd0, byteZero};
        FUNCT3_LOAD_HALFWORD_UNSIGNED: readData = {16'd0, byteOne, byteZero};
        default:                       readData = 32'd0;
      endcase
    end
  end

endmodule : DataMemory
