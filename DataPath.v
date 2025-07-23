module DataPath (
    input  wire        clk,
    input  wire        reset,
    // sinais da UC
    input  wire [3:0]  ALUOp,
    input  wire [2:0]  ImmSel,
    input  wire        ALUSrc,
    input  wire [1:0]  WB_Sel,
    input  wire        RegWrite,
    input  wire        MemWrite,
    input  wire        MemRead,
    input  wire        BranchEq, BranchNE, BranchLT, BranchGE, BranchU,
    input  wire        Jump,
    input  wire        ALU_A_PC,
    input  wire        ALU_A_zero,
    input  wire [1:0]  StoreSize,
    input  wire [1:0]  LoadSize,
    input  wire        LoadUnsigned,
    input  wire [31:0] n_escolhido,
    input  wire        started,
    // flags da ULA
    output wire        zero, less, less_unsigned,
    // campos para a UC
    output wire [6:0]  opcode,
    output wire [2:0]  funct3,
    output wire [6:0]  funct7,
    // palavra RAM[1] para o display
    output wire [31:0] ram_word1
);

    // ============================================================== IF
    wire [31:0] instrucao, PC_atual, PC_mais_1;

    // ============================================================== ID
    wire [31:0] ImmExt;
    wire [4:0]  rs1 = instrucao[19:15];
    wire [4:0]  rs2 = instrucao[24:20];
    wire [4:0]  rd  = instrucao[11:7];
    wire [31:0] Rs1Data, Rs2Data;

    // ============================================================== EX
    wire [31:0] ALU_A, ALU_B, ALUResult;

    // ============================================================== MEM
    wire [31:0] MemReadData;

    // ============================================================== WB
    wire [31:0] ALUMemData, WriteBackData;
    // ---------- IF ----------
    instruction_fetch IFETCH (
        .clk            (clk),
        .reset          (reset),
        .zero           (zero),
        .less           (less),
        .less_unsigned  (less_unsigned),
        .branch_eq      (BranchEq),
        .branch_ne      (BranchNE),
        .branch_lt      (BranchLT),
        .branch_ge      (BranchGE),
        .branch_u       (BranchU),
        .jump           (Jump),
        .offset         (ImmExt),
        .alu_result     (ALUResult),
        .instrucao      (instrucao),
        .PC_atual       (PC_atual),
        .pc_out         (PC_mais_1)
    );

    // ---------- ID ----------
    ExtensorDeImediato EXT (
        .instrucao (instrucao),
        .ImmSel    (ImmSel),
        .ImmExt    (ImmExt)
    );

    BancoDeRegistradores RF (
        .clk            (clk),
        .reset          (reset),
        .rs1            (rs1),
        .rs2            (rs2),
        .write_register (rd),
        .write_data     (WriteBackData),
        .reg_write      (RegWrite),
        .read_data_1    (Rs1Data),
        .read_data_2    (Rs2Data)
    );

    // ---------- EX ----------
    assign ALU_A = ALU_A_PC  ? PC_atual :
                   ALU_A_zero? 32'b0   : Rs1Data;

    assign ALU_B = ALUSrc ? ImmExt : Rs2Data;

    ula ALU (
        .A              (ALU_A),
        .B              (ALU_B),
        .ALU_operacao   (ALUOp),
        .zero           (zero),
        .less           (less),
        .less_unsigned  (less_unsigned),
        .result         (ALUResult)
    );

    // ---------- MEM ----------
    MemoriaDeDados DMEM (
        .clk           (clk),
        .mem_write     (MemWrite),
        .mem_read      (MemRead),
        .store_size    (StoreSize),
        .load_size     (LoadSize),
        .load_unsigned (LoadUnsigned),
        .endereco      (ALUResult),
        .write_data    (Rs2Data),
        .read_data     (MemReadData),
        .tap_addr1     (ram_word1),
        .preload (started),           // enquanto não apertou START
        .n_in    (n_escolhido)
    );

    // ---------- WB ----------
    Mux2to1 #(32) MUX_ALU_MEM (
        .sel (WB_Sel[0]),
        .in0 (ALUResult),
        .in1 (MemReadData),
        .out (ALUMemData)
    );

    Mux2to1 #(32) WB_MUX (
        .sel (WB_Sel[1]),
        .in0 (ALUMemData),
        .in1 (PC_mais_1),
        .out (WriteBackData)
    );

    // ---------- Para UC ----------
    assign opcode = instrucao[6:0];
    assign funct3 = instrucao[14:12];
    assign funct7 = instrucao[31:25];

endmodule
