`timescale 1ns/1ps
module tb_datapath_lui;
    reg         clk, rst;
    wire [6:0]  opcode;
    wire [2:0]  funct3;
    wire        funct7_5;
    wire        wr, ALUSrc, MemWrite, Branch, Jump;
    wire [2:0]  ImmSrc;       // Sadece burada tanımlı
    wire [2:0]  ResultSrc;    // Sadece burada tanımlı
    wire [1:0]  ALUOp;        // Sadece burada tanımlı
    wire [2:0]  ALUControl;
    wire [31:0] aluResult, ImmExt, WBData;

    // Control & Datapath
    control CU (
        .opcode(opcode),
        .funct3(funct3),
        .funct7_5(funct7_5),
        .RegWrite(wr),
        .ImmSrc(ImmSrc),
        .ALUSrc(ALUSrc),
        .MemWrite(MemWrite),
        .ResultSrc(ResultSrc),
        .Branch(Branch),
        .ALUOp(ALUOp),
        .Jump(Jump),
        .ALUControl(ALUControl)
    );
    datapath DP (
        .clk(clk),
        .rst(rst),
        .opcode(opcode),
        .funct3(funct3),
        .funct7_5(funct7_5),
        .wr(wr),
        .ImmSrc(ImmSrc),
        .ALUSrc(ALUSrc),
        .MemWrite(MemWrite),
        .ResultSrc(ResultSrc),
        .Branch(Branch),
        .ALUOp(ALUOp),
        .Jump(Jump),
        .ALUControl(ALUControl),
        .aluResult(aluResult)
    );

    // Instruction field slice
    assign opcode    = DP.Instr[6:0];
    assign funct3    = DP.Instr[14:12];
    assign funct7_5  = DP.Instr[30];

    // Clock & Reset
    initial begin clk = 0; forever #5 clk = ~clk; end
    initial begin rst = 1; #10 rst = 0; end

    // ROM’u yükle
    initial begin
        $readmemh("instr.mem", DP.IM.mem);
    end

    // Dalga formu
    initial begin
        $dumpfile("simulation_q3.vcd");
        $dumpvars(0, tb_datapath_lui);
    end

    // Simülasyonu bitir
    initial #100 $finish;

    // Doğrulama
    always @(posedge clk) begin
        if (DP.PC == 0) begin
            $display("LUI → ImmExt=0x%h, WBData=0x%h", DP.ImmExt, DP.WBData);
        end
    end
endmodule
