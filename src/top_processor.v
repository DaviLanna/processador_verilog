// -----------------------------------------------------------------------------
// Arquivo: top_processor.v
// Descrição: Módulo principal do processador RV32I monociclo.
// Instancia e conecta os módulos dos 5 estágios lógicos:
// IF, ID, EX, MEM e WB.
// -----------------------------------------------------------------------------

module TopProcessor (

    input wire clk,
    input wire reset

);

    // =========================================================================
    // IF - INSTRUCTION FETCH
    // =========================================================================
    // Nesta etapa, o processador:
    // 1. Usa o PC para buscar a instrução atual na memória de instruções.
    // 2. Calcula PC + 4, que normalmente é o endereço da próxima instrução.
    // =========================================================================

    wire [31:0] pc_current;
    wire [31:0] pc_next;
    wire [31:0] pc_plus_4;
    wire [31:0] instruction;

    ProgramCounter PC (
        .clk(clk),
        .reset(reset),
        .pc_next(pc_next),
        .pc_out(pc_current)
    );

    PC_Adder PCAdder (
        .pc_in(pc_current),
        .pc_plus_4(pc_plus_4)
    );

    InstructionMemory InstrMem (
        .read_address(pc_current),
        .instruction(instruction)
    );

    // =========================================================================
    // CAMPOS DA INSTRUÇÃO
    // =========================================================================
    // A instrução RV32I possui 32 bits.
    // Aqui quebramos a instrução em seus campos principais:
    // opcode, rd, funct3, rs1, rs2 e funct7.
    // =========================================================================

    wire [6:0] opcode;
    wire [4:0] rd;
    wire [2:0] funct3;
    wire [4:0] rs1;
    wire [4:0] rs2;
    wire [6:0] funct7;

    assign opcode = instruction[6:0];
    assign rd     = instruction[11:7];
    assign funct3 = instruction[14:12];
    assign rs1    = instruction[19:15];
    assign rs2    = instruction[24:20];
    assign funct7 = instruction[31:25];

    // =========================================================================
    // ID - INSTRUCTION DECODE
    // =========================================================================
    // Nesta etapa, o processador:
    // 1. Decodifica a instrução usando a ControlUnit.
    // 2. Lê os registradores rs1 e rs2 no RegisterFile.
    // 3. Gera o imediato usando o ImmGen.
    // =========================================================================

    wire RegWrite;
    wire ALUSrc;
    wire MemRead;
    wire MemWrite;
    wire Branch;
    wire Jump;
    wire Jalr;

    wire [1:0] MemToReg;
    wire [1:0] ALUOp;

    wire [31:0] read_data1;
    wire [31:0] read_data2;
    wire [31:0] immediate;
    wire [31:0] write_back_data;

    ControlUnit Control (
        .opcode(opcode),
        .funct3(funct3),
        .funct7(funct7),

        .RegWrite(RegWrite),
        .ALUSrc(ALUSrc),
        .MemRead(MemRead),
        .MemWrite(MemWrite),
        .Branch(Branch),
        .Jump(Jump),
        .Jalr(Jalr),

        .MemToReg(MemToReg),
        .ALUOp(ALUOp)
    );

    RegisterFile RegFile (
        .clk(clk),
        .reg_write(RegWrite),

        .rs1(rs1),
        .rs2(rs2),
        .rd(rd),

        .write_data(write_back_data),

        .read_data1(read_data1),
        .read_data2(read_data2)
    );

    ImmGen ImmediateGenerator (
        .instruction(instruction),
        .immediate(immediate)
    );

    // =========================================================================
    // EX - EXECUTE
    // =========================================================================
    // Nesta etapa, o processador:
    // 1. Escolhe o segundo operando da ALU:
    //    - read_data2 para instruções R-Type e branches.
    //    - immediate para instruções I-Type, LW, SW e JALR.
    // 2. Usa a ALUControl para escolher a operação da ALU.
    // 3. Executa a operação na ALU.
    // =========================================================================

    wire [31:0] alu_operand_b;
    wire [31:0] alu_result;
    wire zero;
    wire [3:0] alu_control;

    assign alu_operand_b = (ALUSrc) ? immediate : read_data2;

    ALUControl ALUCtrl (
        .ALUOp(ALUOp),
        .funct3(funct3),
        .funct7(funct7),
        .alu_control(alu_control)
    );

    ALU ULA (
        .operand_a(read_data1),
        .operand_b(alu_operand_b),
        .alu_control(alu_control),
        .result(alu_result),
        .zero(zero)
    );

    // =========================================================================
    // LÓGICA DE BRANCH
    // =========================================================================
    // Aqui decidimos se um desvio condicional será tomado ou não.
    //
    // Instruções suportadas:
    // BEQ  -> desvia se rs1 == rs2
    // BNE  -> desvia se rs1 != rs2
    // BLT  -> desvia se rs1 <  rs2, com sinal
    // BGE  -> desvia se rs1 >= rs2, com sinal
    // BLTU -> desvia se rs1 <  rs2, sem sinal
    // BGEU -> desvia se rs1 >= rs2, sem sinal
    // =========================================================================

    reg branch_taken;

    always @(*) begin

        branch_taken = 1'b0;

        case (funct3)

            // BEQ
            3'b000: begin
                branch_taken = (read_data1 == read_data2);
            end

            // BNE
            3'b001: begin
                branch_taken = (read_data1 != read_data2);
            end

            // BLT
            3'b100: begin
                branch_taken = ($signed(read_data1) < $signed(read_data2));
            end

            // BGE
            3'b101: begin
                branch_taken = ($signed(read_data1) >= $signed(read_data2));
            end

            // BLTU
            3'b110: begin
                branch_taken = (read_data1 < read_data2);
            end

            // BGEU
            3'b111: begin
                branch_taken = (read_data1 >= read_data2);
            end

            default: begin
                branch_taken = 1'b0;
            end

        endcase

    end

    // =========================================================================
    // CÁLCULO DO PRÓXIMO PC
    // =========================================================================
    // Normalmente:
    //      pc_next = pc_current + 4
    //
    // Para branch tomado:
    //      pc_next = pc_current + immediate
    //
    // Para JAL:
    //      pc_next = pc_current + immediate
    //
    // Para JALR:
    //      pc_next = (rs1 + immediate) com o bit 0 zerado
    // =========================================================================

    wire [31:0] branch_target;
    wire [31:0] jump_target;
    wire [31:0] jalr_target_raw;
    wire [31:0] jalr_target;

    assign branch_target = pc_current + immediate;
    assign jump_target   = pc_current + immediate;

    assign jalr_target_raw = read_data1 + immediate;

    // No RISC-V, o endereço de destino do JALR deve ter o bit menos significativo zerado.
    assign jalr_target = {jalr_target_raw[31:1], 1'b0};

    assign pc_next = (Jump && Jalr)             ? jalr_target   :
                     (Jump)                    ? jump_target   :
                     (Branch && branch_taken)  ? branch_target :
                                                  pc_plus_4;

    // =========================================================================
    // MEM - MEMORY
    // =========================================================================
    // Nesta etapa:
    // - LW lê um dado da memória.
    // - SW escreve um dado na memória.
    //
    // O endereço da memória vem do resultado da ALU.
    // =========================================================================

    wire [31:0] data_memory_read;

    DataMemory DataMem (
        .clk(clk),

        .mem_read(MemRead),
        .mem_write(MemWrite),

        .address(alu_result),
        .write_data(read_data2),

        .read_data(data_memory_read)
    );

    // =========================================================================
    // WB - WRITE BACK
    // =========================================================================
    // Nesta etapa, escolhemos o que será escrito no registrador rd.
    //
    // MemToReg:
    // 00 -> resultado da ALU
    // 01 -> dado lido da memória
    // 10 -> PC + 4, usado em JAL e JALR
    // 11 -> imediato, usado em LUI
    // =========================================================================

    assign write_back_data = (MemToReg == 2'b00) ? alu_result        :
                             (MemToReg == 2'b01) ? data_memory_read  :
                             (MemToReg == 2'b10) ? pc_plus_4         :
                             (MemToReg == 2'b11) ? immediate         :
                                                    32'b0;

endmodule
