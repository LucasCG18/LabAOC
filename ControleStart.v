module ControleStart (
    input  wire clk,
    input  wire reset,
    input  wire start_btn,
    output reg  started
);
    reg last_btn;
    always @(posedge clk) begin
        if (reset) begin
            started  <= 1'b0;
            last_btn <= 1'b0;
        end else begin
            // Detecção de borda de subida (push)
            if (~last_btn & start_btn)
                started <= 1'b1;
            last_btn <= start_btn;
        end
    end
endmodule
