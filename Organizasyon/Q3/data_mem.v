module data_mem(
    input  wire        clk,
    input  wire        MemWrite,
    input  wire [31:0] addr,
    input  wire [31:0] WriteData,
    output reg  [31:0] ReadData
);

    reg [31:0] mem [0:1023];

    // Asenkron okuma
    always @(*) begin
        ReadData = mem[addr[11:2]];
    end

    // Senkron yazma
    always @(posedge clk) begin
        if (MemWrite)
            mem[addr[11:2]] <= WriteData;
    end

endmodule
