module BancoDeRegistradores(
    input wire clk,
    input wire reset,               // Reset síncrono (irá apenas no clock)
    input wire reg_write,
    input wire [4:0] rs1,
    input wire [4:0] rs2,
    input wire [4:0] write_register,
    input wire [31:0] write_data,
    output wire [31:0] read_data_1,
    output wire [31:0] read_data_2
);
    reg [31:0] Registradores [0:31];

    // Inicialização opcional para simulação:
    // initial for (integer j = 0; j < 32; j = j + 1) Registradores[j] = 0;
    // ou: initial $readmemh("regs.hex", Registradores);

    // Leitura combinacional
    assign read_data_1 = (rs1 == 5'd0) ? 32'b0 : Registradores[rs1];
    assign read_data_2 = (rs2 == 5'd0) ? 32'b0 : Registradores[rs2];

    always @(posedge clk) begin
        if (reset) begin
            // **ATENÇÃO:** este bloco só zera em simulação, não em hardware real!
            // Em hardware real, os registradores podem vir indefinidos após power-on.
            // for (i = 0; i < 32; i = i + 1) begin
            //     Registradores[i] <= 32'b0;
            // end
            // Para hardware real, ignore este bloco ou use arquivo de init.
        end else if (reg_write && write_register != 5'd0) begin
            Registradores[write_register] <= write_data;
        end
    end
endmodule
