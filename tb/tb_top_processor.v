// -----------------------------------------------------------------------------
// Arquivo: tb_top_processor.v
// Descrição: Testbench do processador RV32I monociclo.
// Responsável por gerar clock/reset, executar o processador e salvar waveforms.
// -----------------------------------------------------------------------------

`timescale 1ns / 1ps

module tb_top_processor;

    // -------------------------------------------------------------------------
    // Sinais do Testbench
    // -------------------------------------------------------------------------

    reg clk;
    reg reset;

    // -------------------------------------------------------------------------
    // Instância do processador
    // -------------------------------------------------------------------------

    TopProcessor DUT (
        .clk(clk),
        .reset(reset)
    );

    // -------------------------------------------------------------------------
    // Geração do clock
    // -------------------------------------------------------------------------
    // Clock com período de 10 ns:
    // 5 ns em 0 e 5 ns em 1.
    // -------------------------------------------------------------------------

    initial begin
        clk = 1'b0;
        forever #5 clk = ~clk;
    end

    // -------------------------------------------------------------------------
    // Sequência principal da simulação
    // -------------------------------------------------------------------------

    initial begin

        // Gera arquivo de waveform para abrir no GTKWave/ModelSim/Vivado
        $dumpfile("waveform.vcd");
        $dumpvars(0, tb_top_processor);

        // Mensagem inicial
        $display("==============================================");
        $display(" Iniciando simulacao do Processador RV32I");
        $display("==============================================");

        // Reset inicial
        reset = 1'b1;
        #20;
        reset = 1'b0;

        // Tempo de execução da simulação
        // Aumente esse valor se o programa em asm/instrucoes.hex for maior.
        #1000;

        // Mostra alguns registradores no final da simulação
        $display("==============================================");
        $display(" Estado final dos registradores");
        $display("==============================================");

        $display("x0  = %h", DUT.RegFile.registers[0]);
        $display("x1  = %h", DUT.RegFile.registers[1]);
        $display("x2  = %h", DUT.RegFile.registers[2]);
        $display("x3  = %h", DUT.RegFile.registers[3]);
        $display("x4  = %h", DUT.RegFile.registers[4]);
        $display("x5  = %h", DUT.RegFile.registers[5]);
        $display("x6  = %h", DUT.RegFile.registers[6]);
        $display("x7  = %h", DUT.RegFile.registers[7]);
        $display("x8  = %h", DUT.RegFile.registers[8]);
        $display("x9  = %h", DUT.RegFile.registers[9]);
        $display("x10 = %h", DUT.RegFile.registers[10]);
        $display("x11 = %h", DUT.RegFile.registers[11]);
        $display("x12 = %h", DUT.RegFile.registers[12]);
        $display("x13 = %h", DUT.RegFile.registers[13]);
        $display("x14 = %h", DUT.RegFile.registers[14]);
        $display("x15 = %h", DUT.RegFile.registers[15]);

        $display("==============================================");
        $display(" Estado final da memoria de dados");
        $display("==============================================");

        $display("mem[0] = %h", DUT.DataMem.memory[0]);
        $display("mem[1] = %h", DUT.DataMem.memory[1]);
        $display("mem[2] = %h", DUT.DataMem.memory[2]);
        $display("mem[3] = %h", DUT.DataMem.memory[3]);

        $display("==============================================");
        $display(" Simulacao finalizada");
        $display("==============================================");

        $finish;

    end

    // -------------------------------------------------------------------------
    // Monitoramento durante a simulação
    // -------------------------------------------------------------------------
    // A cada borda de subida do clock, mostra informações importantes:
    // PC atual, instrução, resultado da ALU e dado de write-back.
    // -------------------------------------------------------------------------

    always @(posedge clk) begin

        if (!reset) begin
            $display("Tempo=%0t | PC=%h | Instrucao=%h | ALU=%h | WB=%h",
                     $time,
                     DUT.pc_current,
                     DUT.instruction,
                     DUT.alu_result,
                     DUT.write_back_data);
        end

    end

endmodule