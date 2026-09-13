module Rv32iCore (
  input  logic        clock,
  input  logic        reset,
  output logic [31:0] programCounterValue,
  output logic [31:0] instructionWord
);

  ProgramCounterRegister programCounterRegister (
    .clock               (clock),
    .reset               (reset),
    .programCounterValue (programCounterValue)
  );

  InstructionMemory instructionMemory (
    .programCounterValue (programCounterValue),
    .instructionWord      (instructionWord)
  );

endmodule : Rv32iCore
