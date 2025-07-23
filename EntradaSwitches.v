module EntradaSwitches (
    input  wire [17:0] switches,  // 8 switches para escolher até Fib(255)
    input  wire       clk,
    input  wire       reset,
    input  wire       start_btn, // Push button (ativo em subida)
    output reg  [31:0] n_escolhido
);
    always @(posedge clk) begin
        if (reset)
            n_escolhido <= 8'd0;
        else if (!start_btn) // Enquanto não apertou, atualiza
            n_escolhido <= {14'd0, switches};
        // Ao pressionar start, mantém valor
    end
endmodule
