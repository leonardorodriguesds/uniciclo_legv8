`ifndef PARAM
	`include "../Parametros.v"
`endif

//*
// * Bloco de Controle UNICICLO
// *
 
/*
* CONTROLE MUX's:
    Descrição do controle do multiplexadores.
    oOrigAULA(Controle a entrada A da ULA de inteiros):
    |=| 1 => R[rs1](Leitura do registrador RS1 int),
    |=| 2 => PC(Program Counter).
	 
    oOrigAULA(Controle a entrada B da ULA):
    |=| 1 => R[rs2](Leitura do registrador RS2 int),
    |=| 2 => Imediato.
	 
    oRegWrite(Habilita/Desabilita a escrita no banco de registradores de inteiros):
    |=| 0 => Escrita desabilitada,
    |=| 1 => Escrita habilitada.
	 
    oMemWrite(Habilita/Desabilita a escrita na memória):
    |=| 0 => Escrita desabilitada,
    |=| 1 => Escrita habilitada.
	 
    oMeoMemReadmWrite(Habilita/Desabilita a leitura da memória):
    |=| 0 => Leitura desabilitada,
    |=| 1 => Leitura habilitada.
	 
    oOrigMemD(Define qual registrador, inteiros ou ponto flutuante, será escrito na memória):
    |=| 0 => R[rs2](Registrador RS2 int),
    |=| 1 => F[rs2](Registrador RS2 float).
	 
    oFPRegWrite(Habilita/Desabilita a escrita no banco de registrador de ponto flutuante):
    |=| 0 => Escrita desabilitada,
    |=| 1 => Escrita habilitada.  
	 
    oFPOrigA(Controle a entrada B da FPULA):
    |=| 1 => F[rs1](Leitura do registrador RS1 float),
    |=| 2 => R[rs1](Leitura do registrador RS1 int).
	 
    oOrigPC(Controle o registrador PC):
    |=| 0 => PC + 4,
    |=| 1 => (Branch == true)? BranchPC : PC + 4,
    |=| 2 => BranchPC,
    |=| 3 => (R[rs1] + Imediato) << 1.
	 
    oFPMem2Reg(Controla a entrada de dados no banco de registradores de ponto flutuante):
    |=| 0 => Resultado da FPULA,
    |=| 1 => MEM[R[rs1] + Imediato](Conteúdo lido da memória no endereço (R[rs1] + Immediate)),
    |=| 2 => R[rs1](Registrado RS1 int).
	 
    oMem2Reg(Controla a entrada de dados no banco de registrador de inteiros):
    |=| 0 => Resultado da ULA,
    |=| 1 => PC + 4,
    |=| 2 => MEM[R[rs1] + Imediato](Conteúdo lido da memória no endereço (R[rs1] + Immediate)),
    |=| 3 => Resultado da FPULA,
    |=| 4 => Resultado da comparação da FPULA(F[rs1] comp F[rs2]),
    |=| 5 => F[rs1](Leitura do registrador RS1 float).
    oALUControl(Controla a operação da ULA).
    oFPALUControl(Controla a operação da FPULA).  
*/

module Control_UNI(
    input  [10:0]   iOPCODE, 
    // ULA
    output    	 	oOrigAULA, oOrigBULA,
    output [4:0]    oALUop,

    output          oReg2Loc, oBranch, oMemRead, oMemWrite, oMemToReg, oRegWrite
);

always (*)
    case (iOPCODE)
        
        default:
            oOrigAULA   = 0;
            oOrigBULA   = 0;
            oALUop      = OPNULL;
            oReg2Loc    = 0;
            oBranch     = 0;
            oMemRead    = 0;
            oMemWrite   = 0;
            oMemToReg   = 0;
            oRegWrite   = 0;
    endcase

endmodule