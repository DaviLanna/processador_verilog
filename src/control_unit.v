// A Unidade de Controle Geral Combinacional
module control_unit (
    input wire [6:0] opcode,
    output reg branch,
    output reg mem_read,
    output reg mem_to_reg,
    output reg [1:0] alu_op,
    output reg mem_write,
    output reg alu_src,
    output reg reg_write
);
    // TODO: Implementar lógica da Unidade de Controle
endmodule
