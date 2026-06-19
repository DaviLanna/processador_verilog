// -----------------------------------------------------------------------------
// Arquivo: alu_control.v
// Estágio: Execute (EX)
// Descrição: Unidade de Controle da ALU.
// Traduz os sinais ALUOp, funct3 e funct7 em um código de controle para a ALU.
// -----------------------------------------------------------------------------

module ALUControl (

    input wire [1:0] ALUOp,
    input wire [2:0] funct3,
    input wire [6:0] funct7,

    output reg [3:0] alu_control

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

        case (ALUOp)

            // -------------------------------------------------------------
            // 00 -> Operações que usam soma
            // LW, SW, JALR
            // -------------------------------------------------------------
            2'b00: begin
                alu_control = 4'b0000; // ADD
            end

            // -------------------------------------------------------------
            // 01 -> Branch
            // BEQ, BNE, BLT, BGE, BLTU, BGEU
            // O top_processor já trata a comparação dos branches,
            // então aqui deixamos um valor padrão útil.
            // -------------------------------------------------------------
            2'b01: begin
                case (funct3)

                    3'b000: alu_control = 4'b0001; // BEQ  -> SUB
                    3'b001: alu_control = 4'b0001; // BNE  -> SUB
                    3'b100: alu_control = 4'b0011; // BLT  -> SLT
                    3'b101: alu_control = 4'b0011; // BGE  -> SLT
                    3'b110: alu_control = 4'b0100; // BLTU -> SLTU
                    3'b111: alu_control = 4'b0100; // BGEU -> SLTU

                    default: alu_control = 4'b0001; // SUB
                endcase
            end

            // -------------------------------------------------------------
            // 10 -> R-Type
            // ADD, SUB, SLL, SLT, SLTU, XOR, SRL, SRA, OR, AND
            // -------------------------------------------------------------
            2'b10: begin
                case (funct3)

                    3'b000: begin
                        if (funct7 == 7'b0100000)
                            alu_control = 4'b0001; // SUB
                        else
                            alu_control = 4'b0000; // ADD
                    end

                    3'b001: alu_control = 4'b0010; // SLL
                    3'b010: alu_control = 4'b0011; // SLT
                    3'b011: alu_control = 4'b0100; // SLTU
                    3'b100: alu_control = 4'b0101; // XOR

                    3'b101: begin
                        if (funct7 == 7'b0100000)
                            alu_control = 4'b0111; // SRA
                        else
                            alu_control = 4'b0110; // SRL
                    end

                    3'b110: alu_control = 4'b1000; // OR
                    3'b111: alu_control = 4'b1001; // AND

                    default: alu_control = 4'b0000; // ADD
                endcase
            end

            // -------------------------------------------------------------
            // 11 -> I-Type aritmético/lógico
            // ADDI, SLTI, SLTIU, XORI, ORI, ANDI, SLLI, SRLI, SRAI
            // -------------------------------------------------------------
            2'b11: begin
                case (funct3)

                    3'b000: alu_control = 4'b0000; // ADDI
                    3'b001: alu_control = 4'b0010; // SLLI
                    3'b010: alu_control = 4'b0011; // SLTI
                    3'b011: alu_control = 4'b0100; // SLTIU
                    3'b100: alu_control = 4'b0101; // XORI

                    3'b101: begin
                        if (funct7 == 7'b0100000)
                            alu_control = 4'b0111; // SRAI
                        else
                            alu_control = 4'b0110; // SRLI
                    end

                    3'b110: alu_control = 4'b1000; // ORI
                    3'b111: alu_control = 4'b1001; // ANDI

                    default: alu_control = 4'b0000; // ADD
                endcase
            end

            // -------------------------------------------------------------
            // Caso padrão
            // -------------------------------------------------------------
            default: begin
                alu_control = 4'b0000; // ADD
            end

        endcase

    end

endmodule