`ifndef PARAM
	`include "../Parametros.v"
`endif

module DATAMEMORY (
    input wire      			iCLK, iCLKMem,
    input wire       	 	    wReadEnable, wWriteEnable,
    input wire		[3:0]  	    wByteEnable,
    input wire		[63:0] 	    wAddress, wWriteData,
    output logic	[63:0] 	    wReadData
);


wire        wMemWriteMB0, wMemReadMB0;
wire [63:0] wMemDataMB0;
wire        is_usermem;
wire [63:0] usermem_add;
	 
UserDataBlock MB0 (
    .address(usermem_add[DATA_WIDTH-1:2]), // Memoria em words
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
                

assign is_usermem = wAddress >= BEGINNING_DATA  &&  wAddress <= END_DATA;       // Memoria usuario  .data
assign usermem_add =  wAddress - BEGINNING_DATA;
assign wMemReadMB0  = wReadEnable  && is_usermem;  
assign wMemWriteMB0 = ~MemWritten && wWriteEnable && is_usermem;              // Controle de escrita no MB0

always @(*)
    if(wReadEnable)
        begin
            if(is_usermem)  
                wReadData = wMemDataMB0;
            else
                wReadData = 64'hzzzzzzzzzzzzzzzz;
        end
    else
        wReadData = 64'hzzzzzzzzzzzzzzzz;

endmodule
