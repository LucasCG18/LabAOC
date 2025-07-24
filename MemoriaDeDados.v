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
    reg [31:0] word_read_from_mem;
    reg [7:0]  byte_sel;
    reg [15:0] half_sel;
    // --- LÓGICA DE LEITURA COMBINACIONAL ---
    // A leitura agora é imediata, sem esperar pelo clock
    always @(*) begin
        

        // Valor padrão para evitar latches
        read_data = 32'b0;

        // Leitura da palavra inteira da memória
        word_read_from_mem = mem[endereco[ADDR_WIDTH-1:2]];

        if (mem_read) begin
            case (load_size)
                2'b00: begin // LB / LBU
                    case (endereco[1:0])
                        2'b00:   byte_sel = word_read_from_mem[7:0];
                        2'b01:   byte_sel = word_read_from_mem[15:8];
                        2'b10:   byte_sel = word_read_from_mem[23:16];
                        default: byte_sel = word_read_from_mem[31:24];
                    endcase
                    read_data = load_unsigned ? {24'b0, byte_sel} : {{24{byte_sel[7]}}, byte_sel};
                end
                2'b01: begin // LH / LHU
                    case (endereco[1])
                        1'b0:    half_sel = word_read_from_mem[15:0];
                        default: half_sel = word_read_from_mem[31:16];
                    endcase
                    read_data = load_unsigned ? {16'b0, half_sel} : {{16{half_sel[15]}}, half_sel};
                end
                default: begin // LW
                    read_data = word_read_from_mem;
                end
            endcase
        end
    end

endmodule
