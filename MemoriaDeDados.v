// -----------------------------------------------------------------------------
// MemoriaDeDados.v (VERSÃO CORRIGIDA)
// -----------------------------------------------------------------------------
module MemoriaDeDados #(
    parameter DATA_WIDTH = 32,
    parameter ADDR_WIDTH = 10,
    parameter DEPTH = 50
)(
    input               clk,
    input               mem_write,
    input               mem_read,
    input       [1:0]   store_size,
    input       [1:0]   load_size,
    input               load_unsigned,
    input       [31:0]  endereco,
    input       [31:0]  write_data,
    input  wire         preload,
    input  wire [31:0]  n_in,
    output reg  [31:0]  read_data,
    output wire [31:0]  tap_addr1
);

    // Declaração da RAM
    reg [DATA_WIDTH-1:0] mem [0:DEPTH-1];

    // Tap sincronizado para o display
    reg [31:0] tap_reg;
    assign tap_addr1 = tap_reg;

    // --- LÓGICA DE ESCRITA SÍNCRONA ---
    // A escrita continua na borda de subida do clock
    always @(posedge clk) begin
        mem[0] <= n_in;
        //mem[0] <= 32'd10; 
        tap_reg <= mem[10];
        if (mem_write) begin
            case (store_size)
                2'b00:  // SB
                    mem[endereco[ADDR_WIDTH-1:2]][(endereco[1:0]*8)+:8] <= write_data[7:0];
                2'b01:  // SH
                    mem[endereco[ADDR_WIDTH-1:2]][(endereco[1]*16)+:16] <= write_data[15:0];
                default: // SW
                    mem[endereco[ADDR_WIDTH-1:2]] <= write_data;
            endcase
        end
    end
    // --- LÓGICA DE LEITURA SÍNCRONA ---
    // A leitura agora é sincronizada com o clock
    always @(posedge clk) begin
        // Valor padrão para evitar latches
        read_data <= 32'b0;

        if (mem_read) begin
            // Leitura da palavra inteira da memória
            case (load_size)
                2'b00: begin // LB / LBU
                    case (endereco[1:0])
                        2'b00:   read_data <= load_unsigned ? {24'b0, mem[endereco[ADDR_WIDTH-1:2]][7:0]} : {{24{mem[endereco[ADDR_WIDTH-1:2]][7]}}, mem[endereco[ADDR_WIDTH-1:2]][7:0]};
                        2'b01:   read_data <= load_unsigned ? {24'b0, mem[endereco[ADDR_WIDTH-1:2]][15:8]} : {{24{mem[endereco[ADDR_WIDTH-1:2]][15]}}, mem[endereco[ADDR_WIDTH-1:2]][15:8]};
                        2'b10:   read_data <= load_unsigned ? {24'b0, mem[endereco[ADDR_WIDTH-1:2]][23:16]} : {{24{mem[endereco[ADDR_WIDTH-1:2]][23]}}, mem[endereco[ADDR_WIDTH-1:2]][23:16]};
                        default: read_data <= load_unsigned ? {24'b0, mem[endereco[ADDR_WIDTH-1:2]][31:24]} : {{24{mem[endereco[ADDR_WIDTH-1:2]][31]}}, mem[endereco[ADDR_WIDTH-1:2]][31:24]};
                    endcase
                end
                2'b01: begin // LH / LHU
                    case (endereco[1])
                        1'b0:    read_data <= load_unsigned ? {16'b0, mem[endereco[ADDR_WIDTH-1:2]][15:0]} : {{16{mem[endereco[ADDR_WIDTH-1:2]][15]}}, mem[endereco[ADDR_WIDTH-1:2]][15:0]};
                        default: read_data <= load_unsigned ? {16'b0, mem[endereco[ADDR_WIDTH-1:2]][31:16]} : {{16{mem[endereco[ADDR_WIDTH-1:2]][31]}}, mem[endereco[ADDR_WIDTH-1:2]][31:16]};
                    endcase
                end
                default: begin // LW
                    read_data <= mem[endereco[ADDR_WIDTH-1:2]];
                end
            endcase
        end
    end

endmodule
