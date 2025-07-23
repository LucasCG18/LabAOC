module ula(
    input  [31:0] A,
    input  [31:0] B,
    input  [3:0]  ALU_operacao,
    output reg    zero,
    output reg    less,
    output reg    less_unsigned,
    output reg [31:0] result
);
    always @(*) begin
        case (ALU_operacao)
            4'b0000: result = A + B;                          // ADD / (também usado para LUI=0+imm, AUIPC=PC+imm)
            4'b0001: result = A - B;                          // SUB (usado em branch para comparar igualdade)
            4'b0010: result = A & B;                          // AND
            4'b0011: result = A | B;                          // OR
            4'b0100: result = A ^ B;                          // XOR
            4'b0101: result = A << B[4:0];                    // SLL
            4'b0110: result = A >> B[4:0];                    // SRL
            4'b0111: result = $signed(A) >>> B[4:0];          // SRA
            4'b1000: result = ($signed(A) < $signed(B)) ? 
                              32'd1 : 32'd0;                  // SLT  (set-on-less-than signed)
            4'b1001: result = (A < B) ? 32'd1 : 32'd0;        // SLTU (set-on-less-than unsigned)
            default: result = 32'd0;
        endcase
        // Sinais de status
        zero          = (result == 32'd0);
        less          = ($signed(A) < $signed(B));
        less_unsigned = (A < B);
    end
endmodule
