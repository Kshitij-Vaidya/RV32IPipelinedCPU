module Rv32iCoreTestbench;

  localparam int unsigned AluOpsCycleCount     = 30;
  localparam int unsigned LoadStoreCycleCount  = 30;
  localparam int unsigned BranchesCycleCount   = 90;
  localparam int unsigned JumpsUpperCycleCount = 20;
  localparam int unsigned HazardsCycleCount    = 50;

  logic clock;
  logic reset;

  Rv32iCore dutAluOps      (.clock(clock), .reset(reset), .programCounterValue(), .instructionWord());
  Rv32iCore dutLoadStore   (.clock(clock), .reset(reset), .programCounterValue(), .instructionWord());
  Rv32iCore dutBranches    (.clock(clock), .reset(reset), .programCounterValue(), .instructionWord());
  Rv32iCore dutJumpsUpper  (.clock(clock), .reset(reset), .programCounterValue(), .instructionWord());
  Rv32iCore dutHazards     (.clock(clock), .reset(reset), .programCounterValue(), .instructionWord());

  initial clock = 1'b0;
  always #5 clock = ~clock;

  initial begin
    $readmemh("tests/asm/phase1_alu_ops.hex",     dutAluOps.instructionMemory.memoryArray);
    $readmemh("tests/asm/phase1_load_store.hex",  dutLoadStore.instructionMemory.memoryArray);
    $readmemh("tests/asm/phase1_branches.hex",    dutBranches.instructionMemory.memoryArray);
    $readmemh("tests/asm/phase1_jumps_upper.hex", dutJumpsUpper.instructionMemory.memoryArray);
    $readmemh("tests/asm/phase2_hazards.hex",     dutHazards.instructionMemory.memoryArray);
    reset = 1'b1;
    repeat (2) @(posedge clock);
    reset = 1'b0;
  end

  always @(posedge clock) begin
    if (!reset) begin
      if (dutAluOps.programCounterValue[1:0] != 2'b00) begin
        $error("dutAluOps: programCounterValue not 4-byte aligned: %0h", dutAluOps.programCounterValue);
      end
      if (dutLoadStore.programCounterValue[1:0] != 2'b00) begin
        $error("dutLoadStore: programCounterValue not 4-byte aligned: %0h", dutLoadStore.programCounterValue);
      end
      if (dutBranches.programCounterValue[1:0] != 2'b00) begin
        $error("dutBranches: programCounterValue not 4-byte aligned: %0h", dutBranches.programCounterValue);
      end
      if (dutJumpsUpper.programCounterValue[1:0] != 2'b00) begin
        $error("dutJumpsUpper: programCounterValue not 4-byte aligned: %0h", dutJumpsUpper.programCounterValue);
      end
      if (dutHazards.programCounterValue[1:0] != 2'b00) begin
        $error("dutHazards: programCounterValue not 4-byte aligned: %0h", dutHazards.programCounterValue);
      end
    end
  end

  task automatic checkRegister(string testName, int unsigned registerIndex, logic [31:0] actualValue, logic [31:0] expectedValue);
    if (actualValue !== expectedValue) begin
      $error("%s: x%0d = %0h, expected %0h", testName, registerIndex, actualValue, expectedValue);
    end
  endtask

  initial begin
    $dumpfile("build/phase2_waveform.vcd");
    $dumpvars(0, Rv32iCoreTestbench);

    repeat (AluOpsCycleCount) @(posedge clock);
    checkRegister("aluOps",  3, dutAluOps.registerFile.registerArray[3],  32'd8);
    checkRegister("aluOps",  4, dutAluOps.registerFile.registerArray[4],  32'd2);
    checkRegister("aluOps",  5, dutAluOps.registerFile.registerArray[5],  32'd1);
    checkRegister("aluOps",  6, dutAluOps.registerFile.registerArray[6],  32'd7);
    checkRegister("aluOps",  7, dutAluOps.registerFile.registerArray[7],  32'd6);
    checkRegister("aluOps",  8, dutAluOps.registerFile.registerArray[8],  32'd1);
    checkRegister("aluOps",  9, dutAluOps.registerFile.registerArray[9],  32'd1);
    checkRegister("aluOps", 10, dutAluOps.registerFile.registerArray[10], 32'd40);
    checkRegister("aluOps", 11, dutAluOps.registerFile.registerArray[11], 32'd0);
    checkRegister("aluOps", 12, dutAluOps.registerFile.registerArray[12], 32'd0);
    checkRegister("aluOps", 13, dutAluOps.registerFile.registerArray[13], 32'd1);
    checkRegister("aluOps", 14, dutAluOps.registerFile.registerArray[14], 32'd1);
    checkRegister("aluOps", 15, dutAluOps.registerFile.registerArray[15], 32'd1);
    checkRegister("aluOps", 16, dutAluOps.registerFile.registerArray[16], 32'd13);
    checkRegister("aluOps", 17, dutAluOps.registerFile.registerArray[17], 32'd4);
    checkRegister("aluOps", 18, dutAluOps.registerFile.registerArray[18], 32'd20);
    checkRegister("aluOps", 19, dutAluOps.registerFile.registerArray[19], 32'd2);
    checkRegister("aluOps", 20, dutAluOps.registerFile.registerArray[20], 32'd2);

    repeat (LoadStoreCycleCount) @(posedge clock);
    checkRegister("loadStore",  4, dutLoadStore.registerFile.registerArray[4],  32'd122);
    checkRegister("loadStore",  5, dutLoadStore.registerFile.registerArray[5],  32'd122);
    checkRegister("loadStore",  6, dutLoadStore.registerFile.registerArray[6],  32'hFFFFFFFF);
    checkRegister("loadStore",  7, dutLoadStore.registerFile.registerArray[7],  32'd255);
    checkRegister("loadStore",  8, dutLoadStore.registerFile.registerArray[8],  32'hFFFFFFFF);
    checkRegister("loadStore",  9, dutLoadStore.registerFile.registerArray[9],  32'd65535);
    checkRegister("loadStore", 10, dutLoadStore.registerFile.registerArray[10], 32'hFFFFFFFF);
    checkRegister("loadStore", 11, dutLoadStore.registerFile.registerArray[11], 32'd122);
    checkRegister("loadStore", 13, dutLoadStore.registerFile.registerArray[13], 32'hFFFFFF00);
    checkRegister("loadStore", 14, dutLoadStore.registerFile.registerArray[14], 32'hFFFF0000);

    repeat (BranchesCycleCount) @(posedge clock);
    for (int unsigned markerIndex = 4; markerIndex <= 15; markerIndex++) begin
      checkRegister("branches", markerIndex, dutBranches.registerFile.registerArray[markerIndex], 32'd1);
    end

    repeat (JumpsUpperCycleCount) @(posedge clock);
    checkRegister("jumpsUpper", 1, dutJumpsUpper.registerFile.registerArray[1], 32'd4);
    checkRegister("jumpsUpper", 2, dutJumpsUpper.registerFile.registerArray[2], 32'd0);
    checkRegister("jumpsUpper", 3, dutJumpsUpper.registerFile.registerArray[3], 32'd1);
    checkRegister("jumpsUpper", 4, dutJumpsUpper.registerFile.registerArray[4], 32'h12345000);
    checkRegister("jumpsUpper", 5, dutJumpsUpper.registerFile.registerArray[5], 32'd16);
    checkRegister("jumpsUpper", 6, dutJumpsUpper.registerFile.registerArray[6], 32'd36);
    checkRegister("jumpsUpper", 7, dutJumpsUpper.registerFile.registerArray[7], 32'd32);
    checkRegister("jumpsUpper", 8, dutJumpsUpper.registerFile.registerArray[8], 32'd0);
    checkRegister("jumpsUpper", 9, dutJumpsUpper.registerFile.registerArray[9], 32'd1);

    repeat (HazardsCycleCount) @(posedge clock);
    checkRegister("hazards",  1, dutHazards.registerFile.registerArray[1],  32'd5);
    checkRegister("hazards",  2, dutHazards.registerFile.registerArray[2],  32'd10);
    checkRegister("hazards",  3, dutHazards.registerFile.registerArray[3],  32'd7);
    checkRegister("hazards",  4, dutHazards.registerFile.registerArray[4],  32'd0);
    checkRegister("hazards",  5, dutHazards.registerFile.registerArray[5],  32'd14);
    checkRegister("hazards",  6, dutHazards.registerFile.registerArray[6],  32'd9);
    checkRegister("hazards",  7, dutHazards.registerFile.registerArray[7],  32'd0);
    checkRegister("hazards",  8, dutHazards.registerFile.registerArray[8],  32'd0);
    checkRegister("hazards",  9, dutHazards.registerFile.registerArray[9],  32'd18);
    checkRegister("hazards", 10, dutHazards.registerFile.registerArray[10], 32'd36);
    checkRegister("hazards", 11, dutHazards.registerFile.registerArray[11], 32'd40);
    checkRegister("hazards", 12, dutHazards.registerFile.registerArray[12], 32'd4096);
    checkRegister("hazards", 13, dutHazards.registerFile.registerArray[13], 32'd4096);
    checkRegister("hazards", 14, dutHazards.registerFile.registerArray[14], 32'd100);
    checkRegister("hazards", 15, dutHazards.registerFile.registerArray[15], 32'd123);
    checkRegister("hazards", 16, dutHazards.registerFile.registerArray[16], 32'd123);
    checkRegister("hazards", 17, dutHazards.registerFile.registerArray[17], 32'd246);
    checkRegister("hazards", 18, dutHazards.registerFile.registerArray[18], 32'd1);
    checkRegister("hazards", 19, dutHazards.registerFile.registerArray[19], 32'd1);
    checkRegister("hazards", 20, dutHazards.registerFile.registerArray[20], 32'd55);
    checkRegister("hazards", 21, dutHazards.registerFile.registerArray[21], 32'd1);
    checkRegister("hazards", 22, dutHazards.registerFile.registerArray[22], 32'd2);
    checkRegister("hazards", 23, dutHazards.registerFile.registerArray[23], 32'd77);
    checkRegister("hazards", 24, dutHazards.registerFile.registerArray[24], 32'd88);

    $finish;
  end

endmodule : Rv32iCoreTestbench
