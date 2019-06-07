`ifndef PARAM
    `include "../Parametros.v"
`endif

module BRANCH(
    input [4:0]     iCondition,
    input           iFlagN, iFlagV, iFlagC, iFlagZ, 
    output          oTakeBranch
);

wire ge = (iFlagN == iFlagV);

always @(*)
    begin
        case (iCondition)
            4'b0000:    oTakeBranch <= iFlagZ;                  // EQ
            4'b0001:    oTakeBranch <= ~iFlagZ;                 // NE
            4'b0010:    oTakeBranch <= iFlagC;                  // CS
            4'b0011:    oTakeBranch <= ~iFlagC;                 // MI
            4'b0100:    oTakeBranch <= iFlagN;                  // PL
            4'b0101:    oTakeBranch <= ~iFlagN;                 // VS
            4'b0110:    oTakeBranch <= iFlagV;                  // VC
            4'b0111:    oTakeBranch <= ~iFlagV;                 // HI
            4'b1000:    oTakeBranch <= (iFlagC & iFlagV);       // LS
            4'b1001:    oTakeBranch <= ~(iFlagC & iFlagV);      // GE
            4'b1010:    oTakeBranch <= ge;                      // GE
            4'b1011:    oTakeBranch <= ~ge;                     // LT
            4'b1100:    oTakeBranch <= (iFlagZ & ge);           // GT
            4'b1101:    oTakeBranch <= ~(iFlagZ & ge);          // LE
            4'b1110:    oTakeBranch <= 1'b1;                    // ALWAYS
            default:
                oTakeBranch <= 1'b0;
        endcase
    end

endmodule