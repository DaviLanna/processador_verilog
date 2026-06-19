// -----------------------------------------------------------------------------
// Arquivo: register_file.v
// Estágio: Instruction Decode (ID)
// Descrição: Banco de Registradores RV32I.
// Possui 32 registradores de 32 bits.
// O registrador x0 é permanentemente conectado ao valor zero.
// -----------------------------------------------------------------------------

module RegisterFile (

    input wire clk,

    // Sinal de controle de escrita
    input wire reg_write,

    // Registradores fonte (leitura)
    input wire [4:0] rs1,
    input wire [4:0] rs2,

    // Registrador destino (escrita)
    input wire [4:0] rd,

    // Dado a ser escrito
    input wire [31:0] write_data,

    // Dados lidos
    output wire [31:0] read_data1,
    output wire [31:0] read_data2

);

    // Banco de 32 registradores de 32 bits
    reg [31:0] registers [0:31];

    // -------------------------------------------------------------------------
    // LEITURA (Combinacional)
    // -------------------------------------------------------------------------
    // A leitura acontece imediatamente quando rs1 ou rs2 mudam.

    assign read_data1 = (rs1 == 5'd0) ? 32'd0 : registers[rs1];
    assign read_data2 = (rs2 == 5'd0) ? 32'd0 : registers[rs2];

    // -------------------------------------------------------------------------
    // ESCRITA (Sequencial)
    // -------------------------------------------------------------------------
    // A escrita acontece apenas na borda de subida do clock.

    always @(posedge clk) begin

        // Nunca permitir escrita em x0
        if (reg_write && (rd != 5'd0)) begin
            registers[rd] <= write_data;
        end

        // Garante que x0 permaneça sempre zero
        registers[0] <= 32'd0;

    end

endmodule