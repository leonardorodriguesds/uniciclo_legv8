`ifndef PARAM
	`include "../Parametros.v"
`endif

module BRANCH(
    input [4:0]     iCondition,
    input           iFlagN, iFlagV, iFlagC, iFlagZ, 
    output          oTakeBranch
);

always @(*)
    begin
        case (iCondition)
            default:
                oTakeBranch <= 0;
        endcase
    end

endmodule