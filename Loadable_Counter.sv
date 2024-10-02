module Loadable_Counter #(parameter limit=8,count_width = 4)	(
input en,clk,rst,
output tc

);


reg [count_width-1:0] count;

wire done_flag;

always @(posedge clk or negedge rst)
begin

	if(!rst)
	begin
		count <=0 ;
	end
	else
	begin
		
		if(en)
		begin
			if(!done_flag)
				count <= count +1 ;
			else
				count <= count ;
		end
		else
		begin
			count <= 0 ;
		end
		
		
		
	end
	
	
end


assign done_flag = (count== limit) ?  1 : 0 ;
assign tc =done_flag;
endmodule





module Loadable_Counter_tb ;

reg en,clk,rst;
wire tc ;

always #1 clk =! clk;

Loadable_Counter dut (
en,clk,rst,tc
);

initial
begin
	en=0;
	clk=0;
	rst=0;
	#10;
	rst=1;
	
	en =1;
	
	#20;
	en=0;
	#10;
	$stop;
	
end
endmodule