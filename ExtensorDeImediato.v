module ExtensorDeImediato(
    input wire [31:0] instrucao,
    input wire [2:0] ImmSel,      // 000=I, 001=S, 010=B, 011=U, 100=J
    output reg [31:0] ImmExt
);
    always @(*) begin
        case (ImmSel)
            3'b000: ImmExt = {{20{instrucao[31]}}, instrucao[31:20]};                         // I-type
            3'b001: ImmExt = {{20{instrucao[31]}}, instrucao[31:25], instrucao[11:7]};         // S-type
            3'b010: ImmExt = {{19{instrucao[31]}}, instrucao[31], instrucao[7], 
                                instrucao[30:25], instrucao[11:8], 1'b0};                     // B-type
            3'b011: ImmExt = {instrucao[31:12], 12'b0};                                       // U-type
            3'b100: ImmExt = {{11{instrucao[31]}}, instrucao[31], instrucao[19:12], 
                                instrucao[20], instrucao[30:21], 1'b0};                       // J-type
            default: ImmExt = 32'b0;
        endcase
    end
endmodule
