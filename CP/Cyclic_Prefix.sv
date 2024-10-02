module Cyclic_Prefix#(parameter data_width =32, in_depth =8,output_depth=10,delta = output_depth- in_depth )(
input 		signed	[data_width-1:0] data_in	[in_depth-1:0],
input 							 		clk,rst,en,
output 	reg signed	[data_width-1:0] data_out	[output_depth-1:0]


);


always @(posedge clk or negedge rst)
begin
	if(!rst)
	begin
		foreach (data_out[i]) 
			data_out[i] <= 0;
	end
	else
	begin
		if(en)
		begin
			foreach (data_out[i])
			begin
				if(i<delta)
				begin
					data_out[i] <= data_in[in_depth - delta+i];
				end
				else
				begin
					data_out[i] <= data_in[i-delta];
					
				end
				
			end
		end
		else
		begin
			foreach (data_out[i]) 
                    data_out[i] <= data_out[i]; 
			
		end
	end
	
end




endmodule


module tb_Cyclic_Prefix;

    parameter int data_width = 32;
    parameter int in_depth = 8;
    parameter int output_depth = 10;

    reg signed [data_width-1:0] data_in[in_depth-1:0];
    reg  clk, rst, en;
    wire signed [data_width-1:0] data_out[output_depth-1:0];

    // Instantiate the Cyclic Prefix module
    Cyclic_Prefix #(data_width, in_depth, output_depth) cp_inst (
        .data_in(data_in),
        .clk(clk),
        .rst(rst),
        .en(en),
        .data_out(data_out)
    );

    // Clock generation
    initial begin
        clk = 0;
        forever #5 clk = ~clk; // 10-time unit clock period
    end

    initial begin
        // Test case setup
        rst = 0; en = 0;
        data_in = '{32'sd7, 32'sd6, 32'sd5, 32'sd4, 32'sd3, 32'sd2, 32'sd1, 32'sd0}; // Example data

        // Reset the module
        #10 rst = 1; // Assert reset


        // Enable the module
        #10 en = 1;

        // Wait for a few clock cycles
        #30;

        // Disable and check outputs
        en = 0;
        #20;

        // Print results
        $display("Output Data with CP:");
        foreach (data_out[i]) begin
            $display("data_out[%0d] = %d", i, data_out[i]);
        end

        // Finish simulation
        #10 $finish;
    end
endmodule
