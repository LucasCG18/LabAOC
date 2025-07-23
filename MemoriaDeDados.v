// -----------------------------------------------------------------------------
// MemoriaDeDados_DualPort – RAM dual-port de 32 b × 1024, byte-addressable
// Implementação compacta que o Quartus reconhece como M9K.
// -----------------------------------------------------------------------------
module MemoriaDeDados #(
    parameter DATA_WIDTH = 32,
    parameter ADDR_WIDTH = 10, // 2^10 = 1024 palavras de 4 bytes = 4 KB
    parameter DEPTH = 50
)(
    input               clk,
    input               mem_write,
    input               mem_read,
    input       [1:0]   store_size,   // 00=SB 01=SH 10=SW
    input       [1:0]   load_size,    // 00=LB 01=LH 10=LW
    input               load_unsigned,
    input       [31:0]  endereco,  
    input       [31:0]  write_data,
    input  wire        preload,     // ativa a escrita em mem[0]
    input  wire [31:0]  n_in,        // valor de N vindo dos switches
    output reg  [31:0]  read_data,
    output wire [31:0]  tap_addr1     // conteúdo de mem[1] p/ display
);

    // Declaração da RAM física (sem a diretiva ramstyle)
    reg [DATA_WIDTH-1:0] mem [0:DEPTH-1];

    // taps sincronizados
    reg [31:0] tap_reg;
    assign tap_addr1 = tap_reg;

    // regs auxiliares para leitura
    reg [31:0] r_word_read_port;
    reg [1:0]  r_byte_off_read_port;
    reg [7:0]  byte_sel_read_port;
    reg [15:0] half_sel_read_port;



    // Lógica de Escrita
    always @(posedge clk) begin
        //mem[0] <= n_in;
        mem[0] <= 32'd10; 
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




    // Lógica de Leitura
    always @(posedge clk) begin
        // Leitura bruta (palavra) – sempre, para ter dado pronto no ciclo
        r_word_read_port <= mem[endereco[ADDR_WIDTH-1:2]];
        r_byte_off_read_port <= endereco[1:0];
        tap_reg <= mem[10]; // Lê o conteúdo do endereço 4 (segunda palavra de 32 bits)

        // Formatação byte / half / word
        if (mem_read) begin
            case (load_size)
                // LB / LBU
                2'b00: begin
                    case (r_byte_off_read_port)
                        2'b00: byte_sel_read_port = r_word_read_port[7:0];
                        2'b01: byte_sel_read_port = r_word_read_port[15:8];
                        2'b10: byte_sel_read_port = r_word_read_port[23:16];
                        2'b11: byte_sel_read_port = r_word_read_port[31:24];
                    endcase
                    read_data <= load_unsigned ? {24'b0, byte_sel_read_port}
                                               : {{24{byte_sel_read_port[7]}}, byte_sel_read_port};
                end

                // LH / LHU
                2'b01: begin
                    case (r_byte_off_read_port[1])
                        1'b0: half_sel_read_port = r_word_read_port[15:0];
                        1'b1: half_sel_read_port = r_word_read_port[31:16];
                    endcase
                    read_data <= load_unsigned ? {16'b0, half_sel_read_port}
                                               : {{16{half_sel_read_port[15]}}, half_sel_read_port};
                end

                // LW (ou default)
                default: read_data <= r_word_read_port;
            endcase
        end else begin
            read_data <= 32'b0;   // opcional: pode manter valor anterior
        end
    end

endmodule


