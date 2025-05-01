module control(
    input  wire [6:0]  opcode,
    input  wire [2:0]  funct3,
    input  wire        funct7_5,
    output reg         RegWrite,
    output reg  [1:0]  ImmSrc,
    output reg         ALUSrc,
    output reg         MemWrite,
    output reg  [1:0]  ResultSrc,
    output reg         Branch,
    output reg  [1:0]  ALUOp,
    output reg         Jump,
    output reg  [2:0]  ALUControl
);

    // Main Decoder
    always @(*) begin
        case (opcode)
            7'b0000011: begin // lw
                RegWrite=1; ImmSrc=2'b00; ALUSrc=1;
                MemWrite=0; ResultSrc=2'b01; Branch=0;
                ALUOp=2'b00; Jump=0;
            end
            7'b0100011: begin // sw
                RegWrite=0; ImmSrc=2'b01; ALUSrc=1;
                MemWrite=1; ResultSrc=2'b00; Branch=0;
                ALUOp=2'b00; Jump=0;
            end
            7'b0110011: begin // R-type
                RegWrite=1; ImmSrc=2'b00; ALUSrc=0;
                MemWrite=0; ResultSrc=2'b00; Branch=0;
                ALUOp=2'b10; Jump=0;
            end
            7'b1100011: begin // beq
                RegWrite=0; ImmSrc=2'b10; ALUSrc=0;
                MemWrite=0; ResultSrc=2'b00; Branch=1;
                ALUOp=2'b01; Jump=0;
            end
            7'b0010011: begin // addi, slti, ori, andi
                RegWrite=1; ImmSrc=2'b00; ALUSrc=1;
                MemWrite=0; ResultSrc=2'b00; Branch=0;
                ALUOp=2'b00; Jump=0;
            end
            7'b1101111: begin // jal
                RegWrite=1; ImmSrc=2'b11; ALUSrc=0;
                MemWrite=0; ResultSrc=2'b10; Branch=0;
                ALUOp=2'b00; Jump=1;
            end
            default: begin
                RegWrite=0; ImmSrc=2'b00; ALUSrc=0;
                MemWrite=0; ResultSrc=2'b00; Branch=0;
                ALUOp=2'b00; Jump=0;
            end
        endcase
    end

    // ALU Decoder
    always @(*) begin
        case (ALUOp)
            2'b00: begin
                if      (opcode==7'b0010011 && funct3==3'b010) ALUControl=3'b101; // slti
                else if (opcode==7'b0010011 && funct3==3'b110) ALUControl=3'b011; // ori
                else if (opcode==7'b0010011 && funct3==3'b111) ALUControl=3'b010; // andi
                else                                           ALUControl=3'b000; // add/addi
            end
            2'b01: ALUControl=3'b001; // sub (beq)
            2'b10: begin              // R-type
                case ({funct7_5,funct3})
                    4'b0000: ALUControl=3'b000; // add
                    4'b1000: ALUControl=3'b001; // sub
                    4'b0001: ALUControl=3'b100; // sll  ← DÜZELTİLDİ
                    4'b0010: ALUControl=3'b101; // slt
                    4'b0110: ALUControl=3'b011; // or
                    4'b0111: ALUControl=3'b010; // and
                    default: ALUControl=3'b000;
                endcase
            end
            default: ALUControl=3'b000;
        endcase
    end

endmodule
