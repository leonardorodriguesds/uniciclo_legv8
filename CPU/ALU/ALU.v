/*
 * ALU
 *
 */
 
`ifndef PARAM
	`include "../Parametros.v"
`endif
 
 
 
module ALU (
	input logic 	    [4:0]  iControl,		// comentar para as análises individuais
	input logic signed  [63:0] iA, 
	input logic signed  [63:0] iB,
	output logic		[63:0] oResult,
	output logic      oZero
);

//	wire [4:0] iControl=OPMUL;		// Usado para as análises individuais


`ifndef RV32I
wire [123:0] mul, mulu, mulsu;
assign mul 	= iA * iB;
assign mulu = $unsigned(iA) * $unsigned(iB);
assign mulsu= $signed(iA) * $unsigned(iB);
`endif


always @(*)
begin
    case (iControl)
		OPAND:
			oResult  <= iA & iB;
		OPOR:
			oResult  <= iA | iB;
		OPXOR:
			oResult  <= iA ^ iB;
		OPADD:
			oResult  <= iA + iB;
		OPSUB:
			oResult  <= iA - iB;
		OPSLT:
			oResult  <= iA < iB;
		OPSLTU:
			oResult  <= $unsigned(iA) < $unsigned(iB);
		OPSLL:
			oResult  <= iA << iB[4:0];
		OPSRL:
			oResult  <= iA >> iB[4:0];
		OPSRA:
			oResult  <= iA >>> iB[4:0];
		OPLUI:
			oResult  <= iB;
			
`ifndef RV32I	//	Modulo de multiplicacao e divisao
		OPMUL:
			oResult  <= mul[63:0];
		OPMULH:
			oResult  <= mul[123:64];
		OPMULHU:
			oResult  <= mulu[123:64];
		OPMULHSU:
			oResult  <= mulsu[123:64];	
		OPDIV:
			oResult  <= iA / iB;
		OPDIVU:
			oResult  <= $unsigned(iA) / $unsigned(iB);
		OPREM:
			oResult  <= iA % iB;
		OPREMU:
			oResult  <= $unsigned(iA) % $unsigned(iB);		
`endif

		OPNULL:
			oResult  <= ZERO;
			
		default:
			oResult  <= ZERO;
    endcase
end

endmodule
