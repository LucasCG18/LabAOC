module DisplaySelector (
    input  wire [31:0] resultado_fibo,
    input  wire [7:0]  n_escolhido,
    input  wire        started,
    output wire [31:0] valor_display
);
    assign valor_display = started ? resultado_fibo : {24'd0, n_escolhido};
endmodule
