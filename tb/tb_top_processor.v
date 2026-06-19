`timescale 1ns / 1ps

// Gera o clock e avalia o top_processor.v
module tb_top_processor();
    reg clk;
    reg reset;

    // Instanciar o processador
    top_processor dut (
        .clk(clk),
        .reset(reset)
    );

    // Geração do clock
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    // Teste
    initial begin
        reset = 1;
        #10;
        reset = 0;
        
        // TODO: Adicionar verificações
        
        #1000;
        $finish;
    end
endmodule
