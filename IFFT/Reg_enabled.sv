module Reg_enabled #(parameter Data_Width = 32)(

input 		[Data_Width-1:0]	data_in,
input							clk,rst,en,
output reg 	[Data_Width-1:0]	data_out		

);




always @(posedge clk or negedge rst)
begin
	if(!rst)
	begin
		data_out<=0;
		
	end
	else
	begin
		if(en)
		begin
			data_out <= data_in;
		end
		else
		begin
			data_out <= data_out;
		end
	end
	
	
end
endmodule