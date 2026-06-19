// -----------------------------------------------------------------------------
// Arquivo: alu.v
// Estágio: Execute (EX)
// Descrição: Unidade Lógica e Aritmética. Executa operações matemáticas e 
// lógicas com base no sinal de controle de 4 bits.
// -----------------------------------------------------------------------------

module ALU (
    input wire [31:0] a,
    input wire [31:0] b,
    input wire [3:0] alu_control,
    
    output reg [31:0] result,
    output wire zero
);

    // O sinal 'zero' é fundamental para as instruções de desvio (Branch).
    // Se a ULA fizer uma subtração (A - B) e o resultado for 0, significa que A == B.
    assign zero = (result == 32'd0);

    always @(*) begin
        case (alu_control)
            4'b0000: result = a & b;                       // AND / ANDI
            4'b0001: result = a | b;                       // OR / ORI
            4'b0010: result = a + b;                       // ADD / ADDI / LW / SW
            4'b0110: result = a - b;                       // SUB / BEQ / BNE
            4'b0011: result = a ^ b;                       // XOR / XORI
            4'b0100: result = a << b[4:0];                 // SLL / SLLI (Shift Left Logical)
            4'b0101: result = a >> b[4:0];                 // SRL / SRLI (Shift Right Logical)
            
            // O comando >>> (Arithmetic Shift) em Verilog requer que os números 
            // sejam tratados como "signed" para preservar o bit de sinal negativo.
            4'b0111: result = $signed(a) >>> b[4:0];       // SRA / SRAI 
            
            // SLT (Set Less Than) - Compara considerando o sinal (Signed)
            4'b1000: result = ($signed(a) < $signed(b)) ? 32'd1 : 32'd0; 
            
            // SLTU (Set Less Than Unsigned) - Compara ignorando o sinal
            4'b1001: result = (a < b) ? 32'd1 : 32'd0;
            
            // Caso de segurança (se receber sinal inválido, joga zero)
            default: result = 32'd0;
        endcase
    end

endmodule