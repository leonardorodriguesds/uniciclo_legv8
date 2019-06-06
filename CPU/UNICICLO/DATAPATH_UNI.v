/*
CAMINHO DE DADOS PARA O PROCESSADOR UNICICLO

Leonardo Rodrigues de Souza - 2019/01 - 17/0060543
*/

`ifndef PARAM
	`include "../Parametros.v"
`endif

module DATAPATH_UNI (
    // Inputs e clocks
    input  wire        iCLK, iCLK50, iRST,
    input  wire [31:0] iInitialPC,

    // Para monitoramento
    input  wire [ 4:0] mRegDispSelect,
    input  wire [ 4:0] mVGASelect,
    output wire [31:0] mPC, mInstr,
    output wire [63:0] mRegDisp,
    output wire [63:0] mDebug,	 
    output wire [63:0] mVGARead,
	output wire [63:0] mRead1,
	output wire [63:0] mRead2,
	output wire [63:0] mRegWrite,
	output wire [63:0] mULA,	 

    //  Barramento de Dados
    input  wire [63:0] DwReadData,
    output wire        DwReadEnable, DwWriteEnable,
    output wire [63:0] DwAddress, DwWriteData,
    output wire [ 7:0] DwByteEnable,

    // Barramento de Instrucoes
    input  wire [31:0] IwReadData,
    output wire [ 3:0] IwByteEnable,
    output wire        IwReadEnable, IwWriteEnable,
    output wire [31:0] IwAddress, IwWriteData
);

reg  [31:0] PC;                     // Controle do endereço da instrução atual.
initial
	begin
		PC         <= BEGINNING_TEXT;
	end

/*-------------------------[FIOS]------------------------*/
/*
    Para padronizar os nomes dos registradores e fios são aplicados:
        Nomes que inicial com 'w' indica que é um fio.
        Nomes que possuem um 'wC' indica que é um fio de controle.
        Outros nomes são de registradores.
*/				 

// Instrução
wire [31:0] wiPC;                   // Endereço da próxima instrução.
wire [31:0] wPC, wPC4;              // Auxiliares para armazanar o PC atual, e o PC + 4, respectivamente.
wire [10:0] wOPCODE;                // Pega o OPCODE da instrução.
wire [63:0] wImmediate;             // Imeadiato com extensão de sinal
wire [31:0] wInstr;                 // Instrução
wire [4:0]  wCRegRM, wCRegRN, wCRegRD, wCRegRT;

// ULA
wire        wULAzero;
wire [4:0]  wCALUControl;           // Sinal para controle da ULA e retorno do sinal ZERO.
wire [63:0] wA_ULA, wB_ULA;         // Entrada A e B para a ULA, respectivamente.
wire [63:0] wALUresult;             // Retorno do resultado da ULA.
// wire        wFlagN, wFlagZ, wFlagV, wFlagC;

// UNICICLO Controle
wire [1:0]  wCOrigPC, wCBranch;     // Controle do mutiplexador da pŕoxima instrução e de Branch;
wire        wCALUsrcA, wCALUsrcB;   // Fios de controle das entradas da ULA.
wire        wCReg2Loc, wCMemRead, wCMemWrite, wCMemToReg, wCRegWrite;
wire [1:0]  wCALUop;                // Controle da operação da ULA.

// Bancos de registradores
wire [63:0] wRead1, wRead2, wRegWrite;
wire [4:0]  wCReg1, wCReg2, wCReg3;

// Unidade de branch condicional
wire        wCBranchCond;

// Para monitoramento
wire [63:0] wFPRegDisp, wRegDisp, wVGAFPRead, wVGARead;
wire [ 4:0] wRegDispSelect, wVGASelect;

// Memória
wire [63:0] wMEMData;
wire [63:0] wMemDataWrite, wReadData;
wire [63:0] wMemLoad;
wire [ 7:0] wMemEnable;

/*-----------[BARRAMENTO DA MEMÓRIA DE DADOS]------------*/
assign DwReadEnable     = wCMemRead;
assign DwWriteEnable    = wCMemWrite;
assign DwWriteData      = wMemDataWrite;
assign wReadData        = DwReadData;
assign DwAddress        = wALUresult;
assign DwByteEnable     = wMemEnable;

/*---------[BARRAMENTO DA MEMÓRIA DE INSTRUÇÕES]---------*/
assign wPC              = PC;               // Cria um auxiliar para PC.
assign wPC4             = wPC + 32'd4;      // Define o valor de PC + 4.
assign IwReadEnable     = ON;
assign IwWriteEnable    = OFF;
assign IwAddress        = wPC;
assign IwWriteData      = ZERO[31:0];
assign IwByteEnable     = 4'b1111;
assign wInstr           = IwReadData;
assign wOPCODE          = wPC[31:21];       // Atribui o OPCODE, pegando todas os possíveis opcodes.

/*---------[ATRIBUIÇÕES BANCO DE REGISTRADORES]----------*/
assign wCRegRD          = wInstr[4:0];
assign wCRegRN          = wInstr[9:5];
assign wCRegRM          = wInstr[20:16];
assign wCRegRT          = wInstr[4:0];
assign wCReg1           = wCRegRN;
assign wCReg3           = wCRegRD;

/*---------------[SINAIS DE MONITORAMENTO]---------------*/
assign mPC			    = wPC; 
assign mInstr			= wInstr;
assign mRead1			= wRead1;
assign mRead2			= wRead2;
assign mRegWrite		= wRegWrite;
assign mULA				= wALUresult;
assign mDebug			= 32'h000ACE10;	// Ligar onde for preciso	
assign mRegDisp		    = wRegDisp;
assign mVGARead		    = wVGARead;
assign wRegDispSelect   = mRegDispSelect;
assign wVGASelect 	    = mVGASelect;

/*-------------------[CONTROLE]-------------------*/
CONTROL_UNI CONTROL (
    .iOPCODE(wOPCODE),
    .oOrigAULA(wCALUsrcA),
    .oOrigBULA(wCALUsrcB),
    .oReg2Loc(wCReg2Loc),
    .oBranch(wCBranch),  
    .oMemRead(wCMemRead),
    .oMemWrite(wCMemWrite),
    .oMemToReg(wCMemToReg),
    .oRegWrite(wCRegWrite),
    .oALUop(wCALUop)
);
/*-------------------[MEMÓRIA]-------------------*/
MEMSTORE MEMSTORE0 (
    .iOpcode(wOPCODE),
    .iData(wMEMData),
    .oData(wMemDataWrite),
    .oByteEnable(wMemEnable)
);
MEMLOAD MEMLOAD0 (
    .iOpcode(wOPCODE),
    .iData(wReadData),
    .oData(wMemLoad)
);
/*---------[BANCO DE REGISTRADORES]----------*/
REGISTERS REG_INT (
    .iCLK(iCLK),
    .iRST(iRST),
    .iRegWrite(wCRegWrite),
    .iReadRegister1(wCReg1),
    .iReadRegister2(wCReg2),
    .iWriteRegister(wCReg3),
    .iWriteData(wRegWrite),
    .oReadData1(wRead1),
    .oReadData2(wRead2),
    
    .iVGASelect(wVGASelect),
    .iRegDispSelect(wRegDispSelect),
    .oRegDisp(wRegDisp),
    .oVGARead(wVGARead)
);
/*-------------------[ULA]-------------------*/
ALU_CONTROL ALU_C (
    .iOPCODE(wOPCODE),
    .iALUop(wCALUop),
    .oALUControl(wCALUControl)
);

ALU ALU_INT (
    .iControl(wCALUControl),
    .iA(wA_ULA),
    .iB(wB_ULA),
    .oResult(wALUresult),
    .oZero(wULAzero),
    .oflagN(),
    .oflagZ(),
    .oflagV(),
    .oflagC()
);
/*-------------------[EXTENSOR DE SINAL]-------------------*/
SIGNAL_EXTEND SIGNAL_EXT (
    .iInstr(wInstr),
    .oImmediateExtended(wImmediate)
);
/*------------[UNIDADE DE BRANCH CONDICIONAL]-------------*/
BRANCH COND_BRANCH (
    .iCondition(wCRegRT),
    .iFlagN(wFlagN),
    .iFlagZ(wFlagZ), 
    .iFlagV(wFlagV),
    .iFlagC(wFlagC),
    .oTakeBranch(wCBranchCond)
);
/*-------------------[MULTIPLEXADORES]-------------------*/
/* CONTROLE MUX's:
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
always @(*)
	begin 
		 case (wCReg2Loc)
			  1'b1:   wCReg2  <= wCRegRD;
			  default:
					wCReg2      <= wCRegRM;
		 endcase
	end

always @(*)
	begin
		 case (wCALUsrcA)
			  1'b0: wA_ULA    <= wRead1;
			  default:
					wA_ULA      <= wRead1;
		 endcase
	end
	 
always @(*)
	begin
		 case (wCALUsrcB)
			  1'b1: wB_ULA    <= wImmediate;
			  default:
					wB_ULA      <= wRead2;
		 endcase
	end

always @(*)
	begin
		 case (wCMemToReg)
			  1'b1: wRegWrite <= wMemLoad;
			  default:
					wRegWrite   <= wALUresult;
		 endcase
	end
	 
/*always @(wCBranch)
begin
    case (wCBranch)
        2'b01:
            begin
                case (wULAzero)
                    1'b1: wiPC <= {wImmediate[29:0], 2'b00} + wPC;
                    default:
                        wiPC <= wPC4;
                endcase
            end
        2'b10:
            begin
                case (wCBranchCond)
                    1'b1: wiPC <= {wImmediate[29:0], 2'b00} + wPC;
                    default:
                        wiPC <= wPC4;
                endcase
            end
        default:
            wiPC <= wPC4;
    endcase
end*/
/*-------------------------------------------------------*/
always @(posedge iCLK or posedge iRST)
    /* posedge iCLK => Para realizar a cada ciclo de CLOCK */
    begin
        if(iRST)
                PC	<= iInitialPC;      // Para dar reset
        else
                PC	<= wiPC;            // Atualiza PC com o endereço da próxima instrução
    end
/*-------------------------------------------------------*/
endmodule