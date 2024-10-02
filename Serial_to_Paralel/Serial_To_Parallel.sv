module Serial_To_Parallel #(parameter reg_width=32,depth =8) (
input	signed	[reg_width-1:0]		bit_Stream,
input								clk,rst,en,
output  reg signed	[reg_width-1:0]		parallel_out [depth-1:0],
output		reg						valid
);


reg [$clog2(depth):0] bit_count;
reg signed	[reg_width-1:0]		parallel_out_reg [depth-1:0];

always @(posedge clk or negedge rst )
begin
	if(~rst)
	begin
		foreach (parallel_out_reg[i])
		begin
			parallel_out_reg[i] <=0;
			//parallel_out[i] <= 0;
		end
		bit_count<=0;
		
	end
	else
	begin
		if(en)
		begin
			for (int i = 0; i < depth-1; i = i + 1) 
            begin
                parallel_out_reg[i] <= parallel_out_reg[i+1];
            end
			parallel_out_reg[depth-1] <= bit_Stream;
			//parallel_out_reg[reg_width-2:0] <= parallel_out_reg[reg_width-1:1]; //first in f o
			
			
            // Assign new data to the first element
            //parallel_out_reg[0] <= bit_Stream;
			
			
			
			
			if(bit_count != depth)
			begin
				bit_count<=bit_count+1;
				
				
			end
			else
			begin
				bit_count<=1;
				//parallel_out <= parallel_out_reg;
			end
		end
		else
		begin
				//ff stayes as old value
				bit_count<=0;
				
		end
	end
	
end	








//assign valid = (bit_count == depth)? 1:0 ;
/*
always @(*)
begin
	if(bit_count== depth)
		parallel_out = parallel_out_reg;
	else
		foreach (parallel_out[i])
			parallel_out[i]=0;
end
*/

always @(posedge clk or negedge rst)
begin
	if(!rst)
	begin
		valid <=0;
		foreach (parallel_out[i])
			parallel_out[i] <= 0;
	end
	else
	begin
		if(bit_count== depth)
		begin	
			parallel_out <= parallel_out_reg;
			valid <=1;
		
		end
		else
		begin
			valid <=0;
			
		end //stays the same
	end
	
	
	
end

endmodule



module Serial_To_Parallel_TB ();
reg signed  [31:0] bit_Stream;
reg clk,rst,en;
wire signed  [31:0] parallel_out [7:0];
wire valid;




Serial_To_Parallel dut (

.bit_Stream(bit_Stream),
.clk(clk),
.rst(rst),
.en(en),
.parallel_out(parallel_out),
.valid(valid)
);



always #1 clk=!clk;


initial
begin
	bit_Stream=0;
	clk=0;
	rst=0;
	en=0;
	#5;
	rst=1;
	// 5symbols:
	@ (posedge clk);
	en=1;
	bit_Stream =32'd5;
	
	@ (posedge clk);
	bit_Stream =32'd6;
	
	@ (posedge clk);
	bit_Stream =32'd7;
	
	@ (posedge clk);
	bit_Stream =32'd8;
	
	@ (posedge clk);
	bit_Stream =32'd9;
	
	@ (posedge clk);
	bit_Stream =32'd10;
	
	@ (posedge clk);
	bit_Stream =32'd11;

	@ (posedge clk);
	bit_Stream =32'd12;
	repeat (8)
	@ (posedge clk);
	bit_Stream =32'd13;
	
	@ (posedge clk);
	#20;$stop;
	
	
	
end
endmodule