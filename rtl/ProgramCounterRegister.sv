module ProgramCounterRegister
  import Rv32iPackage::*;
(
  input  logic        clock,
  input  logic        reset,
  input  logic [31:0] programCounterNextValue,
  output logic [31:0] programCounterValue
);

  always_ff @(posedge clock) begin
    if (reset) begin
      programCounterValue <= RESET_VECTOR;
    end else begin
      programCounterValue <= programCounterNextValue;
    end
  end

endmodule : ProgramCounterRegister
