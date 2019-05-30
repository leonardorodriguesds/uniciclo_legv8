`ifndef PARAM
	`include "../../Parametros.v"
`endif
 
 
 
module ALU_CONTROL (
	input [10:0]    iOPCODE,
    input [1:0]     iALUop,
    output [4:0]    oALUControl
);

always @(*)
    case (iALUop)
        2'b00:      oALUControl <= OPADD;
        2'b01:      oALUControl <= OPNULL;
        default:
				oALUControl <= FOPNULL;
            /*case (iOPCODE)
                oALUControl <= FOPNULL;
            endcase*/
    endcase

endmodule