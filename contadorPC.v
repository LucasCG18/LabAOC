module contadorPC(
    input [31:0] PC_atual,
    output [31:0] PC_mais_1
    );
     assign PC_mais_1 = PC_atual + 32'd4;
endmodule