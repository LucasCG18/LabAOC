module Divisorf (G_CLOCK_50, G_HEX1, V_SW);
    input G_CLOCK_50;
    input [0:17]V_SW;       
    reg S;
    output [0:6] G_HEX1; 
    parameter DIV_COUNT = 50000000;
    reg [3:0] te = 4'b0000;
    reg [31:0] OUT;
    reg [6:0] segmentos;
    always @(posedge G_CLOCK_50) begin
        if (V_SW[0] == 1'b1) begin
            te <= 4'b0000;
        end
        if (OUT == DIV_COUNT) begin
            OUT <= 32'd0;
            S <= 1'b1;
        end
        else begin
            OUT <= OUT + 1;
            S <= 1'b0;
        end
        if(S == 1'b1)begin
            if(te == 4'b1001)
                te <= 4'b0000;
            else
                te <= te + 1;
        end
    end
    always @(*) begin
        case (te)
            4'b0000: segmentos = 7'b0000001;
            4'b0001: segmentos = 7'b1001111;
            4'b0010: segmentos = 7'b0010010;
            4'b0011: segmentos = 7'b0000110;
            4'b0100: segmentos = 7'b1001100;
            4'b0101: segmentos = 7'b0100100;
            4'b0110: segmentos = 7'b0100000;
            4'b0111: segmentos = 7'b0001111;
            4'b1000: segmentos = 7'b0000000;
            4'b1001: segmentos = 7'b0000100;
            default: segmentos = 7'b1111111;
        endcase
    end
endmodule
