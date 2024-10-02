module complex_multiplier #(parameter Data_Width = 32)(

input 		[Data_Width-1:0]	Real_in,Imag_in,
input							clk,rst,
input 		 					select,
output reg 	[Data_Width-1:0]	Real_out,Imag_out		

);


reg [Data_Width-1:0]  r1 ,r2,r3,r4;  //N+1 
// constant multipler wont need n+1







Reg_enabled  reg_1 (
.data_in( (select==0)? (Real_in+Imag_in) : (Real_in-Imag_in ) ),
.clk(clk),
.rst(rst),
.en(1'b1),
.data_out(r1)	
);

Reg_enabled  reg_2 (
.data_in((select==0)? ( Real_in-Imag_in )  : ( Real_in+Imag_in )  ),
.clk(clk),
.rst(rst),
.en(1'b1),
.data_out(r2)	
);

Const_Multiplier  const_mul_1 (
.data_in(r1),
.clk(clk),
.rst(rst),
.output_multiply(r3)


);
Const_Multiplier  const_mul_2 (
.data_in(r2),
.clk(clk),
.rst(rst),
.output_multiply(r4)


);
Reg_enabled   reg_3 (
.data_in((select==0)? ( r3 )  : ( 32'd0 - r3  ) ),
.clk(clk),
.rst(rst),
.en(1'b1),
.data_out(Real_out)	
);

Reg_enabled   reg_4 (
//.data_in( 2^Data_Width- r4    ),
.data_in( 32'd0- r4    ),
.clk(clk),
.rst(rst),
.en(1'b1),
.data_out(Imag_out)	
);
endmodule