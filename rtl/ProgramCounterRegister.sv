module ProgramCounterRegister
  import Rv32iPackage::*;
(
  input  logic        clock,
  input  logic        reset,
  output logic [31:0] programCounterValue
);

  always_ff @(posedge clock) begin
    if (reset) begin
      programCounterValue <= RESET_VECTOR;
    end else begin
      programCounterValue <= programCounterValue + 32'd4;
    end
  end

endmodule : ProgramCounterRegister
