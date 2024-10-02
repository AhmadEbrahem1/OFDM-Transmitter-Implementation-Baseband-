

module Const_Multiplier #(parameter Data_Width = 32)(  // x*0.707
    input signed   [Data_Width-1:0]  data_in,
    input                            clk, rst,
    output reg signed [Data_Width-1:0] output_multiply // width won't change as you multiply by < 1
);

wire	[Data_Width-1:0]	a,b,c,d,e;
reg		[Data_Width-1:0] r1,r2,r3,r4,r5;
/*
assign a = ( data_in[Data_Width-1] ==0 )? (data_in >>1):(  32'd0-(32'd0-data_in >>1)   ); 
assign b = ( data_in[Data_Width-1] ==0 )? (data_in >>3):(  32'd0-(32'd0-data_in >>3)   );
assign c = ( data_in[Data_Width-1] ==0 )? (data_in >>4):(  32'd0-(32'd0-data_in >>4)   );
assign d = ( data_in[Data_Width-1] ==0 )? (data_in >>6):(  32'd0-(32'd0-data_in >>6)   );
assign e = ( data_in[Data_Width-1] ==0 )? (data_in >>8):(  32'd0-(32'd0-data_in >>8)   );
*/

assign a = ( data_in[Data_Width-1] ==0 )? (data_in >>1):( -(-data_in >>1)   ); 
assign b = ( data_in[Data_Width-1] ==0 )? (data_in >>3):( -(-data_in >>3)   );
assign c = ( data_in[Data_Width-1] ==0 )? (data_in >>4):( -(-data_in >>4)   );
assign d = ( data_in[Data_Width-1] ==0 )? (data_in >>6):( -(-data_in >>6)   );
assign e = ( data_in[Data_Width-1] ==0 )? (data_in >>8):( -(-data_in >>8)   );

/*
// Arithmetic right shifts
assign a = data_in >>> 1; 
assign b = data_in >>> 3; 
assign c = data_in >>> 4; 
assign d = data_in >>> 6; 
assign e = data_in >>> 8; 


*/


Reg_enabled reg_1 (
.data_in(a+b),
.clk(clk),
.rst(rst),
.en(1'b1),
.data_out(r1)	
);

Reg_enabled reg_2 (
.data_in(c+d),
.clk(clk),
.rst(rst),
.en(1'b1),
.data_out(r2)	
);

Reg_enabled reg_3 (
.data_in(e),
.clk(clk),
.rst(rst),
.en(1'b1),
.data_out(r3)	
);



//////////////////////////////

Reg_enabled reg_4 (
.data_in(r1+r2),
.clk(clk),
.rst(rst),
.en(1'b1),
.data_out(r4)	
);


Reg_enabled reg_5 (
.data_in(r3),
.clk(clk),
.rst(rst),
.en(1'b1),
.data_out(r5)	
);



Reg_enabled reg_6 (
.data_in(r4+r5),
.clk(clk),
.rst(rst),
.en(1'b1),
.data_out(output_multiply)	
);





endmodule

