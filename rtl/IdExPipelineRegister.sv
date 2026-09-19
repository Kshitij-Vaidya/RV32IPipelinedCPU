module IdExPipelineRegister
  import Rv32iPackage::*;
(
  input  logic          clock,
  input  logic          reset,
  input  logic          flushRegister,
  input  logic          stallRegister,
  input  idExRegister_t registerDataIn,
  output idExRegister_t registerDataOut
);

  always_ff @(posedge clock) begin
    if (reset) begin
      registerDataOut <= '0;
    end else if (flushRegister) begin
      registerDataOut <= '0;
    end else if (stallRegister) begin
      registerDataOut <= registerDataOut;
    end else begin
      registerDataOut <= registerDataIn;
    end
  end

endmodule : IdExPipelineRegister
