/*
CAMINHO DE DADOS PARA O PROCESSADOR UNICICLO

Leonardo Rodrigues de Souza - 2019/01 - 17/0060543
*/

`ifndef PARAM
	`include "../Parametros.v"
`endif

module Datapath_UNI (
    // Inputs e clocks
    input  wire        iCLK, iCLK50, iRST,
    input  wire [31:0] iInitialPC,

    // Para monitoramento
    output wire [31:0] mPC, mInstr,
	input  wire 	    mTypeSelect,
    output wire [31:0] mRegDisp,
    input  wire [ 4:0] mRegDispSelect,
    output wire [31:0] mDebug,	 
    input  wire [ 4:0] mVGASelect,
    output wire [31:0] mVGARead,
	output wire [31:0] mRead1,
	output wire [31:0] mRead2,
	output wire [31:0] mRegWrite,
	output wire [31:0] mULA,	 

    //  Barramento de Dados
    output wire        DwReadEnable, DwWriteEnable,
    output wire [ 3:0] DwByteEnable,
    output wire [31:0] DwAddress, DwWriteData,
    input  wire [31:0] DwReadData,

    // Barramento de Instrucoes
    output wire        IwReadEnable, IwWriteEnable,
    output wire [ 3:0] IwByteEnable,
    output wire [31:0] IwAddress, IwWriteData,
    input  wire [31:0] IwReadData,
	 
	output wire [31:0] OFPAluresult
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
wire [4:0]  wCALUControl, wULAzero; // Sinal para controle da ULA e retorno do sinal ZERO.
wire [31:0] wA_ULA, wB_ULA;         // Entrada A e B para a ULA, respectivamente.
wire [31:0] wALUresult              // Retorno do resultado da ULA.

// UNICICLO Controle
wire [1:0]  wCOrigPC;               // Controle do mutiplexador da pŕoxima instrução.
wire        wCALUsrcA, wCALUsrcB;   // Fios de controle das entradas da ULA.
wire        wCReg2Loc, wCBranch, wCMemRead, wCMemWrite, wCMemToReg, wCRegWrite;
wire [4:0]  wCALUop;                // Controle da operação da ULA.

assign wPC      = PC;               // Cria um auxiliar para PC.
assign wPC4     = wPC + 32'd4;      // Define o valor de PC + 4.
assign wOPCODE  = wPC[31:21];       // Atribui o OPCODE, pegando todas os possíveis opcodes.

/*-------------------[CONTROLE]-------------------*/
Control_UNICICLO CONTROL (
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
SIGNAL_EXTENDER ALU_INT (
    .iInstr(wInstr),
    .oImediate(wImmediate),
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