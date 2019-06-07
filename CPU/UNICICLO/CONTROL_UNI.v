`ifndef PARAM
	`include "../Parametros.v"
`endif

//*
// * Bloco de Controle UNICICLO
// *
 
/*
* CONTROLE MUX's:
    Descrição do controle do multiplexadores.
    oReg2Loc (Selecione entre RM e RD para entrada da leitura do 2 reg)
    [=] 1'b0 <= Seleciona RM
    [=] 1'b1 <= Seleciona RD

    oOrigAULA (Seleciona a origem A da ULA)
    [=] 1'b0 <= Seleciona o dado do registrador 1
    [=] 1'b1 <= Reservado para o controle de FPREAD

    oOrigBULA (Seleciona a origem B da ULA)
    [=] 1'b0 <= Seleciona o dado do registrador 2
    [=] 1'b1 <= Seleciona o imediato com sinal extendido

    oMemToReg (Controle o reg para entrada de dados no banco de registradores)
    [=] 1'b0 <= Seleciona o dado de saída da ULA
    [=] 1'b1 <= Seleciona o dado lido da memória de dados

    oBranch (Controle de Branch, condicional ou incondicional)
    [=] 2'b00 <= Não é um Branch
    [=] 2'b01 <= Branch incondicional
    [=] 2'b10 <= Branch condicional 

    Sinais de controle
    oRegWrite   <= Desativa/Ativa escrita no banco de registradores
    oALUop      <= Controle da operação da ULA
    oMemRead    <= Controla a leitura da memória
    oMemWrite   <= Desativa/Ativa a escrita na memória
*/

module CONTROL_UNI(
    input  [10:0]   iOPCODE, 
    // ULA
    output    	 	oOrigAULA, oOrigBULA,
	output [1:0]    oALUop, oBranch,

    output          oReg2Loc, oMemRead, oMemWrite, oMemToReg, oRegWrite
);

always @(*)
    casez (iOPCODE)
        OPC_R_ADD, OPC_R_SUB, OPC_R_AND, OPC_R_ORR, OPC_R_MUL, OPC_R_SMULH, 
        OPC_R_UMULH, OPC_R_MULHSU, OPC_R_SDIV, OPC_R_UDIV, OPC_R_REM, OPC_R_REMU, OPC_R_EOR:
            begin
                oOrigAULA   <= 0;
                oOrigBULA   <= 0;
                oALUop      <= 2'b10;
                oReg2Loc    <= 0;
                oBranch     <= 2'b00;
                oMemRead    <= 0;
                oMemWrite   <= 0;
                oMemToReg   <= 0;
                oRegWrite   <= 1;
            end

        OPC_D_LDUR, OPC_D_LDURB, OPC_D_LDURH, OPC_D_LDURSW, OPC_D_LDXR, OPC_D_LDURD:
            begin
                oOrigAULA   <= 0;
                oOrigBULA   <= 1;
                oALUop      <= 2'b0;
                oReg2Loc    <= 0;
                oBranch     <= 2'b00;
                oMemRead    <= 1;
                oMemWrite   <= 0;
                oMemToReg   <= 1;
                oRegWrite   <= 1;
            end

        OPC_D_STUR, OPC_D_STURB, OPC_D_STURH, OPC_D_STURW, OPC_D_STXR, OPC_D_STURD:
            begin
                oOrigAULA   <= 0;
                oOrigBULA   <= 1;
                oALUop      <= 2'b0;
                oReg2Loc    <= 0;
                oBranch     <= 2'b00;
                oMemRead    <= 0;
                oMemWrite   <= 1;
                oMemToReg   <= 0;
                oRegWrite   <= 0;
            end

        OPC_I_ADDI, OPC_I_ANDI, OPC_I_ORRI, OPC_I_SUBI, 
        OPC_I_ADDIS, OPC_I_EORI, OPC_I_SUBIS, OPC_I_ANDIS:
            begin
                oOrigAULA   <= 0;
                oOrigBULA   <= 1;
                oALUop      <= 2'b10;
                oReg2Loc    <= 0;
                oBranch     <= 2'b00;
                oMemRead    <= 0;
                oMemWrite   <= 0;
                oMemToReg   <= 0;
                oRegWrite   <= 1;
            end

        OPC_CB_CBZ, OPC_CB_CBNZ:
            begin
                oOrigAULA   <= 0;
                oOrigBULA   <= 0;
                oALUop      <= 2'b01;
                oReg2Loc    <= 0;
                oBranch     <= 2'b01;
                oMemRead    <= 0;
                oMemWrite   <= 0;
                oMemToReg   <= 0;
                oRegWrite   <= 0;
            end

        OPC_CB_BCOND:
            begin
                oOrigAULA   <= 0;
                oOrigBULA   <= 0;
                oALUop      <= 2'b01;
                oReg2Loc    <= 0;
                oBranch     <= 2'b10;
                oMemRead    <= 0;
                oMemWrite   <= 0;
                oMemToReg   <= 0;
                oRegWrite   <= 0;
            end
        
        
        default:
            begin
                oOrigAULA   <= 0;
                oOrigBULA   <= 0;
                oALUop      <= 2'b11;
                oReg2Loc    <= 0;
                oBranch     <= 2'b00;
                oMemRead    <= 0;
                oMemWrite   <= 0;
                oMemToReg   <= 0;
                oRegWrite   <= 0;
            end
    endcase

endmodule
