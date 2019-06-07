/* Definicao do processador */
`ifndef PARAM
    `include "../Parametros.v"
`endif

module COMPUTER (
    input              CLOCK_50, iRST, iTimer, iCLKSelectAuto
    input  wire [7:0]  iFdiv,
    input  wire [3:0]  iKEY,
    input  wire [9:0]  iSW,
    /*------- MONITORAMENTO -------*/
    input  wire [4:0]  mRegDispSelect,
    input  wire [4:0]  mVGASelect,
    output wire [63:0] mPC, 
    output wire [31:0] mInstr,
    output wire [63:0] mDebug,
    output wire [63:0] mRegDisp,
    output wire [63:0] mVGARead,
    output wire [63:0] mRead1,
    output wire [63:0] mRead2,
    output wire [63:0] mRegWrite,
    output wire [63:0] mULA,
    output wire        mCLK, mCLKSelectFast, mCLKSelectAuto,
    output wire        mDwReadEnable, mDwWriteEnable,
    output wire        mIwReadEnable, mIwWriteEnable
);

/*------------------[FIOS E REGISTRADORES]------------------*/
// Controle do Clock
wire CLK, oCLK_50, oCLK_25, oCLK_100, oCLK_150, oCLK_200, oCLK_27, oCLK_18;
wire CLKSelectFast, CLKSelectAuto;
wire wBreak, iCReset;

//Barramento de Dados
wire [63:0] DAddress, DWriteData;
wire [63:0] DReadData;
wire        DWriteEnable, DReadEnable;
wire [ 3:0] DByteEnable;

//Barramento de Instrucoes
wire [63:0] IAddress, IWriteData;
wire [31:0] IReadData;
wire        IWriteEnable, IReadEnable;
wire [ 3:0] IByteEnable;

// Controle do PC
wire [63:0] wPCinicial;

// VGA
wire [4:0]  wVGASelectIn;
wire [63:0] wVGAReadIn;

assign wPCinicial = BEGINNING_TEXT;

// Monitoramento
assign wVGAReadIn       = mVGARead;
assign mVGASelect       = wVGASelectIn;
assign mCLK = CLK;
assign mCLKSelectFast   = CLKSelectFast;
assign mCLKSelectAuto   = CLKSelectAuto;
assign mDwReadEnable    = DWriteEnable;
assign mDReadEnable     = DReadEnable;
assign mIWriteEnable    = IWriteEnable;
assign mIReadEnable     = IReadEnable;
/*--------------------[INTERFACE DE CLOCK]---------------------*/
CLOCK_Interface CLOCK0(
    .iRST(iRST),
    .iCLKSelectAuto(iCLKSelectAuto),    // Alterna entre clock automático ou manual
    .iCLK_50(CLOCK_50),					// 50MHz
    .oCLK_50(oCLK_50),                  // 50MHz  <<  Que será usado em todos os dispositivos	 
    .oCLK_100(oCLK_100),                // 100MHz
    .oCLK_150(oCLK_150),
    .oCLK_200(oCLK_200),                // 200MHz Usado no SignalTap II
    .oCLK_25(oCLK_25),					// Usado na VGA
    .oCLK_27(oCLK_27),
    .oCLK_18(oCLK_18),					// Usado no Audio
    .CLK(CLK),                          // Clock da CPU
    .Reset(iCReset),                    // Reset de todos os dispositivos
    .CLKSelectFast(CLKSelectFast),      // Para visualização
    .CLKSelectAuto(CLKSelectAuto),      // Para visualização
    .iKEY(iKEY),                        // controles dos clocks e reset
    .fdiv(iFdiv),                       // divisor da frequencia CLK = iCLK_50/fdiv
    .Timer(iTimer),                     // Timer de 10 segundos 
    .iBreak(wBreak)						// Break Point
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
    .iRST(iCReset),                         // Controle de reset
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
    .mRegDispSelect(mRegDispSelect),
    .mRegDisp(mRegDisp),
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
    .Reset(iCReset),
    .oBreak(wBreak),
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