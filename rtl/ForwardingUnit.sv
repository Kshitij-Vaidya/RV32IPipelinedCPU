module ForwardingUnit
  import Rv32iPackage::*;
(
  input  logic [4:0] exStageSourceRegisterOneAddress,
  input  logic [4:0] exStageSourceRegisterTwoAddress,
  input  logic [4:0] exMemStageDestinationRegisterAddress,
  input  logic       exMemStageRegisterWriteEnable,
  input  logic [4:0] memWbStageDestinationRegisterAddress,
  input  logic       memWbStageRegisterWriteEnable,
  output logic [1:0] forwardSelectOperandOne,
  output logic [1:0] forwardSelectOperandTwo
);

  always_comb begin
    if (exMemStageRegisterWriteEnable && (exMemStageDestinationRegisterAddress != 5'd0) &&
        (exMemStageDestinationRegisterAddress == exStageSourceRegisterOneAddress)) begin
      forwardSelectOperandOne = FORWARD_SOURCE_EXECUTE_MEMORY_REGISTER;
    end else if (memWbStageRegisterWriteEnable && (memWbStageDestinationRegisterAddress != 5'd0) &&
                 (memWbStageDestinationRegisterAddress == exStageSourceRegisterOneAddress)) begin
      forwardSelectOperandOne = FORWARD_SOURCE_MEMORY_WRITEBACK_REGISTER;
    end else begin
      forwardSelectOperandOne = FORWARD_SOURCE_REGISTER_FILE;
    end
  end

  always_comb begin
    if (exMemStageRegisterWriteEnable && (exMemStageDestinationRegisterAddress != 5'd0) &&
        (exMemStageDestinationRegisterAddress == exStageSourceRegisterTwoAddress)) begin
      forwardSelectOperandTwo = FORWARD_SOURCE_EXECUTE_MEMORY_REGISTER;
    end else if (memWbStageRegisterWriteEnable && (memWbStageDestinationRegisterAddress != 5'd0) &&
                 (memWbStageDestinationRegisterAddress == exStageSourceRegisterTwoAddress)) begin
      forwardSelectOperandTwo = FORWARD_SOURCE_MEMORY_WRITEBACK_REGISTER;
    end else begin
      forwardSelectOperandTwo = FORWARD_SOURCE_REGISTER_FILE;
    end
  end

endmodule : ForwardingUnit
