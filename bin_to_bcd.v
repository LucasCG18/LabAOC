module bin_to_bcd #(
    parameter BIN_WIDTH = 32,
    parameter DIGITS = 8
)(
    input  wire [BIN_WIDTH-1:0] bin,
    output wire [4*DIGITS-1:0] bcd // Agora é um vetor único de bits
);

    integer i, j;
    reg [BIN_WIDTH+4*DIGITS-1:0] shift_reg;

    always @(*) begin
        shift_reg = { {(4*DIGITS){1'b0}}, bin };
        for (i = 0; i < BIN_WIDTH; i = i + 1) begin
            for (j = 0; j < DIGITS; j = j + 1) begin
                if (shift_reg[BIN_WIDTH+4*j +: 4] >= 5)
                    shift_reg[BIN_WIDTH+4*j +: 4] = shift_reg[BIN_WIDTH+4*j +: 4] + 3;
            end
            shift_reg = shift_reg << 1;
        end
    end

    genvar d;
    generate
        for (d = 0; d < DIGITS; d = d + 1) begin : out_bcd
            assign bcd[4*(d+1)-1:4*d] = shift_reg[BIN_WIDTH+4*(DIGITS-1-d) +: 4];
        end
    endgenerate
endmodule
