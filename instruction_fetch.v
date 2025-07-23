module instruction_fetch (
    input  wire        clk,
    input  wire        reset,

    // flags da ULA para comparação de branch
    input  wire        zero,
    input  wire        less,
    input  wire        less_unsigned,

    // sinais de controle de branch e jump
    input  wire        branch_eq,
    input  wire        branch_ne,
    input  wire        branch_lt,
    input  wire        branch_ge,
    input  wire        branch_u,    // 1 para comparação unsigned (BLTU/BGEU); também indica JALR
    input  wire        jump,        // 1 para instruções de salto (JAL / JALR)

    // operandos para cálculo de desvio/salto
    input  wire [31:0] offset,      // imediato estendido (deslocado quando necessário)
    input  wire [31:0] alu_result,  // resultado da ULA (usado para JALR: rs1 + imm)

    // saídas
    output wire [31:0] instrucao,   // instrução lida da memória (ROM)
    output wire [31:0] PC_atual,    // valor corrente do PC
    output wire [31:0] pc_out       // PC+1 (PC incrementado) para Write-Back
);

    // Sinais internos
    wire [31:0] PC_mais_1;
    wire [31:0] EnderecoBranch;
    wire [31:0] PC_next;

    // Registrador de Programa (PC)
    ContadorPrograma PC_reg (
        .PC_next (PC_next),
        .clk     (clk),
        .reset   (reset),
        .PC      (PC_atual)
    );
    assign pc_out = PC_mais_1;  // expõe PC+1

    // Somador PC + 1
    contadorPC ADD1 (
        .PC_atual (PC_atual),
        .PC_mais_1(PC_mais_1)
    );

    // Memória de Instrução (ROM) – leitura da instrução corrente
    MemoriaDeInstrucao ROM (
        .endereco (PC_atual),
        .reset    (reset),
        .instrucao(instrucao)
    );

    // Lógica de branch (condicional)
    wire signed_branch = ~branch_u;                     // =1 para branches signados, =0 para unsigned
    wire lt_flag       = signed_branch ? less : less_unsigned;
    wire cond_ok = (branch_eq &  zero)   |              // BEQ  && (A==B)
                   (branch_ne & ~zero)   |              // BNE  && (A!=B)
                   (branch_lt &  lt_flag) |             // BLT/BLTU  && (A<B) signed/unsigned
                   (branch_ge & ~lt_flag);              // BGE/BGEU  && (A>=B) signed/unsigned

    assign EnderecoBranch = cond_ok ? (PC_atual + offset) : PC_mais_1;

    // Lógica de jump (incondicional)
    wire [31:0] jump_addr = (jump && branch_u) ? (alu_result & 32'hFFFFFFFE)   // JALR: endereço = (rs1+imm) com bit0 = 0:contentReference[oaicite:16]{index=16}
                                             : (PC_atual + offset);           // JAL: endereço = PC + offset

    assign PC_next = jump ? jump_addr : EnderecoBranch;
endmodule
