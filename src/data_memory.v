// Memória RAM (Instruções lw/sw)
module data_memory (
    input wire clk,
    input wire mem_write,
    input wire mem_read,
    input wire [31:0] address,
    input wire [31:0] write_data,
    output reg [31:0] read_data
);
    // TODO: Implementar a memória RAM
endmodule
