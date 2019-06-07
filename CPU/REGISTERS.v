`ifndef PARAM
    `include "../Parametros.v"
`endif


module REGISTERS (
    input wire 			iCLK, iRST, iRegWrite,
    input wire  [4:0] 	iReadRegister1, iReadRegister2, iWriteRegister,
    input wire  [63:0] 	iWriteData,
    output wire [63:0] 	oReadData1, oReadData2,

    // Controle para monitoramento
    input wire  [4:0] 	iVGASelect, iRegDispSelect,
    output reg  [63:0] 	oVGARead, oRegDisp
);

reg [63:0] registers[31:0];
reg [5:0] i;        // 6 bits para não dar warning

initial
    begin
        /* 
            Resetando todos os registradores
        */
        for (i = 0; i <= 31; i = i + 1'b1)
            registers[i] = 63'b0;
        registers[STACK_REG] = STACK_ADDRESS;
    end


// Para leitura
assign oReadData1 =	registers[iReadRegister1];
assign oReadData2 =	registers[iReadRegister2];

// Controle de monitoramento
assign oRegDisp 	=	registers[iRegDispSelect];
assign oVGARead 	=	registers[iVGASelect];


always @(negedge iCLK or posedge iRST)
    begin
        /* 
            Procedimento padrão a cada ciclo de clock
        */
        if (iRST)
            begin
                /* 
                    Resetando todos os registradores
                */
                for (i = 0; i <= 31; i = i + 1'b1) 
                    registers[i] <= 63'b0;
                registers[STACK_REG]   <= STACK_ADDRESS;
            end
        else
            begin
                i <= 6'bx; // para não dar warning
                if(iRegWrite && (iWriteRegister != ZERO_REG))
                    registers[iWriteRegister] <= iWriteData;
            end
    end
endmodule
