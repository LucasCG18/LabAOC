module CPU(
    input wire clk,
    input wire reset,
    input wire [31:0] n,
    input wire started,
	output wire [31:0] resultado_fibo,
	output wire flagzero
);
    // Declaração dos sinais de interconexão
    wire [6:0] opcode;
    wire [2:0] funct3;
    wire [6:0] funct7;
    wire        RegWrite, ALUSrc, MemRead, MemWrite, MemToReg;
    wire        BranchEq, BranchNE, BranchLT, BranchGE, BranchU, Jump;
    wire [2:0]  ImmSel;
    wire [3:0]  ALUOp;
    wire [1:0]  WB_Sel;
    wire [1:0]  StoreSize;
    wire [1:0]  LoadSize;
    wire        LoadUnsigned;
    wire        ALU_A_PC;
    wire        ALU_A_zero;
	wire [31:0] ram_word1;
    // (Flags da ULA do datapath, não utilizados na UC single-cycle)
    wire zero_flag, less_flag, less_u_flag;
	 
	 
	 assign resultado_fibo = ram_word1;
	 assign flagzero = zero_flag;
    // Instancia o Datapath (DP)
    DataPath DP (
        .clk         (clk),
        .reset       (reset),
        // sinais da UC -> DP
        .ALUOp       (ALUOp),
        .ImmSel      (ImmSel),
        .ALUSrc      (ALUSrc),
        .WB_Sel      (WB_Sel),
        .RegWrite    (RegWrite),
        .MemWrite    (MemWrite),
        .MemRead     (MemRead),
        .BranchEq    (BranchEq),
        .BranchNE    (BranchNE),
        .BranchLT    (BranchLT),
        .BranchGE    (BranchGE),
        .BranchU     (BranchU),
        .Jump        (Jump),
        .n_escolhido (n),
        .started (started),
        .ALU_A_PC    (ALU_A_PC),
        .ALU_A_zero  (ALU_A_zero),
        .StoreSize   (StoreSize),
        .LoadSize    (LoadSize),
        .LoadUnsigned(LoadUnsigned),
        // flags da ULA (saídas do DP)
        .zero        (zero_flag),
        .less        (less_flag),
        .less_unsigned (less_u_flag),
        // campos da instrução (saídas do DP) -> UC
        .opcode      (opcode),
        .funct3      (funct3),
        .funct7      (funct7),
		.ram_word1 (ram_word1)
    );

    // Instancia a Unidade de Controle (UC)
    UnidadeControle UC (
        .opcode       (opcode),
        .funct3       (funct3),
        .funct7       (funct7),
        .RegWrite     (RegWrite),
        .ALUSrc       (ALUSrc),
        .MemRead      (MemRead),
        .MemWrite     (MemWrite),
        .MemToReg     (/* não utilizado, substituído por WB_Sel */),
        .BranchEq     (BranchEq),
        .BranchNE     (BranchNE),
        .BranchLT     (BranchLT),
        .BranchGE     (BranchGE),
        .BranchU      (BranchU),
        .Jump         (Jump),
        .ImmSel       (ImmSel),
        .ALUOp        (ALUOp),
        .WB_Sel       (WB_Sel),
        .StoreSize    (StoreSize),
        .LoadSize     (LoadSize),
        .LoadUnsigned (LoadUnsigned),
        .ALU_A_PC     (ALU_A_PC),
        .ALU_A_zero   (ALU_A_zero)
    );
endmodule
