module control(
    input  wire [6:0]  opcode,
    input  wire [2:0]  funct3,
    input  wire        funct7_5,
    output reg         RegWrite,
    output reg  [2:0]  ImmSrc,      // 3 bit
    output reg         ALUSrc,
    output reg         MemWrite,
    output reg  [2:0]  ResultSrc,   // 3 bit
    output reg         Branch,
    output reg  [1:0]  ALUOp,
    output reg         Jump,
    output reg  [2:0]  ALUControl
);

    always @(*) begin
        case (opcode)
            7'b0000011: begin // lw
                RegWrite=1; ImmSrc=3'b000; ALUSrc=1;
                MemWrite=0; ResultSrc=3'b001; Branch=0;
                ALUOp=2'b00; Jump=0;
            end
            7'b0100011: begin // sw
                RegWrite=0; ImmSrc=3'b001; ALUSrc=1;
                MemWrite=1; ResultSrc=3'b000; Branch=0;
                ALUOp=2'b00; Jump=0;
            end
            7'b0110011: begin // R-type
                RegWrite=1; ImmSrc=3'b000; ALUSrc=0;
                MemWrite=0; ResultSrc=3'b000; Branch=0;
                ALUOp=2'b10; Jump=0;
            end
            7'b1100011: begin // beq
                RegWrite=0; ImmSrc=3'b010; ALUSrc=0;
                MemWrite=0; ResultSrc=3'b000; Branch=1;
                ALUOp=2'b01; Jump=0;
            end
            7'b0010011: begin // addi, slti, ori, andi
                RegWrite=1; ImmSrc=3'b000; ALUSrc=1;
                MemWrite=0; ResultSrc=3'b000; Branch=0;
                ALUOp=2'b00; Jump=0;
            end
            7'b1101111: begin // jal
                RegWrite=1; ImmSrc=3'b011; ALUSrc=0;
                MemWrite=0; ResultSrc=3'b010; Branch=0;
                ALUOp=2'b00; Jump=1;
            end
            7'b0110111: begin // lui
                RegWrite   = 1;
                ImmSrc     = 3'b100;  // U-type
                ALUSrc     = 1;
                MemWrite   = 0;
                ResultSrc  = 3'b011;  // WB = ImmExt
                Branch     = 0;
                ALUOp      = 2'b00;
                Jump       = 0;
            end
            default: begin
                RegWrite=0; ImmSrc=3'b000; ALUSrc=0;
                MemWrite=0; ResultSrc=3'b000; Branch=0;
                ALUOp=2'b00; Jump=0;
            end
        endcase
    end

    // ALU Decoder (unchanged from Q2)
    always @(*) begin
        case (ALUOp)
            2'b00: begin
                if      (opcode==7'b0010011 && funct3==3'b010) ALUControl=3'b101;
                else if (opcode==7'b0010011 && funct3==3'b110) ALUControl=3'b011;
                else if (opcode==7'b0010011 && funct3==3'b111) ALUControl=3'b010;
                else                                           ALUControl=3'b000;
            end
            2'b01: ALUControl=3'b001;
            2'b10: begin
                case ({funct7_5,funct3})
                    4'b0000: ALUControl=3'b000;
                    4'b1000: ALUControl=3'b001;
                    4'b0001: ALUControl=3'b100;
                    4'b0010: ALUControl=3'b101;
                    4'b0110: ALUControl=3'b011;
                    4'b0111: ALUControl=3'b010;
                    default: ALUControl=3'b000;
                endcase
            end
            default: ALUControl=3'b000;
        endcase
    end

endmodule
