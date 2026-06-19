// -----------------------------------------------------------------------------
// Arquivo: imm_gen.v
// Estágio: Instruction Decode (ID)
// Descrição: Unidade de Extensão de Imediatos (ImmGen).
// Extrai e estende para 32 bits os valores imediatos dos formatos:
// I-Type, S-Type, B-Type, U-Type e J-Type.
// -----------------------------------------------------------------------------

module ImmGen (

    input wire [31:0] instruction,
    output reg [31:0] immediate

);

    // Campo opcode da instrução
    wire [6:0] opcode;

    assign opcode = instruction[6:0];

    always @(*) begin

        case (opcode)

            // -------------------------------------------------------------
            // I-Type
            // ADDI, SLTI, SLTIU, XORI, ORI, ANDI
            // SLLI, SRLI, SRAI
            // LW
            // JALR
            // -------------------------------------------------------------
            7'b0010011, // Immediate Arithmetic
            7'b0000011, // LW
            7'b1100111: // JALR
            begin
                immediate = {{20{instruction[31]}},
                             instruction[31:20]};
            end

            // -------------------------------------------------------------
            // S-Type
            // SW
            // -------------------------------------------------------------
            7'b0100011:
            begin
                immediate = {{20{instruction[31]}},
                             instruction[31:25],
                             instruction[11:7]};
            end

            // -------------------------------------------------------------
            // B-Type
            // BEQ, BNE, BLT, BGE, BLTU, BGEU
            // -------------------------------------------------------------
            7'b1100011:
            begin
                immediate = {{19{instruction[31]}},
                             instruction[31],
                             instruction[7],
                             instruction[30:25],
                             instruction[11:8],
                             1'b0};
            end

            // -------------------------------------------------------------
            // U-Type
            // LUI
            // -------------------------------------------------------------
            7'b0110111:
            begin
                immediate = {instruction[31:12],
                             12'b0};
            end

            // -------------------------------------------------------------
            // J-Type
            // JAL
            // -------------------------------------------------------------
            7'b1101111:
            begin
                immediate = {{11{instruction[31]}},
                             instruction[31],
                             instruction[19:12],
                             instruction[20],
                             instruction[30:21],
                             1'b0};
            end

            // -------------------------------------------------------------
            // Caso padrão
            // -------------------------------------------------------------
            default:
            begin
                immediate = 32'b0;
            end

        endcase

    end

endmodule