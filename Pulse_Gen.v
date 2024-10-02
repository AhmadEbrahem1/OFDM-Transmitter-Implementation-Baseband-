
module PULSE_GEN  (
input 	LVL_SIG,
input 					CLK, RST,
output 	wire			PULSE_SIG

);


reg PG_FF ;
always @(posedge CLK or negedge RST)
begin
	if(!RST)
	begin
		PG_FF <=0;
	end 
	else
	begin
		PG_FF <= LVL_SIG;
	end


end

assign PULSE_SIG= ~(PG_FF) & LVL_SIG ;


endmodule