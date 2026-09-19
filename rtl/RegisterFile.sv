module RegisterFile (
  input  logic        clock,
  input  logic        reset,
  input  logic [4:0]  sourceRegisterOneAddress,
  input  logic [4:0]  sourceRegisterTwoAddress,
  input  logic [4:0]  destinationRegisterAddress,
  input  logic [31:0] destinationRegisterData,
  input  logic        registerWriteEnable,
  output logic [31:0] sourceRegisterOneData,
  output logic [31:0] sourceRegisterTwoData
);

  logic [31:0] registerArray [0:31];

  always_ff @(posedge clock) begin
    if (reset) begin
      for (int unsigned registerIndex = 0; registerIndex < 32; registerIndex++) begin
        registerArray[registerIndex] <= 32'd0;
      end
    end else if (registerWriteEnable && (destinationRegisterAddress != 5'd0)) begin
      registerArray[destinationRegisterAddress] <= destinationRegisterData;
    end
  end

  logic sourceRegisterOneWriteBypass;
  logic sourceRegisterTwoWriteBypass;

  always_comb begin
    sourceRegisterOneWriteBypass = registerWriteEnable && (destinationRegisterAddress != 5'd0) &&
                                    (destinationRegisterAddress == sourceRegisterOneAddress);
    sourceRegisterTwoWriteBypass = registerWriteEnable && (destinationRegisterAddress != 5'd0) &&
                                    (destinationRegisterAddress == sourceRegisterTwoAddress);

    if (sourceRegisterOneAddress == 5'd0) begin
      sourceRegisterOneData = 32'd0;
    end else if (sourceRegisterOneWriteBypass) begin
      sourceRegisterOneData = destinationRegisterData;
    end else begin
      sourceRegisterOneData = registerArray[sourceRegisterOneAddress];
    end

    if (sourceRegisterTwoAddress == 5'd0) begin
      sourceRegisterTwoData = 32'd0;
    end else if (sourceRegisterTwoWriteBypass) begin
      sourceRegisterTwoData = destinationRegisterData;
    end else begin
      sourceRegisterTwoData = registerArray[sourceRegisterTwoAddress];
    end
  end

endmodule : RegisterFile
