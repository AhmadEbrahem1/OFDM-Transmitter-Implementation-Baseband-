module Butterfly_PU #(parameter Data_Width = 32)(
input			[Data_Width-1:0] 		in0_R,in0_I,
input			[Data_Width-1:0]		in1_R,in1_I,


output	wire	[Data_Width-1:0]		out0_R,out0_I,
output	wire	[Data_Width-1:0]		out1_R,out1_I
		






);



assign out0_R =	in0_R + in1_R ;

assign out0_I =	in0_I + in1_I ;

assign out1_R =	in0_R - in1_R ;

assign out1_I =	in0_I - in1_I ;









endmodule