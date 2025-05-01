module instr_mem(
    input  wire [31:0] addr,
    output reg  [31:0] instr
);

    // ROM  — instr.mem dosyasından okunur
    reg [31:0] mem [0:15];
    initial begin
        $readmemh("instr.mem", mem);
    end

    // adres >> 2 ile word-aligned index
    always @(*) begin
        instr = mem[addr[31:2]];
    end

endmodule
