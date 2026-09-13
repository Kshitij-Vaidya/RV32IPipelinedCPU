module InstructionMemory #(
  parameter int unsigned MemoryWordCount = 256
) (
  input  logic [31:0] programCounterValue,
  output logic [31:0] instructionWord
);

  logic [31:0] memoryArray [0:MemoryWordCount-1];

  always_comb begin
    instructionWord = memoryArray[programCounterValue[31:2]];
  end

endmodule : InstructionMemory
