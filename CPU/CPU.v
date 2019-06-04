/* Definicao do processador */
`ifndef PARAM
	`include "../Parametros.v"
`endif


module CPU (
    input  wire        iCLK, iCLK50, iRST,
    input  wire [31:0] iInitialPC,
	 
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
	output wire [31:0] mULA,	 
	 
    /*------- BARRAMENTO DE DADOS -------*/
    input  wire [31:0] DwReadData,
    output wire        DwReadEnable, DwWriteEnable,
    output wire [3:0]  DwByteEnable,
    output wire [31:0] DwAddress,
    output wire [31:0] DwWriteData,

    /*------- BARRAMENTO DE INSTRUÇOES -------*/
    input  wire [31:0] IwReadData,
    output wire        IwReadEnable, IwWriteEnable,
    output wire [3:0]  IwByteEnable,
	output wire [31:0] IwAddress,
    output wire [31:0] IwWriteData
);

`ifdef UNICICLO
assign mControlState    = 6'b000000;
DATAPATH_UNI Processor (
    .iCLK(iCLK),
    .iCLK50(iCLK50),
    .iRST(iRST),
    .iInitialPC(iInitialPC),
	
	/*------- MONITORAMENTO -------*/
    .mPC(mPC),
    .mInstr(mInstr),
	.mULAorFPULA(mULAorFPULA),
    .mDebug(mDebug),
    .mRegDispSelect(mRegDispSelect),
    .mRegDisp(mRegDisp),
    .mVGASelect(mVGASelect),
    .mVGARead(mVGARead),
	.mRead1(mRead1),
	.mRead2(mRead2),
	.mRegWrite(mRegWrite),
	.mULA(mULA),
	
    /*------- BARRAMENTO DE DADOS -------*/
    .DwReadEnable(DwReadEnable), 
    .DwWriteEnable(DwWriteEnable),
    .DwByteEnable(DwByteEnable),
    .DwWriteData(DwWriteData),
    .DwReadData(DwReadData),
    .DwAddress(DwAddress),
	 
    /*------- BARRAMENTO DE INSTRUÇOES -------*/
    .IwReadEnable(IwReadEnable), 
	.IwWriteEnable(IwWriteEnable),
    .IwByteEnable(IwByteEnable),
    .IwWriteData(IwWriteData),
    .IwReadData(IwReadData),
	.IwAddress(IwAddress)
);
 `endif
 
 endmodule