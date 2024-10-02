module PG (
input start,stop,clk,rst,
output	reg q



);

always @(posedge clk or negedge rst)
begin
	if(!rst)
	begin
		q <=0;
	end
	else
	begin
		if(start==1)
			q<=1;
		else
			if(stop ==1)
				q <=0;
	end
	
	
	
end



endmodule