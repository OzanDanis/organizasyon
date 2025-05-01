module alu(
    input  wire [31:0] A,
    input  wire [31:0] B,
    input  wire [2:0]  ALUControl,
    output reg  [31:0] ALUResult,
    output wire        Zero
);

    always @(*) begin
        case (ALUControl)
            3'b000: ALUResult = A + B;        // add
            3'b001: ALUResult = A - B;        // sub
            3'b010: ALUResult = A & B;        // and
            3'b011: ALUResult = A | B;        // or
            3'b101: ALUResult = ($signed(A) < $signed(B)) ? 32'b1 : 32'b0; // slt
            default: ALUResult = 32'b0;
        endcase
    end

    assign Zero = (ALUResult == 0);

endmodule
