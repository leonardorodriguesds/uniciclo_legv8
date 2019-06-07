`ifndef PARAM
	`include "../../Parametros.v"
`endif
 
module ALU_CONTROL (
	input [10:0]    iOPCODE,
    input [ 5:0]    iShamt,
    input [1:0]     iALUop,
    output [4:0]    oALUControl
);

always @(*)
    case (iALUop)
        2'b00:      oALUControl <= OPADD;
        2'b01:      oALUControl <= OPNULL;
        2'b10:
            begin
                casez (iOPCODE)
                    OPC_R_ADD:
                        oALUControl <= OPADD;
                    OPC_R_SUB:
                        oALUControl <= OPSUB;
                    OPC_R_AND:
                        oALUControl <= OPAND;
                    OPC_R_ORR:
                        oALUControl <= OPOR;
                    OPC_R_MUL:
                        oALUControl <= OPMUL;
                    OPC_R_SMULH:
                        oALUControl <= OPMULH;
                    OPC_R_UMULH:
                        oALUControl <= OPMULHU;
                    OPC_R_MULHSU:
                        oALUControl <= OPMULHSU;
                    OPC_R_DIV:
                        begin
                            case (iShamt)
                                SHAMT_SDIV: oALUControl <= OPDIV;
                                SHAMT_UDIV: oALUControl <= OPDIVU;
                                default:
                                    oALUControl <= OPNULL;
                            endcase
                        end
                    
                    OPC_R_REM:
                        oALUControl <= OPREM;
                    OPC_R_REMU:
                        oALUControl <= OPREMU;
                    OPC_R_EOR:
                        oALUControl <= OPXOR;

                    OPC_I_ADDI,
                    OPC_I_ADDIS:
                        oALUControl <= OPADD;
                    OPC_I_SUBI,
                    OPC_I_SUBIS:
                        oALUControl <= OPSUB;
                    OPC_I_ANDI,
                    OPC_I_ANDIS:
                        oALUControl <= OPAND;
                    OPC_I_ORRI:
                        oALUControl <= OPOR;                
                    OPC_I_EORI:
                        oALUControl <= OPXOR;
                    default:
                        oALUControl <= OPNULL;
                endcase
            end
        default:
            oALUControl <= OPNULL;
    endcase
endmodule