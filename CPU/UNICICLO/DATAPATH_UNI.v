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
    output wire [31:0] mPC, mInstr,
	input  wire 	   mULAorFPULA,
    output wire [63:0] mRegDisp,
    input  wire [ 4:0] mRegDispSelect,
    output wire [63:0] mDebug,	 
    input  wire [ 4:0] mVGASelect,
    output wire [63:0] mVGARead,
	output wire [63:0] mRead1,
	output wire [63:0] mRead2,
	output wire [63:0] mRegWrite,
	output wire [63:0] mULA,	 

    //  Barramento de Dados
    output wire        DwReadEnable, DwWriteEnable,
    output wire [ 3:0] DwByteEnable,
    output wire [31:0] DwAddress, DwWriteData,
    input  wire [31:0] DwReadData,

    // Barramento de Instrucoes
    output wire        IwReadEnable, IwWriteEnable,
    output wire [ 3:0] IwByteEnable,
    output wire [31:0] IwAddress, IwWriteData,
    input  wire [31:0] IwReadData
);



/*--------------------[REGISTRADORES E FIOS]--------------------*/
/*
    Para padronizar os nomes dos registradores e fios são aplicados:
        Nomes que inicial com 'w' indica que é um fio.
        Nomes que possuem um 'wC' indica que é um fio de controle.
        Outros nomes são de registradores.
*/				 

// Instrução
reg  [31:0] PC;                     // Controle do endereço da instrução atual.
wire [31:0] wiPC;                   // Endereço da próxima instrução.
wire [31:0] wPC, wPC4;              // Auxiliares para armazanar o PC atual, e o PC + 4, respectivamente.
wire [10:0] wOPCODE;                // Pega o OPCODE da instrução.
wire [63:0] wImmediate;             // Imeadiato com extensão de sinal
wire [31:0] wInstr;                 // Instrução

// ULA
wire        wULAzero;
wire [4:0]  wCALUControl;           // Sinal para controle da ULA e retorno do sinal ZERO.
wire [63:0] wA_ULA, wB_ULA;         // Entrada A e B para a ULA, respectivamente.
wire [63:0] wALUresult;             // Retorno do resultado da ULA.

// FPULA
wire [4:0]  wCFPALUControl;         // Sinal para controle da FPULA e retorno do sinal ZERO.
wire [63:0] wA_FPULA, wB_FPULA;     // Entrada A e B para a FPULA, respectivamente.
wire [63:0] wFPALUresult;           // Retorno do resultado da FPULA.

// UNICICLO Controle
wire [1:0]  wCOrigPC;               // Controle do mutiplexador da pŕoxima instrução.
wire        wCALUsrcA, wCALUsrcB;   // Fios de controle das entradas da ULA.
wire        wCReg2Loc, wCBranch, wCMemRead, wCMemWrite, wCMemToReg, wCRegWrite;
wire [4:0]  wCALUop;                // Controle da operação da ULA.

// Bancos de registradores
wire [63:0] wReadRN, wReadRM, wRegWrite;
wire [4:0]  wCRegRM, wCRegRN, wCRegRD, wCRegRT;
wire [63:0] wFPReadRN, wFPReadRM, wFPRegWrite;

// Memória
wire [63:0] wMEMData;

// Para monitoramento
wire [63:0] wFPRegDisp, wRegDisp, wVGAFPRead, wVGARead;

assign wPC      = PC;               // Cria um auxiliar para PC.
assign wPC4     = wPC + 32'd4;      // Define o valor de PC + 4.
assign wOPCODE  = wPC[31:21];       // Atribui o OPCODE, pegando todas os possíveis opcodes.

// Banco de registradores
assign wCRegRM = mInstr[4:0];
assign wCRegRN = mInstr[9:5];
assign wCRegRM = mInstr[20:16];
assign wCRegRT = mInstr[4:0];

/*---------------[SINAIS DE MONITORAMENTO]---------------*/
assign mPC					= wPC; 
assign mInstr				= wInstr;
assign mRead1				= mULAorFPULA? wFPReadRN : wReadRN;
assign mRead2				= mULAorFPULA? wFPReadRM : wReadRM;
assign mRegWrite			= mULAorFPULA? wFPRegWrite : wRegWrite;
assign mULA					= mULAorFPULA? wFPALUresult : wALUresult;
assign mDebug				= 32'h000ACE10;	// Ligar onde for preciso	
assign mRegDisp			    = mULAorFPULA? wFPRegDisp : wRegDisp;
assign mVGARead			    = mULAorFPULA? wVGAFPRead : wVGARead;
assign wRegDispSelect 	    = mRegDispSelect;
assign wVGASelect 		    = mVGASelect;

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
/*---------[BANCO DE REGISTRADORES]----------*/
/* 
    input wire 			iCLK, iRST, iRegWrite,
    input wire  [4:0] 	iReadRegister1, iReadRegister2, iWriteRegister,
    input wire  [63:0] 	iWriteData,
    output wire [63:0] 	oReadData1, oReadData2,
    // Controle para monitoramento
    input wire  [4:0] 	iVGASelect, iRegDispSelect,
    output reg  [63:0] 	oVGARead, oRegDisp;
*/
REGISTERS REG_INT (
    .iCLK(iCLK),
    .iRST(iRST),
    .iRegWrite(wCRegWrite),
    .iReadRegister1(wCRegRN),
    .iReadRegister2(wCRegRM),
    .iWriteRegister(wCRegRD),
    .iWriteData(wRegWrite),
    .oReadData1(wReadRN),
    .oReadData2(wReadRM),
    
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
    .oZero(wULAzero)
);
/*-------------------[EXTENSOR DE SINAL]-------------------*/
SIGNAL_EXTEND SIGNAL_EXT (
    .iInstr(wInstr),
    .oImmediateExtended(wImmediate),
);

/*-------------------[MULTIPLEXADORES]-------------------*/
always @(*) 
    case (wCBranch & wULAzero)
        /*
        Multiplexador para controle do PC:
            wiPC = Controle do PC::
                [0] = PC + 4;
                [1] = Shifita o Imediato em 2x, e soma com PC;
        */
        1'b0:       wiPC <= wPC4;
        1'b1:       wiPC <= {wImmediate[29:0], 2'b00} + wPC;
    endcase

/*-------------------------------------------------------*/
always @(posedge iCLK or posedge iRST)
    /* posedge iCLK => Para realizar a cada ciclo de CLOCK */
    begin
        if(iRST)
                PC	<= iInitialPC;      // Para dar reset
        else
                PC	<= wiPC;            // Atualiza PC com o endereço da próxima instrução
    end

endmodule