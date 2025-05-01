module datapath(
    input  wire        clk,
    input  wire        rst,
    input  wire [6:0]  opcode,
    input  wire [2:0]  funct3,
    input  wire        funct7_5,
    input  wire        wr,
    input  wire [1:0]  ImmSrc,
    input  wire        ALUSrc,
    input  wire        MemWrite,
    input  wire [1:0]  ResultSrc,
    input  wire        Branch,
    input  wire [1:0]  ALUOp,
    input  wire        Jump,
    input  wire [2:0]  ALUControl,
    output wire [31:0] aluResult
);

    // Ara sinyaller
    wire [31:0] PC, PCPlus4, PCTarget, Instr;
    wire [31:0] RD1, RD2, ImmExt, ALUInB, MemRD, WBData;
    wire        Zero;

    // PC register
    reg [31:0] pc_reg;
    assign PC = pc_reg;
    always @(posedge clk or posedge rst) begin
        if (rst)                pc_reg <= 0;
        else if (Jump)          pc_reg <= PCTarget;
        else if (Branch && Zero) pc_reg <= PC + ImmExt;
        else                    pc_reg <= PCPlus4;
    end

    assign PCPlus4 = PC + 4;
    assign PCTarget = PC + ImmExt;

    // Instruction Fetch
    instr_mem IM(.addr(PC), .instr(Instr));

    // Register File
    regfile RF(
        .clk(clk), .RegWrite(wr),
        .rs1(Instr[19:15]), .rs2(Instr[24:20]), .rd(Instr[11:7]),
        .WriteData(WBData),
        .ReadData1(RD1), .ReadData2(RD2)
    );

    // Immediate Generation
    imm_gen IG(.instr(Instr), .ImmSrc(ImmSrc), .ImmExt(ImmExt));

    // ALU
    assign ALUInB = ALUSrc ? ImmExt : RD2;
    alu ALU_u(.A(RD1), .B(ALUInB),
              .ALUControl(ALUControl),
              .ALUResult(aluResult),
              .Zero(Zero));

    // Data Memory
    data_mem DM(.clk(clk), .MemWrite(MemWrite),
                .addr(aluResult), .WriteData(RD2),
                .ReadData(MemRD));

    // Write-back MUX
    assign WBData = (ResultSrc==2'b00) ? aluResult :
                    (ResultSrc==2'b01) ? MemRD :
                                         PCPlus4;

endmodule
