module fft_tb (

);

/*
0 1+1j 2+2j 3+3j 4+4j 5+5j 6+6j 7+7j
conj 


*/
logic signed[31:0] data_in_R [7:0] = '{112,96,80,64,48,32,16,0};  // { MSB-Lsb} {down-up}
logic signed [31:0] data_in_I [7:0] = '{112,96,80,64,48,32,16,0};
logic signed [31:0] Real [7:0],Imag [7:0];
reg clk,rst,start;
IFFT_TOP dut (
.data_in_R_in (data_in_R),
.data_in_I_in (data_in_I),
.clk(clk),
.rst(rst),
.start(start),


.Real_out(Real),
.Imag_out(Imag)
);


always #1ns clk =!clk;

initial
begin
clk=0;
rst=0;
#10;
rst=1;
start=1;
repeat(5)
begin
	@ (posedge clk);
end
#1000;
$stop;

end
endmodule