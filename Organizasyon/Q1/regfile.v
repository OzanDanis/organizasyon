module regfile(
    input  wire        clk,
    input  wire        RegWrite,
    input  wire [4:0]  rs1,
    input  wire [4:0]  rs2,
    input  wire [4:0]  rd,
    input  wire [31:0] WriteData,
    output wire [31:0] ReadData1,
    output wire [31:0] ReadData2
);

    reg [31:0] regs [0:31];
    integer i;
    initial for (i = 0; i < 32; i = i + 1) regs[i] = 0;

    assign ReadData1 = (rs1 != 0) ? regs[rs1] : 32'b0;
    assign ReadData2 = (rs2 != 0) ? regs[rs2] : 32'b0;

    always @(posedge clk) begin
        if (RegWrite && rd != 0)
            regs[rd] <= WriteData;
    end

endmodule
