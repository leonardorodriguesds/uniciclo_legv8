/* Definicao do processador */
`ifndef PARAM
	`include "../Parametros.v"
`endif

module COMPUTER (
    input              CLOCK_50, iRST, iTimer,
    input  wire [7:0]  iFdiv,
    input  wire [3:0]  iKEY,
    input  wire [9:0]  iSW,
    /*------- MONITORAMENTO -------*/
	input  wire 	   mULAorFPULA,
    input  wire [4:0]  mRegDispSelect,
    input  wire [4:0]  mVGASelect,
	output wire [31:0] mPC, 
	output wire [31:0] mInstr,
	output wire [31:0] mDebug,
    output wire [31:0] mRegDisp,
    output wire [5:0]  mControlState,
    output wire [31:0] mVGARead,
	output wire [31:0] mRead1,
	output wire [31:0] mRead2,
	output wire [31:0] mRegWrite,
	output wire [31:0] mULA
);

/*------------------[FIOS E REGISTRADORES]------------------*/
// Controle do Clock
wire CLK, oCLK_50, oCLK_25, oCLK_100, oCLK_150, oCLK_200, oCLK_27, oCLK_18;
wire Reset, CLKSelectFast, CLKSelectAuto;
wire wbreak;

//Barramento de Dados
wire [63:0] DAddress, DWriteData;
wire [63:0] DReadData;
wire        DWriteEnable, DReadEnable;
wire [ 3:0] DByteEnable;

//Barramento de Instrucoes
wire [31:0] IAddress, IWriteData;
wire [31:0] IReadData;
wire        IWriteEnable, IReadEnable;
wire [ 3:0] IByteEnable;

// Controle do PC
wire [31:0] wPCinicial;

// VGA
wire [4:0]  wVGASelectIn;
wire [63:0] wVGAReadIn;

assign wPCinicial = BEGINNING_TEXT;

assign wVGAReadIn       = mVGARead;
assign mVGASelect       = wVGASelectIn;
/*--------------------[INTERFACE DE CLOCK]---------------------*/
CLOCK_Interface CLOCK0(
	.iCLK_50(CLOCK_50),					// 50MHz
    .oCLK_50(oCLK_50),                  // 50MHz  <<  Que será usado em todos os dispositivos	 
    .oCLK_100(oCLK_100),                // 100MHz
	.oCLK_150(oCLK_150),
    .oCLK_200(oCLK_200),                // 200MHz Usado no SignalTap II
	.oCLK_25(oCLK_25),					// Usado na VGA
	.oCLK_27(oCLK_27),
	.oCLK_18(oCLK_18),					// Usado no Audio
    .CLK(CLK),                          // Clock da CPU
    .Reset(Reset),                      // Reset de todos os dispositivos
    .CLKSelectFast(CLKSelectFast),      // Para visualização
    .CLKSelectAuto(CLKSelectAuto),      // Para visualização
    .iKEY(iKEY),                        // controles dos clocks e reset
    .fdiv(iFdiv),                       // divisor da frequencia CLK = iCLK_50/fdiv
    .Timer(iTimer),                     // Timer de 10 segundos 
	.iBreak(wbreak)						// Break Point
);
/*--------------------------[MEMÓRIA]--------------------------*/
`ifndef MULTICICLO  // Uniciclo e Pipeline
DataMemory_Interface MEMDATA(
    .iCLK(CLK), 
	.iCLKMem(CLOCK_50), 
    // Barramento de dados
    .wReadEnable(DReadEnable), 
	.wWriteEnable(DWriteEnable),
    .wByteEnable(DByteEnable),
    .wAddress(DAddress), 
	.wWriteData(DWriteData), 
	.wReadData(DReadData)
);
CodeMemory_Interface MEMCODE(
    .iCLK(CLK), 
	.iCLKMem(CLOCK_50),
    // Barramento de Instrucoes
    .wReadEnable(IReadEnable), 
	.wWriteEnable(IWriteEnable),
    .wByteEnable(IByteEnable),
    .wAddress(IAddress), 
	.wWriteData(IWriteData), 
	.wReadData(IReadData)
);
`endif
/*------------------------[PROCESSADOR]------------------------*/
CPU CPU0 (
    .iCLK(CLK),             				// Clock real do Processador
    .iCLK50(oCLK_50),       				// Clock 50MHz fixo, usado so na FPU Uniciclo
    .iRST(Reset),                           // Controle de reset
    .iInitialPC(wPCinicial),                // Endereço inicial do PC

    // Barramento Dados
    .DwReadEnable(DReadEnable), 
	.DwWriteEnable(DWriteEnable),
    .DwByteEnable(DByteEnable),
    .DwAddress(DAddress), 
	.DwWriteData(DWriteData),
	.DwReadData(DReadData),

    // Barramento Instrucoes
    .IwReadEnable(IReadEnable), 
	.IwWriteEnable(IWriteEnable),
    .IwByteEnable(IByteEnable),
    .IwAddress(IAddress), 
	.IwWriteData(IWriteData), 
	.IwReadData(IReadData),

    // Sinais de monitoramento
    .mPC(mPC),
    .mInstr(mInstr),
    .mDebug(mDebug),
	.mTypeSelect(mULAorFPULA),
    .mRegDispSelect(mRegDispSelect),
    .mRegDisp(mRegDisp),
    .mControlState(mControlState),
    .mVGASelect(mVGASelect),
    .mVGARead(mVGARead),
	.mRead1(mRead1),
	.mRead2(mRead2),
	.mRegWrite(mRegWrite),
	.mULA(mULA)
);

/*----------------------[BREAK INTERFACE]----------------------*/
Break_Interface  break0 (
    .iCLK_50(oCLK_50), 
	.iCLK(CLK), 
	.Reset(Reset),
    .oBreak(wbreak),
	.iKEY(iKEY),
	.iPC(mPC),
    //  Barramento Dados
    .wReadEnable(DReadEnable), 
	.wWriteEnable(DWriteEnable),
    .wByteEnable(DByteEnable),
    .wAddress(DAddress), 
	.wWriteData(DWriteData), 
	.wReadData(DReadData)
);
endmodule