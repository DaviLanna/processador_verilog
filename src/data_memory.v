// -----------------------------------------------------------------------------
// Arquivo: data_memory.v
// Estágio: Memory (MEM)
// Descrição: Memória de Dados do processador RV32I.
// Utilizada pelas instruções LW (Load Word) e SW (Store Word).
// -----------------------------------------------------------------------------

module DataMemory (

    input wire clk,

    // Sinais de controle
    input wire mem_read,
    input wire mem_write,

    // Endereço calculado pela ALU
    input wire [31:0] address,

    // Dado a ser escrito na memória, usado no SW
    input wire [31:0] write_data,

    // Dado lido da memória, usado no LW
    output wire [31:0] read_data

);

    // Memória com 256 posições de 32 bits
    reg [31:0] memory [0:255];

    // -------------------------------------------------------------------------
    // LEITURA (Combinacional)
    // -------------------------------------------------------------------------
    // Para LW, lê a posição da memória indicada pelo endereço.
    // Como cada palavra tem 4 bytes, usamos address[31:2].
    // Exemplo:
    // address = 0  -> memory[0]
    // address = 4  -> memory[1]
    // address = 8  -> memory[2]
    // -------------------------------------------------------------------------

    assign read_data = (mem_read) ? memory[address[31:2]] : 32'b0;

    // -------------------------------------------------------------------------
    // ESCRITA (Sequencial)
    // -------------------------------------------------------------------------
    // Para SW, escreve na memória na borda de subida do clock.
    // -------------------------------------------------------------------------

    always @(posedge clk) begin

        if (mem_write) begin
            memory[address[31:2]] <= write_data;
        end

    end

endmodule