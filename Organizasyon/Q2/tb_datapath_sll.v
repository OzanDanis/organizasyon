`timescale 1ns/1ps
module tb_datapath_sll;
    reg         clk, rst;
    wire [6:0]  opcode;
    wire [2:0]  funct3;      // <<< bunlar Instr’den slice edilecek
    wire        funct7_5;
    wire        wr, ALUSrc, MemWrite, Branch, Jump;
    wire [1:0]  ImmSrc, ResultSrc, ALUOp;
    wire [2:0]  ALUControl;
    wire [31:0] aluResult;

    // 1) Control ve Datapath
    control CU (
        .opcode(opcode), .funct3(funct3), .funct7_5(funct7_5),
        .RegWrite(wr),  .ImmSrc(ImmSrc),  .ALUSrc(ALUSrc),
        .MemWrite(MemWrite), .ResultSrc(ResultSrc),
        .Branch(Branch), .ALUOp(ALUOp),  .Jump(Jump),
        .ALUControl(ALUControl)
    );
    datapath DP (
        .clk(clk), .rst(rst),
        .opcode(opcode), .funct3(funct3), .funct7_5(funct7_5),
        .wr(wr), .ImmSrc(ImmSrc), .ALUSrc(ALUSrc),
        .MemWrite(MemWrite), .ResultSrc(ResultSrc),
        .Branch(Branch), .ALUOp(ALUOp), .Jump(Jump),
        .ALUControl(ALUControl),
        .aluResult(aluResult)
    );

    // 2) Burada slice edin:
    assign opcode    = DP.Instr[6:0];
    assign funct3    = DP.Instr[14:12];  // ← 3 bit
    assign funct7_5  = DP.Instr[30];     // ← 1 bit

    // 3) Clock & Reset
    initial begin clk = 0; forever #5 clk = ~clk; end
    initial begin rst = 1; #10 rst = 0; end

    // 4) ROM’u yükle
    initial begin
        $readmemh("instr.mem", DP.IM.mem);
    end

    // 5) Dalga formu al
    initial begin
        $dumpfile("simulation_q2.vcd");
        $dumpvars(0, tb_datapath_sll);
    end

    // 6) Birkaç çevrim sonra bitir
    initial begin #100 $finish; end

endmodule
