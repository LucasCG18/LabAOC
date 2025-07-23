module MemoriaDeInstrucao(
    input  [31:0] endereco,  // byte address, usa [31:2] internamente
    input         reset,
    output [31:0] instrucao
);
    reg [31:0] Memoria [0:50];

    // Inicialização para simulação e FPGA (use .hex/.mif para inicializar o conteúdo)
    initial $readmemh("programa.hex", Memoria);

    // ROM: leitura combinacional (aceita em FPGA)
    assign instrucao = (reset == 1'b1) ? 32'h00000000 : Memoria[endereco[31:2]];
endmodule
