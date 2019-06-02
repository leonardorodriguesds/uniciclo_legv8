`ifndef PARAM
	`include "../Parametros.v"
`endif


module SIGNAL_EXTEND (
    input [31:0] iInstr,
    output [63:0] oImmediateExtended
);

wire [10:0] opcode;
wire [11:0] I_immediate;
wire [8:0]  D_immediate;
wire [25:0] B_immediate;
wire [18:0] CB_immediate;

assign opcode           = iInstr[31:21];
assign I_immediate      = iInstr[21:10];
assign D_immediate      = iInstr[20:12];
assign B_immediate      = iInstr[25:0];
assign CB_immediate     = iInstr[23:5];
// assign IW_immediate     = iInstr[20:5];

always @(*)
    begin
        casez (opcode)
            /*
                É IMPORTANTE MANTER POR ORDEM CRESCENTE DE DON'T CARE,
                OU POR ORDEM DECRESCENTE DE NÚMEROS DE BITS NO OPCODE;
            */
            OPC_D_LDUR,
            OPC_D_STUR,
            OPC_D_STURB,
            OPC_D_LDURB,
            OPC_D_STURH,
            OPC_D_LDURH,
            OPC_D_STURW,
            OPC_D_LDURSW,
            OPC_D_STXR,
            OPC_D_LDXR,
            OPC_D_LDURD,
            OPC_D_STURD:
                oImmediateExtended <= {{55{D_immediate[8]}}, D_immediate};
            
            OPC_I_ADDI,
            OPC_I_SUBI,
            OPC_I_ANDI,
            OPC_I_ORRI,
            OPC_I_ADDIS,
            OPC_I_EORI,
            OPC_I_SUBIS,
            OPC_I_ANDIS:
                oImmediateExtended <= {52'b0, I_immediate};

            OPC_B_B:
                oImmediateExtended <= {{36{B_immediate[25]}}, B_immediate, 2'b00};

            OPC_CB_CBZ,
            OPC_CB_CBNZ,
            OPC_CB_BCOND:
                oImmediateExtended <= {{43{CB_immediate[18]}}, CB_immediate, 2'b00};

            default:
                oImmediateExtended <= 62'd0;
        endcase
    end

endmodule