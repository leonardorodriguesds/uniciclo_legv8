`ifndef PARAM
	`include "../Parametros.v"
`endif

/* Controlador da memoria de escrita */
/* define a partir do opcode qual a forma de acesso a memoria double word, word, half word ou byte */

module MEMSTORE(
	input [10:0] 		    iOpcode,
	input [63:0] 		    iData,
	output logic [63:0]     oData,
    output logic [7:0]      oByteEnable
);

always @(*) 
    begin
        case (iOpcode)
            OPC_D_STURB:
                oData <= {56'b0, iData[7:0]};
            OPC_D_STURH:
                oData <= {48'b0, iData[15:0]};
            OPC_D_STURW:
                oData <= {32'b0, iData[31:0]};
            default:
                oData <= iData;
        endcase
    end

always @(*) 
    begin
        case (iOpcode)
            OPC_D_STUR: // double word
                oByteEnable <= 8'b11111111;
            OPC_D_STURW: // Word
                oByteEnable <= 8'b00001111;
            OPC_D_STURH: // Halfword
                oByteEnable <= 8'b00000011;
            OPC_D_STURB:
                oByteEnable <= 8'b00000001;
            default:
                oByteEnable <= 8'b00000000;
        endcase
    end
endmodule
