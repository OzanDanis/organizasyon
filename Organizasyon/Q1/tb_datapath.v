`timescale 1ns/1ps
module tb_datapath;
    reg         clk, rst;
    wire [6:0]  opcode;
    wire [2:0]  funct3;
    wire        funct7_5;
    wire        wr, ALUSrc, MemWrite, Branch, Jump;
    wire [1:0]  ImmSrc, ResultSrc, ALUOp;
    wire [2:0]  ALUControl;
    wire [31:0] aluResult;

    // DUT: Control
    control CU (
        .opcode(opcode), .funct3(funct3), .funct7_5(funct7_5),
        .RegWrite(wr), .ImmSrc(ImmSrc), .ALUSrc(ALUSrc),
        .MemWrite(MemWrite), .ResultSrc(ResultSrc),
        .Branch(Branch), .ALUOp(ALUOp), .Jump(Jump),
        .ALUControl(ALUControl)
    );

    // DUT: Datapath
    datapath DP (
        .clk(clk), .rst(rst),
        .opcode(opcode), .funct3(funct3), .funct7_5(funct7_5),
        .wr(wr), .ImmSrc(ImmSrc), .ALUSrc(ALUSrc),
        .MemWrite(MemWrite), .ResultSrc(ResultSrc),
        .Branch(Branch), .ALUOp(ALUOp), .Jump(Jump),
        .ALUControl(ALUControl),
        .aluResult(aluResult)
    );

    // Instr’in bit alanları
    assign opcode   = DP.Instr[6:0];
    assign funct3   = DP.Instr[14:12];
    assign funct7_5 = DP.Instr[30];

    // Clock & Reset
    initial begin
        clk = 0; forever #5 clk = ~clk;
    end
    initial begin
        rst = 1; #10 rst = 0;
    end

    // VCD dump
    initial begin
        $dumpfile("simulation_q1.vcd");
        $dumpvars(0, tb_datapath);
    end

    // Sadece adres sınırı: 12 talimat ⇒ 12*4 = 48 zamanı biraz aşalım
    initial begin
        #1000 $finish;
    end

endmodule
