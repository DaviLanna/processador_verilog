// -----------------------------------------------------------------------------
// Arquivo: pc.v
// Estágio: Instruction Fetch (IF)
// Descrição: Contém o registrador do Program Counter e o somador de PC + 4.
// -----------------------------------------------------------------------------

// 1. O Registrador do Program Counter (Sequencial)
module ProgramCounter (
    input wire clk,
    input wire reset,
    input wire [31:0] pc_next,  // Próximo endereço (pode vir do PC+4 ou de um Salto)
    output reg [31:0] pc_out    // Endereço atual sendo executado
);

    // Bloco sequencial: o valor só atualiza na borda de subida do clock
    always @(posedge clk) begin
        if (reset) begin
            // Quando o reset é ativado (1), o PC zera. 
            // É assim que o processador sabe de onde começar a ler o programa.
            pc_out <= 32'h00000000;
        end else begin
            // Caso contrário, atualiza para o próximo endereço
            pc_out <= pc_next;
        end
    end

endmodule


// 2. O Somador de PC + 4 (Combinacional)
module PC_Adder (
    input wire [31:0] pc_in,       // Endereço atual do PC
    output wire [31:0] pc_plus_4   // Endereço atual + 4
);

    // Bloco combinacional: a soma acontece instantaneamente, sem depender de clock.
    // Como a memória do RISC-V é endereçada por byte e cada instrução tem 32 bits (4 bytes),
    // andamos de 4 em 4 na memória para pegar a próxima instrução.
    assign pc_plus_4 = pc_in + 32'd4;

endmodule