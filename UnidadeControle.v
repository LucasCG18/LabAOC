module UnidadeControle(
    input  wire [6:0] opcode,   // opcode da instrução (bits 6..0)
    input  wire [2:0] funct3,   // campo funct3 (bits 14..12)
    input  wire [6:0] funct7,   // campo funct7 (bits 31..25)
    output reg        RegWrite,
    output reg        ALUSrc,
    output reg        MemRead,
    output reg        MemWrite,
    output reg        MemToReg,
    output reg        BranchEq,
    output reg        BranchNE,
    output reg        BranchLT,
    output reg        BranchGE,
    output reg        BranchU,
    output reg        Jump,
    output reg [2:0]  ImmSel,
    output reg [3:0]  ALUOp,
    output reg [1:0]  WB_Sel,
    output reg [1:0]  StoreSize,
    output reg [1:0]  LoadSize,
    output reg        LoadUnsigned,
    output reg        ALU_A_PC,
    output reg        ALU_A_zero
);
    always @(*) begin
        // Valores padrão (NOP)
        RegWrite      = 0;
        ALUSrc        = 0;
        MemRead       = 0;
        MemWrite      = 0;
        MemToReg      = 0;
        BranchEq      = 0;
        BranchNE      = 0;
        BranchLT      = 0;
        BranchGE      = 0;
        BranchU       = 0;
        Jump          = 0;
        ImmSel        = 3'b000;
        ALUOp         = 4'b0000;
        WB_Sel        = 2'b00;
        StoreSize     = 2'b10;
        LoadSize      = 2'b10;
        LoadUnsigned  = 0;
        ALU_A_PC      = 0;
        ALU_A_zero    = 0;
        case (opcode)
            // R-TYPE (instruções de registrador)
            7'b0110011: begin
                RegWrite = 1;
                // ALUOp definido pelo funct7 e funct3 (bit5 de funct7 distingue algumas ops)
                case ({funct7[5], funct3})
                    4'b0000: ALUOp = 4'b0000;  // ADD
                    4'b1000: ALUOp = 4'b0001;  // SUB
                    4'b0111: ALUOp = 4'b0010;  // AND
                    4'b0110: ALUOp = 4'b0011;  // OR
                    4'b0100: ALUOp = 4'b0100;  // XOR
                    4'b0001: ALUOp = 4'b0101;  // SLL
                    4'b0101: ALUOp = 4'b0110;  // SRL
                    4'b1101: ALUOp = 4'b0111;  // SRA
                    4'b0010: ALUOp = 4'b1000;  // SLT
                    4'b0011: ALUOp = 4'b1001;  // SLTU
                endcase
            end

            // I-TYPE aritmético (ADDI, lógica, shifts imediatos, SLTI)
            7'b0010011: begin
                RegWrite = 1;
                ALUSrc   = 1;
                ImmSel   = 3'b000;  // Imediato tipo I
                case (funct3)
                    3'b000: ALUOp = 4'b0000;                        // ADDI
                    3'b010: ALUOp = 4'b1000;                        // SLTI
                    3'b011: ALUOp = 4'b1001;                        // SLTIU
                    3'b111: ALUOp = 4'b0010;                        // ANDI
                    3'b110: ALUOp = 4'b0011;                        // ORI
                    3'b100: ALUOp = 4'b0100;                        // XORI
                    3'b001: ALUOp = 4'b0101;                        // SLLI
                    3'b101: ALUOp = funct7[5] ? 4'b0111 : 4'b0110;  // SRAI (funct7[5]=1) / SRLI
                endcase
            end

            // LOAD (LB, LH, LW, LBU, LHU)
            7'b0000011: begin
                RegWrite    = 1;
                ALUSrc      = 1;
                MemRead     = 1;
                MemToReg    = 1;
                ImmSel      = 3'b000;    // Imediato tipo I
                WB_Sel      = 2'b01;     // Write-back da Memória
                ALUOp       = 4'b0000;   // ULA calcula endereço = rs1 + imm
                case (funct3)
                    3'b000: begin LoadSize = 2'b00; LoadUnsigned = 0; end  // LB
                    3'b001: begin LoadSize = 2'b01; LoadUnsigned = 0; end  // LH
                    3'b010: begin LoadSize = 2'b10; LoadUnsigned = 0; end  // LW
                    3'b100: begin LoadSize = 2'b00; LoadUnsigned = 1; end  // LBU
                    3'b101: begin LoadSize = 2'b01; LoadUnsigned = 1; end  // LHU
                    default: begin LoadSize = 2'b10; LoadUnsigned = 0; end // demais -> LW
                endcase
            end

            // STORE (SB, SH, SW)
            7'b0100011: begin
                ALUSrc   = 1;
                MemWrite = 1;
                ImmSel   = 3'b001;    // Imediato tipo S
                ALUOp    = 4'b0000;   // ULA calcula endereço = rs1 + imm
                case (funct3)
                    3'b000: StoreSize = 2'b00;   // SB
                    3'b001: StoreSize = 2'b01;   // SH
                    default: StoreSize = 2'b10;  // SW (ou outros não usados)
                endcase
            end

            // BRANCH (BEQ, BNE, BLT, BGE, BLTU, BGEU)
            7'b1100011: begin
                ImmSel = 3'b010;   // Imediato tipo B
                ALUOp  = 4'b0001;   // ULA faz SUB para usar flag zero (BEQ/BNE)
                case (funct3)
                    3'b000: BranchEq = 1;                        // BEQ
                    3'b001: BranchNE = 1;                        // BNE
                    3'b100: begin BranchLT = 1; BranchU = 0; end // BLT  (signed)
                    3'b101: begin BranchGE = 1; BranchU = 0; end // BGE  (signed)
                    3'b110: begin BranchLT = 1; BranchU = 1; end // BLTU (unsigned)
                    3'b111: begin BranchGE = 1; BranchU = 1; end // BGEU (unsigned)
                endcase
            end

            // LUI (Load Upper Immediate)
            7'b0110111: begin
                RegWrite = 1;
                ALUSrc   = 1;
                ImmSel   = 3'b011;  // Imediato tipo U (20 bits superiores)
                ALUOp    = 4'b0000; // ULA fará 0 + imm (função de soma)
                ALU_A_zero = 1;    // operando A da ULA = 0 (ignora rs1)
            end

            // AUIPC (Add Upper Imm to PC)
            7'b0010111: begin
                RegWrite = 1;
                ALUSrc   = 1;
                ImmSel   = 3'b011;  // Imediato tipo U
                ALUOp    = 4'b0000; // ULA fará PC + imm
                ALU_A_PC = 1;      // operando A da ULA = PC:contentReference[oaicite:11]{index=11}
            end

            // JAL (Jump and Link)
            7'b1101111: begin
                RegWrite = 1;
                Jump     = 1;
                ImmSel   = 3'b100;  // Imediato tipo J
                WB_Sel   = 2'b10;   // write-back do PC+4 para rd
                // ALUOp default (ADD), ALUSrc default (0) – ULA não é usada para PC (calculado no IF)
            end

            // JALR (Jump and Link Register)
            7'b1100111: begin
                RegWrite = 1;
                Jump     = 1;
                ALUSrc   = 1;
                ImmSel   = 3'b000;  // Imediato tipo I (JALR usa formato I)
                ALUOp    = 4'b0000; // ULA calcula rs1 + imm (endereço de destino)
                WB_Sel   = 2'b10;   // write-back do PC+4 para rd
                BranchU  = 1;       // sinaliza JALR (para lógica de PC no IF)
            end
        endcase
    end
endmodule
