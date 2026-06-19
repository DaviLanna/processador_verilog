// -----------------------------------------------------------------------------
// Arquivo: alu_control.v
// Estágio: Execute (EX)
// Descrição: Gera o sinal de 4 bits para comandar a ULA, baseado no ALUOp 
// e nos campos da instrução atual.
// -----------------------------------------------------------------------------

module ALUControl (
    input wire [1:0] alu_op,     // Sinal gerado pela Unidade de Controle Principal
    input wire [2:0] funct3,     // Bits [14:12] da instrução
    input wire funct7_5,         // Bit [30] da instrução (o 6º bit do funct7)
    input wire opcode_5,         // Bit [5] da instrução (diferencia R-Type de I-Type)
    
    output reg [3:0] alu_control
);

    // O bit 5 do opcode é um salva-vidas clássico:
    // Instruções R-Type (como ADD) têm opcode_5 = 1.
    // Instruções I-Type (como ADDI) têm opcode_5 = 0.
    // Combinando isso com o funct7_5, decidimos com segurança entre ADD e SUB.

    always @(*) begin
        case (alu_op)
            // 2'b00: Usado para operações de Memória (LW/SW) ou saltos puros (JAL).
            // A ULA apenas soma o endereço base com o imediato.
            2'b00: alu_control = 4'b0010; // ADD

            // 2'b01: Usado para desvios condicionais (BEQ, BNE, etc).
            // A ULA faz uma subtração. Se (A - B == 0), a flag 'zero' da ULA acende.
            2'b01: alu_control = 4'b0110; // SUB

            // 2'b10: Operações Lógicas e Aritméticas (R-Type e I-Type)
            2'b10: begin
                case (funct3)
                    3'b000: begin
                        // Se for R-Type (opcode_5=1) E o funct7 indicar subtração (funct7_5=1)
                        if (opcode_5 == 1'b1 && funct7_5 == 1'b1) 
                            alu_control = 4'b0110; // SUB
                        else 
                            alu_control = 4'b0010; // ADD / ADDI
                    end
                    3'b001: alu_control = 4'b0100; // SLL / SLLI
                    3'b010: alu_control = 4'b1000; // SLT / SLTI
                    3'b011: alu_control = 4'b1001; // SLTU / SLTIU
                    3'b100: alu_control = 4'b0011; // XOR / XORI
                    3'b101: begin
                        // Aqui também: se funct7_5 for 1, é SRA/SRAI. Se for 0, é SRL/SRLI.
                        if (funct7_5 == 1'b1)
                            alu_control = 4'b0111; // SRA / SRAI
                        else
                            alu_control = 4'b0101; // SRL / SRLI
                    end
                    3'b110: alu_control = 4'b0001; // OR / ORI
                    3'b111: alu_control = 4'b0000; // AND / ANDI
                    
                    default: alu_control = 4'b0000;
                endcase
            end
            
            default: alu_control = 4'b0000;
        endcase
    end

endmodule