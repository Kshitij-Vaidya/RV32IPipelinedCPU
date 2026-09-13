module Rv32iCoreTestbench;

  localparam int unsigned SimulationCycleCount = 20;

  logic        clock;
  logic        reset;
  logic [31:0] programCounterValue;
  logic [31:0] instructionWord;

  Rv32iCore dutInstance (
    .clock               (clock),
    .reset               (reset),
    .programCounterValue (programCounterValue),
    .instructionWord     (instructionWord)
  );

  initial clock = 1'b0;
  always #5 clock = ~clock;

  initial begin
    $readmemh("tests/asm/phase0_single_nop.hex", dutInstance.instructionMemory.memoryArray);
    reset = 1'b1;
    repeat (2) @(posedge clock);
    reset = 1'b0;
  end

  always @(posedge clock) begin
    if (!reset && programCounterValue[1:0] != 2'b00) begin
      $error("programCounterValue not 4-byte aligned: %0h", programCounterValue);
    end
  end

  initial begin
    $dumpfile("build/phase0_waveform.vcd");
    $dumpvars(0, Rv32iCoreTestbench);
    repeat (SimulationCycleCount) @(posedge clock);
    $finish;
  end

endmodule : Rv32iCoreTestbench
