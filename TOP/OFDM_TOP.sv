module OFDM_TOP  #(parameter Data_Width=32,FFT_size=8,cycle_prefix = 2)(
input start,serial_data,clk,rst,en_qpsk,
output  signed [Data_Width-1:0]	serial_bits_Real ,
output  signed [Data_Width-1:0]	serial_bits_Imag 






);




wire q1,q2,q3,tc2,tc3,tc4,ss,ss2;

wire q,en_IFFT,en_ps,en_sp,en_cp;

Reg_enabled #(.Data_Width(1))
 reg_1 (
.data_in(start),
.clk(clk),
.rst(rst),
.en(1'b1),
.data_out(ss)	
);
Reg_enabled #(.Data_Width(1))
 reg_2 (
.data_in(ss),
.clk(clk),
.rst(rst),
.en(1'b1),
.data_out(ss2)	
);


// enabke s/p after 2 clks
PG PG_1 (
.start(ss2),
.stop(tc),
.clk(clk),
.rst(rst),
.q(en_sp)

);


Loadable_Counter #(
    .limit(16),           // Set width to 32 bits
    .count_width(8)       // Set Cyclic Prefix length to 128
)  Loadable_Counter_1 (
.en(en_sp),
.clk(clk),
.rst(rst),
.tc(tc)




);





PG PG_2 (
.start(tc),
.stop(tc2),
.clk(clk),
.rst(rst),
.q(en_IFFT)

);


Loadable_Counter  #(
    .limit(5),           // Set width to 32 bits
    .count_width(4)       // Set Cyclic Prefix length to 128
)  Loadable_Counter_2 
 (
.en(en_IFFT),
.clk(clk),
.rst(rst),
.tc(tc2)




);



PG PG_3 (
.start(tc2),
.stop(tc3),
.clk(clk),
.rst(rst),
.q(en_cp)

);


Loadable_Counter   #(
    .limit(1),           // Set width to 32 bits
    .count_width(3)       // Set Cyclic Prefix length to 128
)  Loadable_Counter_3
 (
.en(en_cp),
.clk(clk),
.rst(rst),
.tc(tc3)




);


PG PG_4 (
.start(tc3),
.stop(tc4),
.clk(clk),
.rst(rst),
.q(en_ps)

);


Loadable_Counter #(
    .limit(8),           // Set width to 32 bits
    .count_width(2)       // Set Cyclic Prefix length to 128
)  Loadable_Counter_4 
 (
.en(en_ps),
.clk(clk),
.rst(rst),
.tc(tc4)




);






wire signed [Data_Width-1:0]		real_num,imag_num ;
QPSK_mod QPSK_mod_inst (
.in_bits(serial_data),
.clk(clk),
.en(en_qpsk),
.rst(rst),
.real_num(real_num),
.imag_num(imag_num)

);

wire	signed [Data_Width-1:0]	parallel_out_R [FFT_size-1:0] ;
wire	signed [Data_Width-1:0]	parallel_out_I [FFT_size-1:0] ;
wire valid_R ,valid_I;



wire divided_clk;
ClkDiv ClkDiv_inst (
.i_ref_clk(clk) , 
.i_rst(rst) ,     
.i_clk_en(1'b1),   
.i_div_ratio('d2), 
.o_div_clk(divided_clk)   


);



Serial_To_Parallel Serial_To_Parallel_real_inst (
.bit_Stream(real_num),
.clk(divided_clk),
.rst(rst),
.en(en_sp),
.parallel_out(parallel_out_R),
.valid(valid_R)
);


Serial_To_Parallel Serial_To_Parallel_Imag_inst (
.bit_Stream(imag_num),
.clk(divided_clk),
.rst(rst),
.en(en_sp),
.parallel_out(parallel_out_I),
.valid(valid_I)
);

wire signed [Data_Width-1:0]	ifft_real_out [FFT_size-1:0];
wire signed [Data_Width-1:0]	ifft_imag_out [FFT_size-1:0];

IFFT_TOP IFFT_inst (

.data_in_R_in(parallel_out_R) ,
.data_in_I_in(parallel_out_I) ,
.clk(clk),
.rst(rst),
.start(en_IFFT),
.Real_out(ifft_real_out),
.Imag_out(ifft_imag_out)




);

wire signed [Data_Width-1:0]	 cycled_data_real [FFT_size+cycle_prefix-1:0];
wire signed [Data_Width-1:0]	 cycled_data_imag [FFT_size+cycle_prefix-1:0];


Cyclic_Prefix Cyclic_Prefix_real_inst (

.data_in(ifft_real_out)	,
.clk(clk),
.rst(rst),
.en(en_cp),
.data_out(cycled_data_real)


);




Cyclic_Prefix Cyclic_Prefix_imag_inst (

.data_in(ifft_imag_out)	,
.clk(clk),
.rst(rst),
.en(en_cp),
.data_out(cycled_data_imag)


);

wire load_p_S;
PULSE_GEN PULSE_GEN_inst (
.LVL_SIG(en_ps),
.CLK(clk),
.RST(rst),
.PULSE_SIG(load_p_S)
);



//wire [Data_Width-1:0]	serial_bits_Real ;
//wire [Data_Width-1:0]	serial_bits_Imag ;

Parallel_To_Serial Parallel_To_Serial_real_inst (
.parallel_data(cycled_data_real),
.clk(clk),
.rst(rst),
.en(en_ps),
.load(load_p_S),
.serial_bits(serial_bits_Real)


);



Parallel_To_Serial Parallel_To_Serial_imag_inst (
.parallel_data(cycled_data_imag),
.clk(clk),
.rst(rst),
.en(en_ps),
.load(load_p_S),
.serial_bits(serial_bits_Imag)


);

endmodule


module OFDM_TOP_TB();

reg  serial_data,clk,rst,en,en_sp,ps_load,start,en_qpsk;
wire  signed [31:0]	serial_bits_Real ;
wire  signed [31:0]	serial_bits_Imag ;


OFDM_TOP dut (start,serial_data,clk,rst,en_qpsk,serial_bits_Real,serial_bits_Imag);

always #1ns clk =! clk;
bit x []={0,1,0,1,0,1,1,1,0,0,1,0,1,1,0,1};
initial 
begin
	clk=0;
	start=0;
	en_qpsk=0;
	/*
	en=0;
	ps_load=0;
	en_sp=0;
	*/
	serial_data=0;
	rst=0;
	#15;
	@(negedge clk);
	rst =1;
	@(negedge clk);
	//fork
	//begin
		foreach (x[i])
		begin
			serial_data =x[i];
			if(i==0)
			begin
				start=1;
				en_qpsk=1;
			end
			else
				start=0;
			//en=1;
			//if(i==2)
				//en_sp=1;
			@(negedge clk);
		end
	//end
	/*
	begin
		@ (posedge dut.Serial_To_Parallel_real_inst.valid);
		repeat(6)
		@(posedge clk);
		ps_load=1;
		@(posedge clk);
		ps_load=0;
	end	
	join
	*/
	
	
	repeat(50)
		@(posedge clk);
	
	$stop;
	
	
end
endmodule