// ======================================================================
// Title      : FPU Double Testbench
// Description: SystemVerilog version converted from fpu_double_tb.vhd
// Author     : Auto-converted by ChatGPT (GPT-5)
// Notes      :
//   - UPF supplies represented by supply1/supply0
//   - Original comments preserved
//   - Timing, processes, and signal flow equivalent to VHDL version
// ======================================================================

`timescale 1ns/1ps

module fpu_double_tb;

  // ================================================================
  // Power supplies (UPF replacement)
  // ================================================================
  // supply1 VDD;
  // supply0 VSS;

  // ================================================================
  // DUT Interface Signals
  // ================================================================
  logic         clk;
  logic         rst_n;

  logic         enable;
  logic         ready;
  logic   [1:0] rmode;
  logic   [2:0] fpu_op;
  logic  [15:0] opa_i;
  logic  [15:0] opb_i;
  logic  [15:0] out_fp_o;
  logic  [63:0] opa_h;
  logic  [63:0] opb_h;
  logic  [63:0] out_fp_h;
  
  logic underflow ;
  logic overflow ;
  logic inexact ;
  logic exception ;
  logic invalid ;
  
  // ================================================================
  // Task Load Result
  // ================================================================
  // This task should be defined within a SystemVerilog testbench or program block.
  // The `clk`, `ready`, and `out_fp_o` signals would need to be defined outside this task,
  // and the `result` signal should be passed as a reference.
  task automatic load_result(
    ref logic clk,
    ref logic ready,
    ref logic [15:0] out_fp_o,
    ref logic [63:0] result
  );
    // $display("%t Entrou no LOAD RESULT.",$realtime);
    @(posedge ready);
    @(posedge clk);
    @(posedge clk);

    result[63:48] = out_fp_o;
    @(posedge clk);
  
    result[47:32] = out_fp_o;
    @(posedge clk);

    result[31:16] = out_fp_o;
    @(posedge clk);

    result[15:0] = out_fp_o;
    @(posedge clk);
  endtask : load_result
  
  // ================================================================
  // Task Load Values
  // ================================================================
  // This task provides stimulus to the instantiated FPU module "fpu_i".
  task automatic Operation(
    ref  logic clk,
    // input  logic rst_n,
    // input  logic [1:0] rmode,
    // input  logic [2:0] fpu_op,
    input  logic [63:0] A,
    input  logic [63:0] B,
    ref logic [15:0] opa_i,
    ref logic [15:0] opb_i,
    ref logic start
    // input  logic ready,
    // input  logic [15:0] out_fp_o,
    //output logic [63:0] out_fp
  );
    // Local signals within the testbench that will be connected to the FPU instance.
    // logic [15:0] out_fp_o;
    // $display("%t %m Entrou no OPERATION.",$realtime);
    // Corresponding to the original VHDL procedure logic.
    start = 1'b0; // Ensure FPU is disabled before starting
    
    @(posedge clk) begin end;
    // $display("%t %m OPERATION - CLK1",$realtime);
    opa_i = A[15:0];
    opb_i = B[15:0];
    start = 1'b1;

    @(posedge clk) begin end;
    // $display("%t %m OPERATION - CLK2",$realtime);
    opa_i = A[31:16];
    opb_i = B[31:16];
    start = 1'b0;

    @(posedge clk) begin end;
    // $display("%t %m OPERATION - CLK3",$realtime);
    opa_i = A[47:32];
    opb_i = B[47:32];

    @(posedge clk) begin end;
    // $display("%t %m OPERATION - CLK4",$realtime);
    opa_i = A[63:48];
    opb_i = B[63:48];
    
    // The `load_result` task now needs to wait for the FPU's `ready_o` signal.
    // Pass the FPU's output (`out_fp_o`) and the `ready_o` signal to the task.
    // load_result(clk, ready, out_fp_o, out_fp);

    @(posedge clk);
  endtask : Operation
  

  // ================================================================
  // Clock Generation
  // ================================================================
  initial begin :clk_gen
    clk = 0;
    forever #5 clk = ~clk; // 100 MHz clock
  end

  // ================================================================
  // Reset Generation
  // ================================================================
  initial begin :rst_gen
    rst_n = 1'b0;
    #20;
    rst_n = 1'b1;
  end

  initial
  begin: timing_format
    $timeformat(-9, 0, "ns", 9);
  end: timing_format
  // ================================================================
  // DUT Instantiation
  // ================================================================
  fpu_double fpu_i (
    .clk      (clk),
    .rst_n    (rst_n),
    .enable_i (enable),
    .rmode_i  (rmode),
    .fpu_op_i (fpu_op),
    .opa_i    (opa_i),
    .opb_i    (opb_i),
    .out_fp_o (out_fp_o),
    .ready_o  (ready),
    .underflow  (underflow),
    .overflow (overflow),
    .inexact  (inexact),
    .exception  (exception),
    .invalid  (invalid)
  );

  // ================================================================
  // Power-up / Power-down Sequence
  // ================================================================
  // In VHDL: supply_on("VDD", 0.8), supply_off("VSS"), etc.
  // Here: emulate delays and print power events
  `ifdef UPF
  initial begin : PSU_inicialization
    reg status;
    $display("Powering up...");
    status=UPF::supply_on("fpu_i.VSS", 0.0);
    status=UPF::supply_off("fpu_i.VDD");
    #10;
    status=UPF::supply_on("fpu_i.VDD", 0.8);
    $display("VDD = 0.8, VSS = 0");
  end
  `endif //UPF

  // ================================================================
  // Stimulus Process
  // ================================================================
  // High-level signals for the Operation task
  
  initial begin : stim_proc
    integer i;
    i=0;
    opa_i   = 16'd0;
    opb_i   = 16'd0;
    enable  = 1'b0;
    fpu_op  = 3'd0;
    rmode   = 2'b00;

    wait(rst_n);
    $display("Starting simulation...");
    
    //inputA:4.0000000000e+000
    //inputB:-4.0000000000e+000
    //Output:0.000000000000000e+000
    
    opa_h  = 64'b0100000000010000000000000000000000000000000000000000000000000000;
    opb_h  = 64'b1100000000010000000000000000000000000000000000000000000000000000;
    fpu_op = 3'b000;
    rmode = 2'b10;
    Operation(clk, opa_h, opb_h, opa_i, opb_i, enable);
    load_result(clk, ready, out_fp_o, out_fp_h);
    assert (out_fp_h == 64'h0000000000000000) $display("%t OK", $realtime);
      else $display("%t Desired: 0000000000000000", $realtime);
//----------------------------------------------------------------------------
    //inputA:3.0000000000e-312
    //inputB:1.0000000000e-025
    //Output:3.000000000000337e-287
    opa_h = 64'b0000000000000000000000001000110101100000010101111101110111110010;
    opb_h = 64'b0011101010111110111100101101000011110101110110100111110111011001;
    fpu_op = 3'b011;
    rmode = 2'b10;
    Operation(clk, opa_h, opb_h, opa_i, opb_i, enable);
    load_result(clk, ready, out_fp_o, out_fp_h);
    assert (out_fp_h == 64'h047245C02F8B68C5) $display("%t OK", $realtime);
      else $display("%t Desired: 047245C02F8B68C5", $realtime);
//------------------------------------------------------------------------------
    //inputA:4.0000000000e-304
    //inputB:2.0000000000e-007
    //Output:8.000000000000074e-311
    opa_h  = 64'b0000000011110001100011100011101110011011001101110100000101101001;
    opb_h  = 64'b0011111010001010110101111111001010011010101111001010111101001000;
    fpu_op = 3'b010;
    rmode = 2'b00;
    Operation(clk, opa_h, opb_h, opa_i, opb_i, enable);
    load_result(clk, ready, out_fp_o, out_fp_h);
    assert (out_fp_h == 64'h00000EBA09271E89) $display("%t OK", $realtime);
      else $display("%t Desired: 00000EBA09271E89", $realtime);
//------------------------------------------------------------------------------
    //inputA:3.4445600000e+002
    //inputB:3.4445599000e+002
    opa_h  = 64'b0100000001110101100001110100101111000110101001111110111110011110;
    opb_h  = 64'b0100000001110101100001110100101110111100001010111001010011011001;
    fpu_op = 3'b001;
    rmode = 2'b00;
    Operation(clk, opa_h, opb_h, opa_i, opb_i, enable);
    load_result(clk, ready, out_fp_o, out_fp_h);

    //Output:1.000000003159585e-005
    assert (out_fp_h == 64'h3EE4F8B58A000000) $display("%t OK", $realtime);
      else $display("%t Desired: 3EE4F8B58A000000", $realtime);
//------------------------------------------------------------------------------
    //inputA:-8.8899000000e+002
    //inputB:7.8898020000e+002
    opa_h  = 64'b1100000010001011110001111110101110000101000111101011100001010010;
    opb_h  = 64'b0100000010001000101001111101011101110011000110001111110001010000;
    fpu_op = 3'b000;
    rmode = 2'b11;
    Operation(clk, opa_h, opb_h, opa_i, opb_i, enable);
    load_result(clk, ready, out_fp_o, out_fp_h);

    //Output:-1.000098000000000e+002
    assert (out_fp_h == 64'hC05900A0902DE010) $display("%t OK", $realtime);
      else $display("%t Desired: C05900A0902DE010", $realtime);
//------------------------------------------------------------------------------
    //inputA:4.5600000000e+002
    //inputB:2.3700000000e+001

    opa_h  = 64'b0100000001111100100000000000000000000000000000000000000000000000;
    opb_h  = 64'b0100000000110111101100110011001100110011001100110011001100110011;
    fpu_op = 3'b011;
    rmode = 2'b00;
    Operation(clk, opa_h, opb_h, opa_i, opb_i, enable);
    load_result(clk, ready, out_fp_o, out_fp_h);

    //Output:1.924050632911392e+001
    assert (out_fp_h == 64'h40333D91D2A2067B) $display("%t OK", $realtime);
      else $display("%t Desired: 40333D91D2A2067B", $realtime);
//------------------------------------------------------------------------------
    //inputA:4.9990000000e+003
    //inputB:0.0000000000e+000
    opa_h  = 64'b0100000010110011100001110000000000000000000000000000000000000000;
    opb_h  = 64'b0000000000000000000000000000000000000000000000000000000000000000;
    fpu_op = 3'b010;
    rmode = 2'b10;
    Operation(clk, opa_h, opb_h, opa_i, opb_i, enable);
    load_result(clk, ready, out_fp_o, out_fp_h);

    //Output:0.000000000000000e+000
    assert (out_fp_h == 64'h0000000000000000) $display("%t OK", $realtime);
      else $display("%t Desired: 0000000000000000", $realtime);
//------------------------------------------------------------------------------
    //inputA:-9.8883300000e+005
    //inputB:4.4444440000e+006
    opa_h  = 64'b1100000100101110001011010100001000000000000000000000000000000000;
    opa_h  = 64'hC12E2D42_00000000;
    opb_h  = 64'b0100000101010000111101000100011100000000000000000000000000000000;
    opb_h  = 64'h4150F447_00000000;
    fpu_op = 3'b001;
    rmode = 2'b10;
    Operation(clk, opa_h, opb_h, opa_i, opb_i, enable);
    load_result(clk, ready, out_fp_o, out_fp_h);

    //Output:-5.433277000000000e+006
    assert (out_fp_h == 64'hC154B9EF40000000) $display("%t OK", $realtime);
      else $display("%t Desired: C154B9EF40000000", $realtime);
//------------------------------------------------------------------------------
    //inputA:-4.8000000000e-311
    //inputB:4.0000000000e-050
    opa_h  = 64'b1000000000000000000010001101011000000101011111011101111100011111;
    opb_h  = 64'b0011010110101101111011100111101001001010110101001011100000011111;
    fpu_op = 3'b011;
    rmode = 2'b00;
    Operation(clk, opa_h, opb_h, opa_i, opb_i, enable);
    load_result(clk, ready, out_fp_o, out_fp_h);

    //Output:-1.200000000000011e-261
    assert (out_fp_h == 64'h89C2E4AE4EAE705E) $display("%t OK", $realtime);
      else $display("%t Desired: 89C2E4AE4EAE705E", $realtime);
//------------------------------------------------------------------------------
    //inputA:1.9500000000e-308
    //inputB:1.8800000000e-308
    opa_h  = 64'b0000000000001110000001011010001000110110111111110101001011001101;
    opb_h  = 64'b0000000000001101100001001100011001100110111010010000011110011111;
    fpu_op = 3'b000;
    rmode = 2'b10;
    Operation(clk, opa_h, opb_h, opa_i, opb_i, enable);
    load_result(clk, ready, out_fp_o, out_fp_h);

    //Output:3.830000000000000e-308
    assert (out_fp_h == 64'h001B8A689DE85A6C) $display("%t OK", $realtime);
      else $display("%t Desired: 001B8A689DE85A6C", $realtime);
//------------------------------------------------------------------------------
    //inputA:-3.0000000000e-309
    //inputB:9.0000000000e+100
    opa_h  = 64'b1000000000000010001010000100000001010111001110101111100100001100;
    opb_h  = 64'b0101010011100100100100101110001011001010010001110101101111101101;
    fpu_op = 3'b010;
    rmode = 2'b11;
    Operation(clk, opa_h, opb_h, opa_i, opb_i, enable);
    load_result(clk, ready, out_fp_o, out_fp_h);

    //Output:-2.700000000000001e-208
    assert (out_fp_h == 64'h94D630F25FC26702) $display("%t OK", $realtime);
      else $display("%t Desired: 94D630F25FC26702", $realtime);
//------------------------------------------------------------------------------
    //inputA:3.0000000000e-308
    //inputB:2.9900000000e-308
    opa_h  = 64'b0000000000010101100100101000001101101000010011011011101001110111;
    opb_h  = 64'b0000000000010101100000000001101011011100110111001101010001001011;
    fpu_op = 3'b001;
    rmode = 2'b10;
    Operation(clk, opa_h, opb_h, opa_i, opb_i, enable);
    load_result(clk, ready, out_fp_o, out_fp_h);

    //Output:1.000000000000046e-310
    assert (out_fp_h == 64'h000012688B70E62C) $display("%t OK", $realtime);
      else $display("%t Desired: 000012688B70E62C", $realtime);
//------------------------------------------------------------------------------
    //inputA:-9.0000000000e-300
    //inputB:5.0000000000e+100
    opa_h  = 64'b1000000111011000000110111110001110111011010110000001000111000100;
    opb_h  = 64'b0101010011010110110111000001100001101110111110011111010001011100;
    fpu_op = 3'b011;
    rmode = 2'b11;
    Operation(clk, opa_h, opb_h, opa_i, opb_i, enable);
    load_result(clk, ready, out_fp_o, out_fp_h);

    //Output:-4.940656458412465e-324
    assert (out_fp_h == 64'h8000000000000001) $display("%t OK", $realtime);
      else $display("%t Desired: 8000000000000001", $realtime);
//------------------------------------------------------------------------------
    //inputA:4.0000000000e+100
    //inputB:3.0000000000e-090
    opa_h  = 64'b0101010011010010010010011010110100100101100101001100001101111101;
    opb_h  = 64'b0010110101011000011100011100011001000110111001011001010110100111;
    fpu_op = 3'b010;
    rmode = 2'b10;
    Operation(clk, opa_h, opb_h, opa_i, opb_i, enable);
    load_result(clk, ready, out_fp_o, out_fp_h);

    //Output:1.200000000000000e+011
    assert (out_fp_h == 64'h423BF08EB0000001) $display("%t OK", $realtime);
      else $display("%t Desired: 423BF08EB0000001", $realtime);
//------------------------------------------------------------------------------
    //inputA:-9.9000000000e-002
    //inputB:4.0220000000e+001
    opa_h  = 64'b1011111110111001010110000001000001100010010011011101001011110010;
    opb_h  = 64'b0100000001000100000111000010100011110101110000101000111101011100;
    fpu_op = 3'b000;
    rmode = 2'b11;
    Operation(clk, opa_h, opb_h, opa_i, opb_i, enable);
    load_result(clk, ready, out_fp_o, out_fp_h);

    //Output:4.012100000000000e+001
    assert (out_fp_h == 64'h40440F7CED916872) $display("%t OK", $realtime);
      else $display("%t Desired: 40440F7CED916872", $realtime);
//------------------------------------------------------------------------------
    //inputA:9.0770000000e+001
    //inputB:-2.0330000000e+001
    opa_h  = 64'b0100000001010110101100010100011110101110000101000111101011100001;
    opb_h  = 64'b1100000000110100010101000111101011100001010001111010111000010100;
    fpu_op = 3'b000;
    rmode = 2'b00;
    Operation(clk, opa_h, opb_h, opa_i, opb_i, enable);
    load_result(clk, ready, out_fp_o, out_fp_h);

    //Output:7.044000000000000e+001
    assert (out_fp_h == 64'h40519C28F5C28F5C) $display("%t OK", $realtime);
      else $display("%t Desired: 40519C28F5C28F5C", $realtime);
//------------------------------------------------------------------------------
    //inputA:4.9077000000e+002
    //inputB:-3.4434000000e+002
    Operation(clk, opa_h, opb_h, opa_i, opb_i, enable);
    load_result(clk, ready, out_fp_o, out_fp_h);

    opa_h  = 64'b0100000001111110101011000101000111101011100001010001111010111000;
    opb_h  = 64'b1100000001110101100001010111000010100011110101110000101000111101;
    fpu_op = 3'b001;
    rmode = 2'b00;
    Operation(clk, opa_h, opb_h, opa_i, opb_i, enable);
    load_result(clk, ready, out_fp_o, out_fp_h);

    //Output:8.351100000000000e+002
    assert (out_fp_h == 64'h408A18E147AE147B) $display("%t OK", $realtime);
      else $display("%t Desired: 408A18E147AE147B", $realtime);
//-----------------------------------------------------------------------------
    //inputA:9.0000000000e+034
    //inputB:2.7700000000e+000
    opa_h  = 64'b0100011100110001010101010101011110110100000110011100010111000010;
    opb_h  = 64'b0100000000000110001010001111010111000010100011110101110000101001;
    fpu_op = 3'b011;
    rmode = 2'b00;
    Operation(clk, opa_h, opb_h, opa_i, opb_i, enable);
    load_result(clk, ready, out_fp_o, out_fp_h);

    //Output:3.249097472924188e+034
    assert (out_fp_h == 64'h471907B705EBEABE) $display("%t OK", $realtime);
      else $display("%t Desired: 471907B705EBEABE", $realtime);
//------------------------------------------------------------------------------
    //inputA:3.9999999989e-315
    //inputB:1.0000000000e-002

    opa_h  = 64'b0000000000000000000000000000000000110000010000011010011100110101;
    opb_h  = 64'b0011111110000100011110101110000101000111101011100001010001111011;
    fpu_op = 3'b010;
    rmode = 2'b10;
    Operation(clk, opa_h, opb_h, opa_i, opb_i, enable);
    load_result(clk, ready, out_fp_o, out_fp_h);

    //Output:4.000000428704504e-317
    assert (out_fp_h == 64'h00000000007B895B) $display("%t OK", $realtime);
      else $display("%t Desired: 00000000007B895B", $realtime);
//------------------------------------------------------------------------------
    //inputA:-9.0000000000e+003
    //inputB:8.0000000000e+003

    opa_h  = 64'b1100000011000001100101000000000000000000000000000000000000000000;
    opb_h  = 64'b0100000010111111010000000000000000000000000000000000000000000000;
    fpu_op = 3'b011;
    rmode = 2'b00;
    Operation(clk, opa_h, opb_h, opa_i, opb_i, enable);
    load_result(clk, ready, out_fp_o, out_fp_h);

    //Output:-1.125000000000000e+000
    assert (out_fp_h == 64'hBFF2000000000000) $display("%t OK", $realtime);
      else $display("%t Desired: BFF2000000000000", $realtime);
//------------------------------------------------------------------------------
    //inputA:9.8440000000e+003
    //inputB:0.0000000000e+000

    opa_h  = 64'b0100000011000011001110100000000000000000000000000000000000000000;
    opb_h  = 64'b0000000000000000000000000000000000000000000000000000000000000000;
    fpu_op = 3'b011;
    rmode = 2'b10;
    Operation(clk, opa_h, opb_h, opa_i, opb_i, enable);
    load_result(clk, ready, out_fp_o, out_fp_h);

    //Output:1.#INF00000000000e+000
    assert (out_fp_h == 64'h7FF0000000000000) $display("%t OK", $realtime);
      else $display("%t Desired: 7FF0000000000000", $realtime);
//------------------------------------------------------------------------------
    //inputA:4.4440000000e+002
    //inputB:-8.8800000000e+002

    opa_h  = 64'b0100000001111011110001100110011001100110011001100110011001100110;
    opb_h  = 64'b1100000010001011110000000000000000000000000000000000000000000000;
    fpu_op = 3'b001;
    rmode = 2'b10;
    Operation(clk, opa_h, opb_h, opa_i, opb_i, enable);
    load_result(clk, ready, out_fp_o, out_fp_h);

    //Output:1.332400000000000e+003
    assert (out_fp_h == 64'h4094D1999999999A) $display("%t OK", $realtime);
      else $display("%t Desired: 4094D1999999999A", $realtime);
//------------------------------------------------------------------------------
    //inputA:3.0000000000e-309
    //inputB:3.0000000000e+080

    opa_h  = 64'b0000000000000010001010000100000001010111001110101111100100001100;
    opb_h  = 64'b0101000010100100001111011011001101111101011101001011110010000111;
    fpu_op = 3'b011;
    rmode = 2'b00;
    Operation(clk, opa_h, opb_h, opa_i, opb_i, enable);
    load_result(clk, ready, out_fp_o, out_fp_h);

    //Output:0.000000000000000e+000
    assert (out_fp_h == 64'h0000000000000000) $display("%t OK", $realtime);
      else $display("%t Desired: 0000000000000000", $realtime);
//------------------------------------------------------------------------------
    //inputA:4.9900000000e+002
    //inputB:-3.3000000000e-003

    opa_h  = 64'b0100000001111111001100000000000000000000000000000000000000000000;
    opb_h  = 64'b1011111101101011000010001001101000000010011101010010010101000110;
    fpu_op = 3'b010;
    rmode = 2'b11;
    Operation(clk, opa_h, opb_h, opa_i, opb_i, enable);
    load_result(clk, ready, out_fp_o, out_fp_h);

    //Output:-1.646700000000000e+000
    assert (out_fp_h == 64'hBFFA58E219652BD4) $display("%t OK", $realtime);
      else $display("%t Desired: BFFA58E219652BD4", $realtime);
//------------------------------------------------------------------------------
    //inputA:9.0000000000e+034
    //inputB:4.0000000000e+023

    opa_h  = 64'b0100011100110001010101010101011110110100000110011100010111000010;
    opb_h  = 64'b0100010011010101001011010000001011000111111000010100101011110110;
    fpu_op = 3'b000;
    rmode = 2'b10;
    Operation(clk, opa_h, opb_h, opa_i, opb_i, enable);
    load_result(clk, ready, out_fp_o, out_fp_h);

    //Output:9.000000000040000e+034
    assert (out_fp_h == 64'h47315557B41A1A76) $display("%t OK", $realtime);
      else $display("%t Desired: 47315557B41A1A76", $realtime);
//------------------------------------------------------------------------------
    //inputA:4.0000000000e+080
    //inputB:3.0000000000e-002

    opa_h  = 64'b0101000010101010111111001110111101010001111100001111101101011111;
    opb_h  = 64'b0011111110011110101110000101000111101011100001010001111010111000;
    fpu_op = 3'b000;
    rmode = 2'b10;
    Operation(clk, opa_h, opb_h, opa_i, opb_i, enable);
    load_result(clk, ready, out_fp_o, out_fp_h);

    //Output:4.000000000000001e+080
    assert (out_fp_h == 64'h50AAFCEF51F0FB60) $display("%t OK", $realtime);
      else $display("%t Desired: 50AAFCEF51F0FB60", $realtime);
//------------------------------------------------------------------------------
    //inputA:-5.4770000000e+000
    //inputB:-8.9990000000e+000

    opa_h  = 64'b1100000000010101111010000111001010110000001000001100010010011100;
    opb_h  = 64'b1100000000100001111111110111110011101101100100010110100001110011;
    fpu_op = 3'b011;
    rmode = 2'b10;
    Operation(clk, opa_h, opb_h, opa_i, opb_i, enable);
    load_result(clk, ready, out_fp_o, out_fp_h);

    //Output:6.086231803533726e-001
    assert (out_fp_h == 64'h3FE379D751E6915E) $display("%t OK", $realtime);
      else $display("%t Desired: 3FE379D751E6915E", $realtime);
//------------------------------------------------------------------------------
    //inputA:-7.7000000000e+001
    //inputB:-8.8400000000e+001

    opa_h  = 64'b1100000001010011010000000000000000000000000000000000000000000000;
    opb_h  = 64'b1100000001010110000110011001100110011001100110011001100110011010;
    fpu_op = 3'b010;
    rmode = 2'b10;
    Operation(clk, opa_h, opb_h, opa_i, opb_i, enable);
    load_result(clk, ready, out_fp_o, out_fp_h);

    //Output:6.806800000000001e+003
    assert (out_fp_h == 64'h40BA96CCCCCCCCCE) $display("%t OK", $realtime);
      else $display("%t Desired: 40BA96CCCCCCCCCE", $realtime);
//------------------------------------------------------------------------------
    //inputA:4.0000000000e+009
    //inputB:3.0000000000e+008

    opa_h  = 64'b0100000111101101110011010110010100000000000000000000000000000000;
    opb_h  = 64'b0100000110110001111000011010001100000000000000000000000000000000;
    fpu_op = 3'b011;
    rmode = 2'b00;
    Operation(clk, opa_h, opb_h, opa_i, opb_i, enable);
    load_result(clk, ready, out_fp_o, out_fp_h);

    //Output:1.333333333333333e+001
    assert (out_fp_h == 64'h402AAAAAAAAAAAAB) $display("%t OK", $realtime);
      else $display("%t Desired: 402AAAAAAAAAAAAB", $realtime);
//------------------------------------------------------------------------------
    //inputA:9.0000000000e-311
    //inputB:8.0000000000e-311

    opa_h  = 64'b0000000000000000000100001001000101001010010011000000001001011010;
    opb_h  = 64'b0000000000000000000011101011101000001001001001110001111010001001;
    fpu_op = 3'b000;
    rmode = 2'b00;
    Operation(clk, opa_h, opb_h, opa_i, opb_i, enable);
    load_result(clk, ready, out_fp_o, out_fp_h);

    //Output:1.700000000000010e-310
    assert (out_fp_h == 64'h00001F4B537320E3) $display("%t OK", $realtime);
      else $display("%t Desired: 00001F4B537320E3", $realtime);
//------------------------------------------------------------------------------
    //inputA:1.9999777344e-320
    //inputB:5.0000000000e+099

    opa_h  = 64'b0000000000000000000000000000000000000000000000000000111111010000;
    opb_h  = 64'b0101010010100010010010011010110100100101100101001100001101111101;
    fpu_op = 3'b010;
    rmode = 2'b10;
    Operation(clk, opa_h, opb_h, opa_i, opb_i, enable);
    load_result(clk, ready, out_fp_o, out_fp_h);

    //Output:9.999888671826831e-221
    assert (out_fp_h == 64'h124212D01E240533) $display("%t OK", $realtime);
      else $display("%t Desired: 124212D01E240533", $realtime);
//------------------------------------------------------------------------------
    //inputA:4.4444000000e+004
    //inputB:3.3000000000e+001

    opa_h  = 64'b0100000011100101101100111000000000000000000000000000000000000000;
    opb_h  = 64'b0100000001000000100000000000000000000000000000000000000000000000;
    fpu_op = 3'b011;
    rmode = 2'b00;
    Operation(clk, opa_h, opb_h, opa_i, opb_i, enable);
    load_result(clk, ready, out_fp_o, out_fp_h);

    //Output:1.346787878787879e+003
    assert (out_fp_h == 64'h40950B26C9B26C9B) $display("%t OK", $realtime);
      else $display("%t Desired: 40950B26C9B26C9B", $realtime);
//------------------------------------------------------------------------------
    //inputA:9.7730000000e+000
    //inputB:9.7720000000e+000

    opa_h  = 64'b0100000000100011100010111100011010100111111011111001110110110010;
    opb_h  = 64'b0100000000100011100010110100001110010101100000010000011000100101;
    fpu_op = 3'b011;
    rmode = 2'b00;
    Operation(clk, opa_h, opb_h, opa_i, opb_i, enable);
    load_result(clk, ready, out_fp_o, out_fp_h);

    //Output:1.000102333196889e+000
    assert (out_fp_h == 64'h3FF0006B4DDBBE31) $display("%t OK", $realtime);
      else $display("%t Desired: 3FF0006B4DDBBE31", $realtime);
//------------------------------------------------------------------------------
    //inputA:8.3345700000e+003
    //inputB:1.0000000000e+000

    opa_h  = 64'b0100000011000000010001110100100011110101110000101000111101011100;
    opb_h  = 64'b0011111111110000000000000000000000000000000000000000000000000000;
    fpu_op = 3'b010;
    rmode = 2'b00;
    Operation(clk, opa_h, opb_h, opa_i, opb_i, enable);
    load_result(clk, ready, out_fp_o, out_fp_h);

    //Output:8.334570000000000e+003
    assert (out_fp_h == 64'h40C04748F5C28F5C) $display("%t OK", $realtime);
      else $display("%t Desired: 40C04748F5C28F5C", $realtime);
//------------------------------------------------------------------------------
    //inputA:-1.0000000000e+000
    //inputB:5.8990000000e+003

    opa_h  = 64'b1011111111110000000000000000000000000000000000000000000000000000;
    opb_h  = 64'b0100000010110111000010110000000000000000000000000000000000000000;
    fpu_op = 3'b010;
    rmode = 2'b11;
    Operation(clk, opa_h, opb_h, opa_i, opb_i, enable);
    load_result(clk, ready, out_fp_o, out_fp_h);

    //Output:-5.899000000000000e+003
    assert (out_fp_h == 64'hC0B70B0000000000) $display("%t OK", $realtime);
      else $display("%t Desired: C0B70B0000000000", $realtime);
//------------------------------------------------------------------------------
    //inputA:6.1000000000e+000
    //inputB:-6.0990000000e+000

    opa_h  = 64'b0100000000011000011001100110011001100110011001100110011001100110;
    opb_h  = 64'b1100000000011000011001010110000001000001100010010011011101001100;
    fpu_op = 3'b000;
    rmode = 2'b10;
    Operation(clk, opa_h, opb_h, opa_i, opb_i, enable);
    load_result(clk, ready, out_fp_o, out_fp_h);

    //Output:9.999999999994458e-004
    assert (out_fp_h == 64'h3F50624DD2F1A000) $display("%t OK", $realtime);
      else $display("%t Desired: 3F50624DD2F1A000", $realtime);
//------------------------------------------------------------------------------
    //inputA:3.0000000000e-300
    //inputB:3.0000000000e-015

    opa_h  = 64'b0000000111000000000100101001011111010010001110101011011010000011;
    opb_h  = 64'b0011110011101011000001011000011101101110010110110000000100100000;
    fpu_op = 3'b010;
    rmode = 2'b00;
    Operation(clk, opa_h, opb_h, opa_i, opb_i, enable);
    load_result(clk, ready, out_fp_o, out_fp_h);

    //Output:9.000000001157124e-315
    assert (out_fp_h == 64'h000000006C93B838) $display("%t OK", $realtime);
      else $display("%t Desired: 000000006C93B838", $realtime);
//------------------------------------------------------------------------------
    //inputA:-9.0000000000e+088
    //inputB:4.0000000000e+084

    opa_h  = 64'b1101001001100110100111110000000010010101111101001101000000000000;
    opb_h  = 64'b0101000110000000011110001110000100010001110000110101010101101101;
    fpu_op = 3'b000;
    rmode = 2'b00;
    Operation(clk, opa_h, opb_h, opa_i, opb_i, enable);
    load_result(clk, ready, out_fp_o, out_fp_h);

    //Output:-8.999600000000000e+088
    assert (out_fp_h == 64'hD2669EBEB27088F3) $display("%t OK", $realtime);
      else $display("%t Desired: D2669EBEB27088F3", $realtime);
//------------------------------------------------------------------------------
    //inputA:6.6210000000e+001
    //inputB:6.9892000000e+001

    opa_h  = 64'b0100000001010000100011010111000010100011110101110000101000111101;
    opb_h  = 64'b0100000001010001011110010001011010000111001010110000001000001100;
    fpu_op = 3'b011;
    rmode = 2'b00;
    Operation(clk, opa_h, opb_h, opa_i, opb_i, enable);
    load_result(clk, ready, out_fp_o, out_fp_h);

    //Output:9.473187203113375e-001
    assert (out_fp_h == 64'h3FEE506F59540645) $display("%t OK", $realtime);
      else $display("%t Desired: 3FEE506F59540645", $realtime);
//------------------------------------------------------------------------------
    //inputA:-5.0000000000e-309
    //inputB:4.0000000000e-310

    opa_h  = 64'b1000000000000011100110000110101100111100000011001111010001101001;
    opb_h  = 64'b0000000000000000010010011010001000101101110000111001100010101100;
    fpu_op = 3'b000;
    rmode = 2'b11;
    Operation(clk, opa_h, opb_h, opa_i, opb_i, enable);
    load_result(clk, ready, out_fp_o, out_fp_h);

    //Output:-4.600000000000001e-309
    assert (out_fp_h == 64'h80034EC90E495BBD) $display("%t OK", $realtime);
      else $display("%t Desired: 80034EC90E495BBD", $realtime);
//------------------------------------------------------------------------------
    //inputA:8.8000000000e+001
    //inputB:0.0000000000e+000

    opa_h  = 64'b0100000001010110000000000000000000000000000000000000000000000000;
    opb_h  = 64'b0000000000000000000000000000000000000000000000000000000000000000;
    fpu_op = 3'b011;
    rmode = 2'b01;
    Operation(clk, opa_h, opb_h, opa_i, opb_i, enable);
    load_result(clk, ready, out_fp_o, out_fp_h);

    //Output:1.#INF00000000000e+000
    assert (out_fp_h == 64'h7FEFFFFFFFFFFFFF) $display("%t OK", $realtime);
      else $display("%t Desired: 7FEFFFFFFFFFFFFF", $realtime);
//------------------------------------------------------------------------------
    //inputA:4.5570000000e+002
    //inputB:3.4229100000e+003

    opa_h  = 64'b0100000001111100011110110011001100110011001100110011001100110011;
    opb_h  = 64'b0100000010101010101111011101000111101011100001010001111010111000;
    fpu_op = 3'b000;
    rmode = 2'b01;
    Operation(clk, opa_h, opb_h, opa_i, opb_i, enable);
    load_result(clk, ready, out_fp_o, out_fp_h);

    //Output:3.878610000000000e+003
    assert (out_fp_h == 64'h40AE4D3851EB851E) $display("%t OK", $realtime);
      else $display("%t Desired: 40AE4D3851EB851E", $realtime);
//------------------------------------------------------------------------------
    //inputA:9.9440000000e+003
    //inputB:2.3000000000e+001

    opa_h  = 64'b0100000011000011011011000000000000000000000000000000000000000000;
    opb_h  = 64'b0100000000110111000000000000000000000000000000000000000000000000;
    fpu_op = 3'b011;
    rmode = 2'b01;
    Operation(clk, opa_h, opb_h, opa_i, opb_i, enable);
    load_result(clk, ready, out_fp_o, out_fp_h);

    //Output:4.323478260869565e+002
    assert (out_fp_h == 64'h407B0590B21642C8) $display("%t OK", $realtime);
      else $display("%t Desired: 407B0590B21642C8", $realtime);
//------------------------------------------------------------------------------
    //inputA:-9.0054400000e+005
    //inputB:-3.4445500000e+005

    opa_h  = 64'b1100000100101011011110111000000000000000000000000000000000000000;
    opb_h  = 64'b1100000100010101000001100001110000000000000000000000000000000000;
    fpu_op = 3'b001;
    rmode = 2'b01;
    Operation(clk, opa_h, opb_h, opa_i, opb_i, enable);
    load_result(clk, ready, out_fp_o, out_fp_h);

    //Output:-5.560890000000000e+005
    assert (out_fp_h == 64'hC120F87200000000) $display("%t OK", $realtime);
      else $display("%t Desired: C120F87200000000", $realtime);
//------------------------------------------------------------------------------
    //inputA:5.5500000000e-002
    //inputB:3.2444400000e+005

    opa_h  = 64'b0011111110101100011010100111111011111001110110110010001011010001;
    opb_h  = 64'b0100000100010011110011010111000000000000000000000000000000000000;
    fpu_op = 3'b011;
    rmode = 2'b00;
    Operation(clk, opa_h, opb_h, opa_i, opb_i, enable);
    load_result(clk, ready, out_fp_o, out_fp_h);

    //Output:1.710618781669564e-007
    assert (out_fp_h == 64'h3E86F5A431628F6D) $display("%t OK", $realtime);
      else $display("%t Desired: 3E86F5A431628F6D", $realtime);
//------------------------------------------------------------------------------
    //inputA:1.2330000000e+000
    //inputB:1.5666600000e+000

    opa_h  = 64'b0011111111110011101110100101111000110101001111110111110011101110;
    opb_h  = 64'b0011111111111001000100010000101000010011011111110011100011000101;
    fpu_op = 3'b010;
    rmode = 2'b10;
    Operation(clk, opa_h, opb_h, opa_i, opb_i, enable);
    load_result(clk, ready, out_fp_o, out_fp_h);

    //Output:1.931691780000000e+000
    assert (out_fp_h == 64'h3FFEE835A3D0D51B) $display("%t OK", $realtime);
      else $display("%t Desired: 3FFEE835A3D0D51B", $realtime);
//------------------------------------------------------------------------------
    //inputA:9.7770000000e-001
    //inputB:3.0000000000e+099

    opa_h  = 64'b0011111111101111010010010101000110000010101010011001001100001100;
    opb_h  = 64'b0101010010010101111100100000001011111001111001011011011101100011;
    fpu_op = 3'b011;
    rmode = 2'b00;
    Operation(clk, opa_h, opb_h, opa_i, opb_i, enable);
    load_result(clk, ready, out_fp_o, out_fp_h);

    //Output:3.259000000000000e-100
    assert (out_fp_h == 64'h2B46CF7665DCED50) $display("%t OK", $realtime);
      else $display("%t Desired: 2B46CF7665DCED50", $realtime);
//------------------------------------------------------------------------------
    //inputA:4.4000000000e+007
    //inputB:6.0000000000e+002
    opa_h  = 64'b0100000110000100111110110001100000000000000000000000000000000000;
    opb_h  = 64'b0100000010000010110000000000000000000000000000000000000000000000;
    fpu_op = 3'b010;
    rmode = 2'b00;
    Operation(clk, opa_h, opb_h, opa_i, opb_i, enable);
    load_result(clk, ready, out_fp_o, out_fp_h);

    //Output:2.640000000000000e+010
    assert (out_fp_h == 64'h4218964020000000) $display("%t OK", $realtime);
      else $display("%t Desired: 4218964020000000", $realtime);
//------------------------------------------------------------------------------
    //inputA:3.9800000000e+000
    //inputB:3.7700000000e+000
    opa_h  = 64'b0100000000001111110101110000101000111101011100001010001111010111;
    opb_h  = 64'b0100000000001110001010001111010111000010100011110101110000101001;
    fpu_op = 3'b000;
    rmode = 2'b01;
    Operation(clk, opa_h, opb_h, opa_i, opb_i, enable);
    load_result(clk, ready, out_fp_o, out_fp_h);

    //Output:7.750000000000000e+000
    assert (out_fp_h == 64'h401F000000000000) $display("%t OK", $realtime);
      else $display("%t Desired: 401F000000000000", $realtime);
//------------------------------------------------------------------------------
    //inputA:8.0400000000e+000
    //inputB:8.0395700000e+000
    opa_h  = 64'b0100000000100000000101000111101011100001010001111010111000010100;
    opb_h  = 64'b0100000000100000000101000100001010000100110111111100111000110001;
    fpu_op = 3'b001;
    rmode = 2'b01;
    Operation(clk, opa_h, opb_h, opa_i, opb_i, enable);
    load_result(clk, ready, out_fp_o, out_fp_h);

    //Output:4.299999999997084e-004
    assert (out_fp_h == 64'h3F3C2E33EFF18000) $display("%t OK", $realtime);
      else $display("%t Desired: 3F3C2E33EFF18000", $realtime);
    #20;
    $display("Simulation completed.");
    $finish;
  end

  // ================================================================
  // Waveform Dump
  // ================================================================
  // initial begin
  //   $dumpfile("fpu_double_tb.vcd");
  //   $dumpvars(0, fpu_double_tb);
  // end

endmodule
