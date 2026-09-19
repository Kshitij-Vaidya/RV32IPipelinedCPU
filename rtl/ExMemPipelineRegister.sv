module ExMemPipelineRegister
  import Rv32iPackage::*;
(
  input  logic           clock,
  input  logic           reset,
  input  logic           flushRegister,
  input  logic           stallRegister,
  input  exMemRegister_t registerDataIn,
  output exMemRegister_t registerDataOut
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

endmodule : ExMemPipelineRegister
