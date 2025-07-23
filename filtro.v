module filtro (V_BT, S);
    input [0:5]V_BT;
    output reg [2:0] S;

    always @(posedge V_BT[3]) begin
        if (S[0] == 0) begin
            S[0] <= 1;
        end
        if ((S[0] == 1) && (S[1] == 0)) begin
            S[1] <= 1;
        end
        if ((S[0] == 1) && (S[1] == 1) && (S[2] == 0)) begin
            S[2] <= 1;
        end
    end
endmodule
