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
            case (iOPCODE)
                OPC_R_ADD,
                OPC_I_ADDI,
                OPC_I_ADDIS:
                    oALUControl <= OPADD;
                OPC_R_SUB,
                OPC_R_SUBI,
                OPC_R_SUBIS:
                    oALUControl <= OPSUB;
                OPC_R_AND,
                OPC_R_ANDI,
                OPC_I_ANDIS:
                    oALUControl <= OPAND;
                OPC_R_ORR,
                OPC_I_ORRI:
                    oALUControl <= OPOR;
                OPC_R_MUL:
                    oALUControl <= OPMUL;
                OPC_R_SMULH:
                    oALUControl <= OPMULH;
                OPC_R_UMULH:
                    oALUControl <= OPMULHU;
                OPC_R_MULHSU:
                    oALUControl <= OPMULHSU;
                OPC_R_SDIV:
                    oALUControl <= OPDIV;
                OPC_R_UDIV:
                    oALUControl <= OPDIVU;
                OPC_R_REM:
                    oALUControl <= OPREM;
                OPC_R_REMU:
                    oALUControl <= OPREMU;
                OPC_R_EOR,
                OPC_I_EORI:
                    oALUControl <= OPXOR;
                default:
                    oALUControl <= FOPNULL;
            endcase
    endcase

endmodule