`ifndef PARAM
	`include "../Parametros.v"
`endif

module CODEMEMORY (
    input wire    			iCLK, iCLKMem,
    input wire    			wReadEnable, wWriteEnable,
    input wire  	[7:0]  	wByteEnable,
    input wire		[63:0] 	wAddress, wWriteData,
    output logic 	[31:0] 	wReadData
);

wire        wMemWriteMB0, wMemReadMB0;
wire [31:0] wMemDataMB0;
wire        is_usermem;
wire [63:0] usermem_add;

UserCodeBlock MB0 (
    .address(usermem_add[TEXT_WIDTH-1:2]),
    .byteena(wByteEnable),
    .clock(iCLKMem),
    .data(wWriteData),
    .wren(wMemWriteMB0),
	.rden(wMemReadMB0),
    .q(wMemDataMB0)
);

reg MemWritten;
initial MemWritten <= 1'b0;
always @(iCLK) 
    /* Evita escrever na memória 2x por ciclo de clock */
    MemWritten <= iCLK;

assign is_usermem   = wAddress >= BEGINNING_TEXT && wAddress <= END_TEXT;        // Programa usuario .text
assign usermem_add  = wAddress - BEGINNING_TEXT;
assign wMemReadMB0  = wReadEnable && is_usermem;   
assign wMemWriteMB0 = ~MemWritten && wWriteEnable && is_usermem;

always @(*)
    if(wReadEnable)
        begin
            if(is_usermem)
                wReadData = wMemDataMB0; 
            else
                wReadData = 32'hzzzzzzzz;
        end
    else
        wReadData = 32'hzzzzzzzz;
endmodule
