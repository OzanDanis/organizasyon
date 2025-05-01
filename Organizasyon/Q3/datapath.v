module datapath(
    input  wire        clk,
    input  wire        rst,
    input  wire [6:0]  opcode,
    input  wire [2:0]  funct3,
    input  wire        funct7_5,
    input  wire        wr,
    input  wire [2:0]  ImmSrc,      // 3 bit
    input  wire        ALUSrc,
    input  wire        MemWrite,
    input  wire [2:0]  ResultSrc,   // 3 bit
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
    always @(posedge clk or posedge rst)
        if (rst)          pc_reg <= 0;
        else if (Jump)    pc_reg <= PCTarget;
        else if (Branch && Zero) pc_reg <= PC + ImmExt;
        else              pc_reg <= PCPlus4;

    assign PC       = pc_reg;
    assign PCPlus4  = PC + 4;
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
    alu ALU_u(
        .A(RD1), .B(ALUInB),
        .ALUControl(ALUControl),
        .ALUResult(aluResult),
        .Zero(Zero)
    );

    // Data Memory
    data_mem DM(
        .clk(clk), .MemWrite(MemWrite),
        .addr(aluResult), .WriteData(RD2),
        .ReadData(MemRD)
    );

    // Write-back MUX
    reg [31:0] wb_reg;
    always @(*) begin
        case (ResultSrc)
            3'b000: wb_reg = aluResult;
            3'b001: wb_reg = MemRD;
            3'b010: wb_reg = PCPlus4;
            3'b011: wb_reg = ImmExt;   // LUI
            default: wb_reg = 32'b0;
        endcase
    end
    assign WBData = wb_reg;

endmodule
