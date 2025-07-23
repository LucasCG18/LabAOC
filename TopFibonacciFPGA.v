module TopFibonacciFPGA (
    input  wire        G_CLOCK_50,          // CLOCK_50
    input  wire [3:0]  V_BT,
    input  wire [17:0]  V_SW,     // SW[7:0]

    // ─── 56 saídas: a..g de cada dígito (cátodo comum) ───
    output wire [6:0] G_HEX1,
    output wire [6:0] G_HEX2,
    output wire [6:0] G_HEX3,
    output wire [6:0] G_HEX4,
    output wire [6:0] G_HEX5,
    output wire [6:0] G_HEX6,
    output wire [6:0] G_HEX7,
    output wire [6:0] G_HEX0,
    output wire [17:0] G_LED
);
    // ─────────────────── Entradas (switches + botão) ──────────────
    
    
    // ---- Divisor de 50 MHz para 1 Hz ---------------------------------
    reg [25:0] counter      = 26'd0;   // 26 bits alcançam até 67 108 864
    reg        clk_1hz_pulse = 1'b0;
    
    always @(posedge G_CLOCK_50 or negedge V_BT[1]) begin
        if (~V_BT[1]) begin                 // reset assíncrono (botão)
            counter        <= 26'd0;
            clk_1hz_pulse  <= 1'b0;
        end else if (counter == 26'd999) begin
            counter        <= 26'd0;
            clk_1hz_pulse  <= ~clk_1hz_pulse;  // troca a cada 1 s → onda quadrada 0,5 Hz
        end else begin
            counter <= counter + 1'b1;
        end
    end


    
    wire [7:0] n_escolhido;
    EntradaSwitches entrada (
        .switches    (V_SW),
        .clk         (clk_1hz_pulse),
        .reset       (~V_BT[1]),
        .start_btn   (~V_BT[0]),
        .n_escolhido (n_escolhido)
    );

    wire started;
    ControleStart ctrl_start (
        .clk       (clk_1hz_pulse),
        .reset     (~V_BT[1]),
        .start_btn (~V_BT[0]),
        .started   (started)
    );

    // ─────────────────── CPU / núcleo de Fibonacci ───────────────
    wire [31:0] resultado_fibo;
    wire flagzero;
    CPU cpu (
        .clk           (clk_1hz_pulse),
        .reset         (~V_BT[1]),
        .n (n_escolhido),
        .started (started),
        .resultado_fibo(resultado_fibo),
        .flagzero(flagzero)
    );

    // ─────────────── Seleciona valor a exibir (N ou Fib) ──────────
    wire [31:0] valor_display;
    DisplaySelector disp_sel (
        .resultado_fibo (resultado_fibo),
        .n_escolhido    (n_escolhido),
        .started        (started),
        .valor_display  (valor_display)
    );

    // ────────────────── Driver sem multiplexação ──────────────────
    wire [6:0] seg0, seg1, seg2, seg3, seg4, seg5, seg6, seg7;

    Display7segFlat display_flat (
        .valor(resultado_fibo), // Expande para 32 bits (14 zeros + 18 bits do V_SW)
        .seg0(seg0),
        .seg1(seg1),
        .seg2(seg2),
        .seg3(seg3),
        .seg4(seg4),
        .seg5(seg5),
        .seg6(seg6),
        .seg7(seg7)
    );

    // Cada saída vai para um display
    assign G_HEX7 = seg0; // Menos significativo (unidade)
    assign G_HEX6 = seg1;
    assign G_HEX5 = seg2;
    assign G_HEX4 = seg3;
    assign G_HEX3 = seg4;
    assign G_HEX2 = seg5;
    assign G_HEX1 = seg6;
    assign G_HEX0 = seg7; // Mais significativo
    
    assign G_LED[17] = ~V_BT[0];
    assign G_LED[16] = ~V_BT[1];
    assign G_LED[15] = started;
    assign G_LED[14] = clk_1hz_pulse;
    assign G_LED[13] = flagzero;
    assign G_LED[12] = ~flagzero;
    
endmodule
