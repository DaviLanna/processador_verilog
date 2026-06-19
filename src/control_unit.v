// -----------------------------------------------------------------------------
// Arquivo: control_unit.v
// Estágio: Instruction Decode (ID)
// Descrição: Unidade de Controle principal do processador RV32I monociclo.
// Gera os sinais de controle a partir do opcode da instrução.
// -----------------------------------------------------------------------------

module ControlUnit (

    input wire [6:0] opcode,
    input wire [2:0] funct3,
    input wire [6:0] funct7,

    // Sinais principais de controle
    output reg RegWrite,
    output reg ALUSrc,
    output reg MemRead,
    output reg MemWrite,
    output reg Branch,
    output reg Jump,
    output reg Jalr,

    // MemToReg:
    // 00 -> Resultado da ALU
    // 01 -> Dado vindo da Memória de Dados
    // 10 -> PC + 4, usado em JAL e JALR
    // 11 -> Imediato, usado em LUI
    output reg [1:0] MemToReg,

    // ALUOp:
    // 00 -> Soma padrão, usada em LW, SW, JALR
    // 01 -> Branch
    // 10 -> R-Type
    // 11 -> I-Type aritmético/lógico
    output reg [1:0] ALUOp

);

    always @(*) begin

        // ---------------------------------------------------------------------
        // Valores padrão
        // ---------------------------------------------------------------------
        // Começamos tudo desligado para evitar latches.
        // Depois, dentro do case, ligamos apenas o que cada instrução precisa.
        // ---------------------------------------------------------------------

        RegWrite = 1'b0;
        ALUSrc   = 1'b0;
        MemRead  = 1'b0;
        MemWrite = 1'b0;
        Branch   = 1'b0;
        Jump     = 1'b0;
        Jalr     = 1'b0;
        MemToReg = 2'b00;
        ALUOp    = 2'b00;

        case (opcode)

            // -------------------------------------------------------------
            // R-Type
            // ADD, SUB, SLL, SLT, SLTU, XOR, SRL, SRA, OR, AND
            // opcode = 0110011
            // -------------------------------------------------------------
            7'b0110011: begin
                RegWrite = 1'b1;  // Escreve o resultado no registrador rd
                ALUSrc   = 1'b0;  // Segundo operando vem de rs2
                MemRead  = 1'b0;  // Não lê memória
                MemWrite = 1'b0;  // Não escreve memória
                Branch   = 1'b0;  // Não é desvio condicional
                Jump     = 1'b0;  // Não é salto
                Jalr     = 1'b0;
                MemToReg = 2'b00; // Escreve resultado da ALU
                ALUOp    = 2'b10; // Operação R-Type
            end

            // -------------------------------------------------------------
            // I-Type aritmético/lógico
            // ADDI, SLTI, SLTIU, XORI, ORI, ANDI, SLLI, SRLI, SRAI
            // opcode = 0010011
            // -------------------------------------------------------------
            7'b0010011: begin
                RegWrite = 1'b1;  // Escreve em rd
                ALUSrc   = 1'b1;  // Segundo operando vem do imediato
                MemRead  = 1'b0;
                MemWrite = 1'b0;
                Branch   = 1'b0;
                Jump     = 1'b0;
                Jalr     = 1'b0;
                MemToReg = 2'b00; // Escreve resultado da ALU
                ALUOp    = 2'b11; // Operação I-Type
            end

            // -------------------------------------------------------------
            // LW - Load Word
            // opcode = 0000011
            // -------------------------------------------------------------
            7'b0000011: begin
                RegWrite = 1'b1;  // Escreve o dado lido em rd
                ALUSrc   = 1'b1;  // Usa imediato para calcular endereço
                MemRead  = 1'b1;  // Lê memória de dados
                MemWrite = 1'b0;
                Branch   = 1'b0;
                Jump     = 1'b0;
                Jalr     = 1'b0;
                MemToReg = 2'b01; // Escreve dado vindo da memória
                ALUOp    = 2'b00; // ALU faz soma para calcular endereço
            end

            // -------------------------------------------------------------
            // SW - Store Word
            // opcode = 0100011
            // -------------------------------------------------------------
            7'b0100011: begin
                RegWrite = 1'b0;  // Não escreve em registrador
                ALUSrc   = 1'b1;  // Usa imediato para calcular endereço
                MemRead  = 1'b0;
                MemWrite = 1'b1;  // Escreve na memória de dados
                Branch   = 1'b0;
                Jump     = 1'b0;
                Jalr     = 1'b0;
                MemToReg = 2'b00;
                ALUOp    = 2'b00; // ALU faz soma para calcular endereço
            end

            // -------------------------------------------------------------
            // B-Type
            // BEQ, BNE, BLT, BGE, BLTU, BGEU
            // opcode = 1100011
            // -------------------------------------------------------------
            7'b1100011: begin
                RegWrite = 1'b0;  // Branch não escreve em registrador
                ALUSrc   = 1'b0;  // Compara rs1 com rs2
                MemRead  = 1'b0;
                MemWrite = 1'b0;
                Branch   = 1'b1;  // Ativa lógica de desvio
                Jump     = 1'b0;
                Jalr     = 1'b0;
                MemToReg = 2'b00;
                ALUOp    = 2'b01; // Operação de branch
            end

            // -------------------------------------------------------------
            // JAL - Jump and Link
            // opcode = 1101111
            // -------------------------------------------------------------
            7'b1101111: begin
                RegWrite = 1'b1;  // Escreve PC + 4 em rd
                ALUSrc   = 1'b0;
                MemRead  = 1'b0;
                MemWrite = 1'b0;
                Branch   = 1'b0;
                Jump     = 1'b1;  // Ativa salto
                Jalr     = 1'b0;  // Não é JALR
                MemToReg = 2'b10; // Escreve PC + 4
                ALUOp    = 2'b00;
            end

            // -------------------------------------------------------------
            // JALR - Jump and Link Register
            // opcode = 1100111
            // -------------------------------------------------------------
            7'b1100111: begin
                RegWrite = 1'b1;  // Escreve PC + 4 em rd
                ALUSrc   = 1'b1;  // Usa imediato com rs1 para calcular destino
                MemRead  = 1'b0;
                MemWrite = 1'b0;
                Branch   = 1'b0;
                Jump     = 1'b1;  // Ativa salto
                Jalr     = 1'b1;  // Indica que o salto é JALR
                MemToReg = 2'b10; // Escreve PC + 4
                ALUOp    = 2'b00; // Soma rs1 + imediato
            end

            // -------------------------------------------------------------
            // LUI - Load Upper Immediate
            // opcode = 0110111
            // -------------------------------------------------------------
            7'b0110111: begin
                RegWrite = 1'b1;  // Escreve imediato em rd
                ALUSrc   = 1'b1;
                MemRead  = 1'b0;
                MemWrite = 1'b0;
                Branch   = 1'b0;
                Jump     = 1'b0;
                Jalr     = 1'b0;
                MemToReg = 2'b11; // Escreve o imediato gerado pelo ImmGen
                ALUOp    = 2'b00;
            end

            // -------------------------------------------------------------
            // Caso padrão
            // -------------------------------------------------------------
            default: begin
                RegWrite = 1'b0;
                ALUSrc   = 1'b0;
                MemRead  = 1'b0;
                MemWrite = 1'b0;
                Branch   = 1'b0;
                Jump     = 1'b0;
                Jalr     = 1'b0;
                MemToReg = 2'b00;
                ALUOp    = 2'b00;
            end

        endcase

    end

endmodule