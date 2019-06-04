`ifndef PARAM
	`include "../Parametros.v"
`endif

/* Controlador da memoria de leitura */
/* define a partir do opcode qual o tipo de leitura Double word, word, half word ou byte */

module MEMLOAD(
	input [10:0] 		    iOpcode,
	input [63:0] 		    iData,
	output logic [63:0]     oData
);

always @(*) begin
	case (iOpcode)
		OPC_D_LDUR:
            oData <= iData;
        OPC_D_LDURB:
            oData <= {56'b0, iData[7:0]};
        OPC_D_LDURSB:
            oData <= {{56{iData[7]}}, iData[7:0]};
        OPC_D_LDURH:
            oData <= {48'b0, iData[15:0]};
        OPC_D_LDURSH:
            oData <= {{48{iData[15]}}, iData[15:0]};
        OPC_D_LDURSW:
            oData <= {{32{iData[31]}}, iData[31:0]};
        OPC_D_LDXR:
            oData <= iData;
		default:
            oData <= 32'b0;
	endcase
end

endmodule
