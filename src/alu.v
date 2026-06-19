// -----------------------------------------------------------------------------
// Arquivo: alu.v
// Estágio: Execute (EX)
// Descrição: Unidade Lógica e Aritmética (ALU) do processador RV32I.
// Executa operações aritméticas, lógicas, comparações e deslocamentos.
// -----------------------------------------------------------------------------

module ALU (

    input wire [31:0] operand_a,
    input wire [31:0] operand_b,

    // Código da operação que a ALU deve executar
    input wire [3:0] alu_control,

    output reg [31:0] result,
    output wire zero

);

    // -------------------------------------------------------------------------
    // Códigos de operação da ALU
    // -------------------------------------------------------------------------
    // 0000 -> ADD
    // 0001 -> SUB
    // 0010 -> SLL
    // 0011 -> SLT
    // 0100 -> SLTU
    // 0101 -> XOR
    // 0110 -> SRL
    // 0111 -> SRA
    // 1000 -> OR
    // 1001 -> AND
    // -------------------------------------------------------------------------

    always @(*) begin

        case (alu_control)

            // ADD
            // Usado por ADD, ADDI, LW, SW e cálculo de endereço
            4'b0000: begin
                result = operand_a + operand_b;
            end

            // SUB
            // Usado por SUB e pode auxiliar em comparações
            4'b0001: begin
                result = operand_a - operand_b;
            end

            // SLL - Shift Left Logical
            // Desloca operand_a para a esquerda
            4'b0010: begin
                result = operand_a << operand_b[4:0];
            end

            // SLT - Set Less Than com sinal
            // Retorna 1 se operand_a < operand_b considerando sinal
            4'b0011: begin
                result = ($signed(operand_a) < $signed(operand_b)) ? 32'd1 : 32'd0;
            end

            // SLTU - Set Less Than Unsigned
            // Retorna 1 se operand_a < operand_b sem considerar sinal
            4'b0100: begin
                result = (operand_a < operand_b) ? 32'd1 : 32'd0;
            end

            // XOR
            4'b0101: begin
                result = operand_a ^ operand_b;
            end

            // SRL - Shift Right Logical
            // Desloca operand_a para a direita preenchendo com zeros
            4'b0110: begin
                result = operand_a >> operand_b[4:0];
            end

            // SRA - Shift Right Arithmetic
            // Desloca operand_a para a direita preservando o bit de sinal
            4'b0111: begin
                result = $signed(operand_a) >>> operand_b[4:0];
            end

            // OR
            4'b1000: begin
                result = operand_a | operand_b;
            end

            // AND
            4'b1001: begin
                result = operand_a & operand_b;
            end

            // Caso padrão
            default: begin
                result = 32'b0;
            end

        endcase

    end

    // Sinal zero fica ativo quando o resultado da ALU é zero
    assign zero = (result == 32'b0);

endmodule
