/*
 TopDE
Adaptado para a versão ARMS UNICICLO v0 por
Leonardo Rodrigues de Souza         17/0060543

CONTROLE:
    SW[2:0] = Controla a divisão do CLK => CLK = (CLOCK_50 / SW[2:0] * 8);
    SW[7:3] = Seleciona o registrador que será exibido no display;
    SW[9:8] = Alterna o que será exibido no display entre:
        00 <= Instrução;
        01 <= Saída da ULA;
        10 <= Dado do registrador 1 apontado pela instrução;
        11 <= Registrador selecionado por SW[7:3];

    KEY[0] = Reseta o processador;
    KEY[1] = 
        SE NÃO ESTIVER EM CLOCK MANUAL:
            Alterna entre clock rápido ou lento;
        EM CLOCK MANUAL:
            Alterna o valor do bit 0 do controle do display;
    KEY[2] = 
        SE NÃO ESTIVER EM CLOCK MANUAL:
            Alterna entre clock automático ou manual;
        EM CLOCK MANUAL:
            Alterna o valor do bit 1 do controle do display;
    KEY[3] = CLOCK MANUAL;

CONTROLE DO DISPLAY:
    00 <= Exibe no display os bits de 23:0
    01 <= Exibe no display os bits de 47:24
    10 <= Exibe no display os bits de 63:32
    11 <= Exibe no display os bits de {{63:56}, {16:0}}
    Inicialmente começa em 00

SAÍDA:
    LEDR[0]     = Clock da CPU;
    LEDR[1]     = Sinal REGWRITE do Controle;
    LEDR[2]     = Se está sendo usado o clock manual;
    LEDR[3]     = Clock fast;
    LEDR[9:4]   = Representação binária do fator de divisão do clock;

*/
module TopDE (
    input CLK_50, 

    output      [6:0]  HEX0,
    output      [6:0]  HEX1,
    output      [6:0]  HEX2,
    output      [6:0]  HEX3,
    output      [6:0]  HEX4,
    output      [6:0]  HEX5,
	///////// KEY Push-Bottom /////////
    input       [3:0]  KEY,

    ///////// LEDR  LED Red/////////
    input       [9:0]  SW,
    
    // Monitoramento
    output wire [63:0] mPC, 
	output wire [31:0] mInstr,
	output wire [63:0] mDebug,
    output wire [63:0] mRegDisp,
    output wire [63:0] mVGARead,
	output wire [63:0] mRead1,
	output wire [63:0] mRead2,
	output wire [63:0] mRegWrite,
	output wire [63:0] mULA
    output wire        mCLK, mCLKSelectFast, mCLKSelectAuto
    output wire        mDwReadEnable, mDwWriteEnable,
    output wire        mIwReadEnable, mIwWriteEnable,
);

wire [ 7:0] wFdiv;
wire        wRST;

// Fios de monitoramento
wire [63:0] mPC, mDebug, mRegDisp, mVGARead, mRead1, mRead2, mRegWrite, mULA;
wire [31:0] mInstr;
wire [ 4:0] mRegDispSelect, mVGASelect;
wire        mCLK, mCLKSelectFast, mCLKSelectAuto;
wire        mDwReadEnable, mDwWriteEnable, mIwReadEnable, mIwWriteEnable;

// Controle do display
wire [63:0] wOutput;
wire [ 1:0] iSelect;

assign wRST             = KEY[0];

assign mRegDispSelect   = SW[7:3];
assign mVGASelect       = 5'b0;
assign wFdiv            = {2'b0, SW[2:0], 3'b0};

assign wCLKSelectAuto   = 1'b0;

assign wOutput          = SW[9:8] == 2'b00 ? mInstr : SW[9:8] == 2'b01 ? mULA : SW[9:8] == 2'b10? mRead1 : mRegDisp;
assign iSelect          = 2'b00;
/*------------------[COMPUTER]------------------*/
COMPUTER CPU(
    .CLOCK_50(CLK_50),
    .iRST(wRST),
    .iKEY(KEY),
    .iTimer(0),
    .iFdiv(wFdiv),
    .iSW(SW),

    // Monitoramento
    .mRegDispSelect(mRegDispSelect),
    .mVGASelect(mVGASelect),
    .mPC(mPC), 
	.mInstr(mInstr),
	.mDebug(mDebug),
    .mRegDisp(mRegDisp),
    .mVGARead(mVGARead),
	.mRead1(mRead1),
	.mRead2(mRead2),
	.mRegWrite(mRegWrite),
	.mULA(mULA),
    .mCLK(mCLK),
    .mCLKSelectFast(mCLKSelectFast),
    .mCLKSelectAuto(mCLKSelectAuto),
    .mDwReadEnable(mDwReadEnable),
    .mDwWriteEnable(mDwWriteEnable),
    .mIwReadEnable(mIwReadEnable),
    .mIwWriteEnable(mIwWriteEnable)
); 
/*------------------[LEDS]------------------*/
assign LEDG[0]      = mCLK;
assign LEDG[1]      = mRegWrite;
assign LEDR[2]      = mCLKSelectAuto;
assign LEDR[3]      = mCLKSelectFast;
assign LEDR[9:4]    = wFdiv;
/*------------------[CONTROLE]------------------*/
always @(mCLKSelectAuto and (posedge iKEY[1] or posedge iKEY[2] or posedge wRST))
    begin
        if (wRST)           iSelect <= 2'b0;
        else if (iKEY[1])   iSelect <= {iSelect[1], ~iSelect[0]};
        else if (iKEY[2])   iSelect <= {~iSelect[1], iSelect[0]};
    end
assign iSelect      = mCLKSelectAuto? iSelect : 2'b0;
/*------------------[DISPLAY]------------------*/
Display7_Interface Display70   (
    .HEX0_D(HEX0), 
	.HEX1_D(HEX1), 
	.HEX2_D(HEX2), 
	.HEX3_D(HEX3), 
	.HEX4_D(HEX4), 
	.HEX5_D(HEX5), 
	.iOutput(wOutput),
    .iSelect(iSelect)
);
endmodule