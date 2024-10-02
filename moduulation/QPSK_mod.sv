module QPSK_mod #(parameter A=5*16,output_width=32,constelation_size=4) (
input 										in_bits,clk,en,rst,
output  reg signed [output_width-1:0]		real_num,imag_num




);
// in opertation enable is raised 1 clk cyvle erarlier

reg [$clog2(constelation_size)-1:0] bit_spliter ; // 1:0
reg	[$clog2(constelation_size):0]	bit_counter;
always @(posedge clk or negedge rst)
begin
	if(!rst)
	begin
		bit_spliter<=0;
	
	end
	else
	begin
		if(en)
		begin
			bit_spliter<={in_bits,bit_spliter[1]};
			
		end
		else
		begin
			bit_spliter<=bit_spliter;
			
		end
	end
	
end

always @(posedge clk or negedge rst)
begin
	if(!rst)
	begin
		
		bit_counter<=0;
	end
	else
	begin
		if(en)
		begin
			if(bit_counter != $clog2(constelation_size))
				bit_counter<=bit_counter+1;
			else
				bit_counter<=1;
		end
		else
		begin
			
			bit_counter<=0;
		end
	end
	
end


always @(posedge clk or negedge rst)
begin
	if(!rst)
	begin
		real_num <=0;
		imag_num <=0;
	end
	else
	begin
		if(en && bit_counter==$clog2(constelation_size))
		begin
			case(bit_spliter)
			2'b00: 
			begin
				real_num <=A;
				imag_num <=0;
			end
			2'b10:	//msb is 1
			begin
				real_num <=0;
				imag_num <=A;
			end
			2'b01:
			begin
				real_num <=0;
				imag_num <=-A;//-A  101  011
			end
			2'b11:
			begin
				real_num <=-A; //-A
				imag_num <=0;
			end
			default:
			begin
				real_num <=0;
				imag_num <=0;	
			end
			endcase
		end
		else
		begin
			real_num <=real_num;
			imag_num <=imag_num;
		end
		
	end	
end

endmodule

















module qpsk_mod_TB ();

reg in_bits,clk,en,rst;
wire [7:0]real_num,imag_num;

logic arr_Stream[$] ={0,1,1,0,1,1};
QPSK_mod dut (
in_bits,clk,en,rst,
real_num,imag_num
);
always #1 clk=!clk;
initial
begin

	rst=0;
	clk=0;
	en=1;
	in_bits=0;
	#10;
	rst =1;
	
	foreach (arr_Stream[i])
	begin
		in_bits<= arr_Stream[i];
		@(posedge clk);
	end
	#1
	$stop;
end



endmodule