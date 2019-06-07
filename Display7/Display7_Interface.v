module Display7_Interface (
	output [6:0] HEX0_D, HEX1_D, HEX2_D, HEX3_D, HEX4_D, HEX5_D,
	input [63:0] iOutput,
    input [ 1:0] iSelect
);

wire [23:0] wDisplay;

always @(*)
    case (iSelect)
        2'b00:      wDisplay <= iOutput[23:0];
        2'b01:      wDisplay <= iOutput[47:24];
        2'b10:      wDisplay <= iOutput[63:32];
        2'b11:      wDisplay <= {iOutput[63:56], iOutput[16:0]};
        default:
            wDisplay <= iOutput[23:0];
    endcase

Decoder7 Dec0 (
	.In(wDisplay[3:0]),
	.Out(HEX0_D)
);

Decoder7 Dec1 (
	.In(wDisplay[7:4]),
	.Out(HEX1_D)
);

Decoder7 Dec2 (
	.In(wDisplay[11:8]),
	.Out(HEX2_D)
);

Decoder7 Dec3 (
	.In(wDisplay[15:12]),
    .Out(HEX3_D)
);

Decoder7 Dec4 (
	.In(wDisplay[19:16]),
	.Out(HEX4_D)
);

Decoder7 Dec5 (
	.In(wDisplay[23:20]),
	.Out(HEX5_D)
);

	
endmodule