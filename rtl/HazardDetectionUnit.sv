module HazardDetectionUnit
  import Rv32iPackage::*;
(
  input  logic [4:0] idStageSourceRegisterOneAddress,
  input  logic [4:0] idStageSourceRegisterTwoAddress,
  input  logic [4:0] exStageDestinationRegisterAddress,
  input  logic       exStageMemoryReadEnable,
  output logic       loadUseHazardDetected
);

  always_comb begin
    loadUseHazardDetected = exStageMemoryReadEnable &&
                             (exStageDestinationRegisterAddress != 5'd0) &&
                             ((exStageDestinationRegisterAddress == idStageSourceRegisterOneAddress) ||
                              (exStageDestinationRegisterAddress == idStageSourceRegisterTwoAddress));
  end

endmodule : HazardDetectionUnit
