module Display7segFlat #(
    parameter COMMON_ANODE = 0
)(
    input  wire [31:0] valor,
    output wire [6:0] seg0,
    output wire [6:0] seg1,
    output wire [6:0] seg2,
    output wire [6:0] seg3,
    output wire [6:0] seg4,
    output wire [6:0] seg5,
    output wire [6:0] seg6,
    output wire [6:0] seg7
);

    wire [31:0] bcd_digits;
    bin_to_bcd #(.BIN_WIDTH(32), .DIGITS(8)) b2bcd (
        .bin(valor),
        .bcd(bcd_digits)
    );

    function [6:0] dec2seg(input [3:0] n);
        case (n)
            4'd0: dec2seg = 7'b1000000;
            4'd1: dec2seg = 7'b1111001;
            4'd2: dec2seg = 7'b0100100;
            4'd3: dec2seg = 7'b0110000;
            4'd4: dec2seg = 7'b0011001;
            4'd5: dec2seg = 7'b0010010;
            4'd6: dec2seg = 7'b0000010;
            4'd7: dec2seg = 7'b1111000;
            4'd8: dec2seg = 7'b0000000;
            4'd9: dec2seg = 7'b0010000;
            default: dec2seg = 7'b1111111;
        endcase
    endfunction

    wire [3:0] digit0 = bcd_digits[3:0];
    wire [3:0] digit1 = bcd_digits[7:4];
    wire [3:0] digit2 = bcd_digits[11:8];
    wire [3:0] digit3 = bcd_digits[15:12];
    wire [3:0] digit4 = bcd_digits[19:16];
    wire [3:0] digit5 = bcd_digits[23:20];
    wire [3:0] digit6 = bcd_digits[27:24];
    wire [3:0] digit7 = bcd_digits[31:28];

    assign seg0 = COMMON_ANODE ? ~dec2seg(digit0) : dec2seg(digit0);
    assign seg1 = COMMON_ANODE ? ~dec2seg(digit1) : dec2seg(digit1);
    assign seg2 = COMMON_ANODE ? ~dec2seg(digit2) : dec2seg(digit2);
    assign seg3 = COMMON_ANODE ? ~dec2seg(digit3) : dec2seg(digit3);
    assign seg4 = COMMON_ANODE ? ~dec2seg(digit4) : dec2seg(digit4);
    assign seg5 = COMMON_ANODE ? ~dec2seg(digit5) : dec2seg(digit5);
    assign seg6 = COMMON_ANODE ? ~dec2seg(digit6) : dec2seg(digit6);
    assign seg7 = COMMON_ANODE ? ~dec2seg(digit7) : dec2seg(digit7);

endmodule
