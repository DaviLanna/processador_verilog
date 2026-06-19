// -----------------------------------------------------------------------------
// Arquivo: instruction_memory.v
// Estágio: Instruction Fetch (IF)
// Descrição: Memória de Apenas Leitura (ROM) que guarda o programa.
// -----------------------------------------------------------------------------

module InstructionMemory (
    input wire [31:0] read_address, // O endereço que vem do PC
    output wire [31:0] instruction  // A instrução de 32 bits devolvida
);


    reg [31:0] memory [0:255];


    initial begin

        $readmemh("asm/instrucoes.hex", memory);
    end

    assign instruction = memory[read_address[31:2]];

endmodule