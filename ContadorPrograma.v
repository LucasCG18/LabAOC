module ContadorPrograma(
    input [31:0] PC_next,
    input clk, reset,
    output reg [31:0] PC
    );

    always @(posedge clk or posedge reset)
    begin
        if (reset == 1'b1)
            PC <= 32'h00000000;
        else
            PC <= PC_next;
    end

endmodule
