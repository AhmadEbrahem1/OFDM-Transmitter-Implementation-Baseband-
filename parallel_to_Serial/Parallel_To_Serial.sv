module Parallel_To_Serial #(parameter reg_width=32,depth =10)(
input 	signed		[reg_width-1:0] parallel_data [depth-1:0],
input 								clk,rst,en,load,
output	wire signed  [reg_width-1:0]	serial_bits

);


reg signed		[reg_width-1:0] parallel_data_reg [depth-1:0];
always @(posedge clk or negedge rst)
begin
	if(!rst)
	begin
		foreach(parallel_data_reg[i])
			parallel_data_reg[i]<=0;
		
	end
	else
	begin
		if(en)
		begin
			if(load)
				foreach (parallel_data_reg[i])
                    parallel_data_reg[i] <= parallel_data[i];
			else
			begin
				
				for (int i = 0; i <depth-1; i = i + 1) 
				begin
					parallel_data_reg[i] <= parallel_data_reg[i+1];
				end
				 
			end
			

		end
		else
		begin
			
		end
	end
	
end


assign serial_bits = parallel_data_reg[0];
endmodule

module Parallel_To_Serial_tb() ;
reg signed		[31:0] parallel_data [7:0];
	reg						clk,rst,en,load;
wire signed  [31:0]	serial_bits;

Parallel_To_Serial dut (parallel_data,clk,rst,en,load,serial_bits);


always #1 clk=!clk;


initial
begin
	foreach(parallel_data[i])
		parallel_data[i]=0;
	clk=0;
	rst=0;
	en=0;
	load=0;
	#5;
	@(posedge clk);
	rst=1;
	
	parallel_data ={60,70,80,90,100,110,120,130};
	load=1;
	en=1;
	@(posedge clk);
	load=0;
	repeat(8)
	@(posedge clk);
	
	#20;
	$stop;
	
	
	
	
end
	

endmodule