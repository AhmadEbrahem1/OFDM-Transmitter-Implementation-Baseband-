 			

module IFFT_TOP #(parameter Data_Width = 32, FFT_size = 8)(
input 			signed	[Data_Width-1:0]	data_in_R_in [FFT_size-1:0],data_in_I_in [FFT_size-1:0],
input										clk,rst,start,


output	wire	signed	[Data_Width-1:0]	Real_out [FFT_size-1:0],
output	wire 	signed	[Data_Width-1:0]	Imag_out [FFT_size-1:0]

);


wire 	signed  [Data_Width-1:0]	data_in_R [FFT_size-1:0];
wire 	signed  [Data_Width-1:0]	data_in_I [FFT_size-1:0];
wire	signed	[Data_Width-1:0]	Real [FFT_size-1:0];
wire 	signed	[Data_Width-1:0]	Imag [FFT_size-1:0];
parameter w = Data_Width;


parameter c = $clog2(FFT_size); 
//parameter  f = FFT_size/2 ; // do it manulaaay ;
// 8 4 2 
parameter bit [7:0] f [1:0]   = '{8'd2, 8'd4};
// IFFT PART
assign data_in_R = data_in_R_in;
genvar i6;
generate
    for (i6 = 0; i6 < FFT_size; i6++) begin : negation_loop1
        assign data_in_I[i6] = -data_in_I_in[i6];
    end
endgenerate
assign Real_out= Real;


genvar i5;
generate
    for (i5 = 0; i5 < FFT_size; i5++) begin : negation_loop2
        assign Imag_out[i5] = -Imag[i5];
    end
endgenerate


wire [Data_Width*FFT_size-1:0] mid_wire_R [c-1:0] ; 
wire [Data_Width*FFT_size-1:0] mid_wire_R_new [c-1:0] ;  
 
wire [Data_Width*FFT_size-1:0] mid_wire_I [c-1:0] ;
wire [Data_Width*FFT_size-1:0] mid_wire_I_new [c-1:0] ;


generate
genvar  i;


  for (i = 0; i < c; i = i + 1) // 0 1 2 for c = 3
    begin:gen1
		
		if(i==0)
		begin
			
			// 1- inputs 
			
			//genvar z =0;
			//z=0;
			genvar k;
			//generate
			
			for(k=0 ; k<FFT_size/2;k=k+1)
			begin :gen2
			
				
				
				
				Butterfly_PU	pu_0	(
					.in0_R(data_in_R[k]),
					.in0_I(data_in_I[k]),
					
					.in1_R(data_in_R[k+f[0]]),
					.in1_I(data_in_I[k+f[0]]),
					
					
					.out0_R(mid_wire_R[0][2*k*w+(Data_Width-1):2*k*w]),
					.out0_I(mid_wire_I[0][2*k*w+(Data_Width-1):2*k*w]),
					
					.out1_R(mid_wire_R[0][(2*k+1)*w+(Data_Width-1):(2*k+1)*w]),
					.out1_I(mid_wire_I[0][(2*k+1)*w+(Data_Width-1):(2*k+1)*w])  // instead z = z+2
				
				);
				
				assign mid_wire_R_new[0][2*k*w+(Data_Width-1):2*k*w] = mid_wire_R[0][2*k*w+(Data_Width-1):2*k*w] ;
				assign mid_wire_I_new[0][2*k*w+(Data_Width-1):2*k*w] = mid_wire_I[0][2*k*w+(Data_Width-1):2*k*w] ;
				
				
				
				case(k)
				'd0:
				begin
					assign mid_wire_R_new[0][(2*k+1)*w+(Data_Width-1):(2*k+1)*w] = mid_wire_R[0][(2*k+1)*w+(Data_Width-1):(2*k+1)*w] ;
					assign mid_wire_I_new[0][(2*k+1)*w+(Data_Width-1):(2*k+1)*w] = mid_wire_I[0][(2*k+1)*w+(Data_Width-1):(2*k+1)*w] ;
					
				end
				'd1:
				begin
					complex_multiplier comp_mul_u0 (
					.Real_in(mid_wire_R[0][(2*k+1)*w+(Data_Width-1):(2*k+1)*w]),
					.Imag_in(mid_wire_I[0][(2*k+1)*w+(Data_Width-1):(2*k+1)*w]),
					.clk(clk),
					.rst(rst),
					.select(1'b0),
					.Real_out(mid_wire_R_new[0][(2*k+1)*w+(Data_Width-1):(2*k+1)*w]),
					.Imag_out(mid_wire_I_new[0][(2*k+1)*w+(Data_Width-1):(2*k+1)*w])
					
					
					
					);
				end
				'd2: //-j
				begin
					assign mid_wire_R_new[0][(2*k+1)*w+(Data_Width-1):(2*k+1)*w] = mid_wire_I[0][(2*k+1)*w+(Data_Width-1):(2*k+1)*w] ;
					assign mid_wire_I_new[0][(2*k+1)*w+(Data_Width-1):(2*k+1)*w] = 'd0- ( mid_wire_R[0][(2*k+1)*w+(Data_Width-1):(2*k+1)*w] ) ;
					
				end
				'd3:
				begin
					
					complex_multiplier comp_mul_u1 (
					.Real_in(mid_wire_R[0][(2*k+1)*w+(Data_Width-1):(2*k+1)*w]),
					.Imag_in(mid_wire_I[0][(2*k+1)*w+(Data_Width-1):(2*k+1)*w]),
					.clk(clk),
					.rst(rst),
					.select(1'b1),
					.Real_out(mid_wire_R_new[0][(2*k+1)*w+(Data_Width-1):(2*k+1)*w]),
					.Imag_out(mid_wire_I_new[0][(2*k+1)*w+(Data_Width-1):(2*k+1)*w])
					
					
					
					);
				
				end
				
				endcase
				
				
				
				
				
				
				
				
				
				
				
				
				
				
				
			end
			//endgenerate
		end
		
		else
		begin
			// 2 middle conncetion
			genvar x;
			for(x=0 ; x<FFT_size/2;x=x+1)
			begin :gen3
				// middle wires
				if(i==c-1)
				begin
					Butterfly_PU	pu_3	(
								.in0_R(mid_wire_R_new[i-1][x*w+(Data_Width-1):x*w]),
								.in0_I(mid_wire_I_new[i-1][x*w+(Data_Width-1):x*w]),
								
								.in1_R(mid_wire_R_new[i-1][(x+f[0])*w+(Data_Width-1):(x+f[0])*w]),
								.in1_I(mid_wire_I_new[i-1][(x+f[0])*w+(Data_Width-1):(x+f[0])*w]),
								
								
								.out0_R(mid_wire_R[i][2*x*w+(Data_Width-1):2*x*w]),
								.out0_I(mid_wire_I[i][2*x*w+(Data_Width-1):2*x*w]),
												
								.out1_R(mid_wire_R[i][(2*x+1)*w+(Data_Width-1):(2*x+1)*w]),
								.out1_I(mid_wire_I[i][(2*x+1)*w+(Data_Width-1):(2*x+1)*w])  // instead z = z+2
							
							);
						assign  mid_wire_R_new[i][2*x*w+(Data_Width-1):2*x*w] =mid_wire_R[i][2*x*w+(Data_Width-1):2*x*w];
						assign  mid_wire_I_new[i][2*x*w+(Data_Width-1):2*x*w] =mid_wire_I[i][2*x*w+(Data_Width-1):2*x*w];
					
					
					
					
							
				end
				else
				begin
				
				
					if(x<f[i-1] || x-f[i-1] >=f[i-1])
					//if(x==f[i-1])
					begin
						Butterfly_PU	pu_1	(
								.in0_R(mid_wire_R_new[i-1][x*w+(Data_Width-1):x*w]),
								.in0_I(mid_wire_I_new[i-1][x*w+(Data_Width-1):x*w]),
								
								.in1_R(mid_wire_R_new[i-1][(x+f[i-1])*w+(Data_Width-1):(x+f[i-1])*w]),
								.in1_I(mid_wire_I_new[i-1][(x+f[i-1])*w+(Data_Width-1):(x+f[i-1])*w]),
								
								
								.out0_R(mid_wire_R[i][2*x*w+(Data_Width-1):2*x*w]),
								.out0_I(mid_wire_I[i][2*x*w+(Data_Width-1):2*x*w]),
												
								.out1_R(mid_wire_R[i][(2*x+1)*w+(Data_Width-1):(2*x+1)*w]),
								.out1_I(mid_wire_I[i][(2*x+1)*w+(Data_Width-1):(2*x+1)*w])  // instead z = z+2
							
							);
							
						assign  mid_wire_R_new[i][2*x*w+(Data_Width-1):2*x*w] =mid_wire_R[i][2*x*w+(Data_Width-1):2*x*w];
						assign  mid_wire_I_new[i][2*x*w+(Data_Width-1):2*x*w] =mid_wire_I[i][2*x*w+(Data_Width-1):2*x*w];
						
						
						
						
							/*
							if(x<f[i])
							begin
								//if((2**i) * x ==0)
								//begin
									assign  mid_wire_R_new[i][(2*x+1)*w+7:(2*x+1)*w]=mid_wire_R[i][(2*x+1)*w+7:(2*x+1)*w];
									assign  mid_wire_I_new[i][(2*x+1)*w+7:(2*x+1)*w]=mid_wire_I[i][(2*x+1)*w+7:(2*x+1)*w];
									
									
								//end
								if((2**i) * x ==1)
								begin
									
									complex_multiplier comp_mul_u2 (
									.Real_in(mid_wire_R[i][(2*x+1)*w+7:(2*x+1)*w]),
									.Imag_in(mid_wire_I[i][(2*x+1)*w+7:(2*x+1)*w]),
									.clk(clk),
									.rst(rst),
									.select(1'b0),
									.Real_out(mid_wire_R_new[i][(2*x+1)*w+7:(2*x+1)*w]),
									.Imag_out(mid_wire_I_new[i][(2*x+1)*w+7:(2*x+1)*w])
									);
									
									
									
									
									
									
								end
								if((2**i) * x ==2)
								begin
									assign  mid_wire_R_new[i][(2*x+1)*w+7:(2*x+1)*w]=mid_wire_I[i][(2*x+1)*w+7:(2*x+1)*w];
									assign  mid_wire_I_new[i][(2*x+1)*w+7:(2*x+1)*w]='d0- ( mid_wire_R[i][(2*x+1)*w+7:(2*x+1)*w] );
									
								end
								if((2**i) * x ==3)
								begin
									complex_multiplier comp_mul_u3 (
									.Real_in(mid_wire_R[i][(2*x+1)*w+7:(2*x+1)*w]),
									.Imag_in(mid_wire_I[i][(2*x+1)*w+7:(2*x+1)*w]),
									.clk(clk),
									.rst(rst),
									.select(1'b1),
									.Real_out(mid_wire_R_new[i][(2*x+1)*w+7:(2*x+1)*w]),
									.Imag_out(mid_wire_I_new[i][(2*x+1)*w+7:(2*x+1)*w])
									);
									
									
									
								end
								
								
								
							end
							else
							begin
		
								if((2**i) * ( x%f[i] ) ==0)
								begin
									assign  mid_wire_R_new[i][(2*x+1)*w+7:(2*x+1)*w]=mid_wire_R[i][(2*x+1)*w+7:(2*x+1)*w];
									assign  mid_wire_I_new[i][(2*x+1)*w+7:(2*x+1)*w]=mid_wire_I[i][(2*x+1)*w+7:(2*x+1)*w];
									
									
								end
								if((2**i) * ( x%f[i] ) ==1)
								begin
									
									complex_multiplier comp_mul_u4 (
									.Real_in(mid_wire_R[i][(2*x+1)*w+7:(2*x+1)*w]),
									.Imag_in(mid_wire_I[i][(2*x+1)*w+7:(2*x+1)*w]),
									.clk(clk),
									.rst(rst),
									.select(1'b0),
									.Real_out(mid_wire_R_new[i][(2*x+1)*w+7:(2*x+1)*w]),
									.Imag_out(mid_wire_I_new[i][(2*x+1)*w+7:(2*x+1)*w])
									);
									
									
									
									
									
									
								end
								if((2**i) * ( x%f[i] ) ==2)
								begin
									assign  mid_wire_R_new[i][(2*x+1)*w+7:(2*x+1)*w]=mid_wire_I[i][(2*x+1)*w+7:(2*x+1)*w];
									assign  mid_wire_I_new[i][(2*x+1)*w+7:(2*x+1)*w]='d0- ( mid_wire_R[i][(2*x+1)*w+7:(2*x+1)*w] );
									
								end
								if((2**i) * ( x%f[i] ) ==3)
								begin
									complex_multiplier comp_mul_u5 (
									.Real_in(mid_wire_R[i][(2*x+1)*w+7:(2*x+1)*w]),
									.Imag_in(mid_wire_I[i][(2*x+1)*w+7:(2*x+1)*w]),
									.clk(clk),
									.rst(rst),
									.select(1'b1),
									.Real_out(mid_wire_R_new[i][(2*x+1)*w+7:(2*x+1)*w]),
									.Imag_out(mid_wire_I_new[i][(2*x+1)*w+7:(2*x+1)*w])
									);
									
									
									
								end
		
		
		
							end
							*/
							
							
						
							
							
							
							
							
							
							
							
							
							
							
							
							
							
					end
					else
					begin 
						Butterfly_PU	pu_2	(
								.in0_R(mid_wire_R_new[i-1][(x+f[i-1])*w+(Data_Width-1):(x+f[i-1])*w]),
								.in0_I(mid_wire_I_new[i-1][(x+f[i-1])*w+(Data_Width-1):(x+f[i-1])*w]),
								
								.in1_R(mid_wire_R_new[i-1][(x+2*f[i-1])*w+(Data_Width-1):(x+2*f[i-1])*w]),
								.in1_I(mid_wire_I_new[i-1][(x+2*f[i-1])*w+(Data_Width-1):(x+2*f[i-1])*w]),
								
								
								.out0_R(mid_wire_R[i][2*x*w+(Data_Width-1):2*x*w]),
								.out0_I(mid_wire_I[i][2*x*w+(Data_Width-1):2*x*w]),
												
								.out1_R(mid_wire_R[i][(2*x+1)*w+(Data_Width-1):(2*x+1)*w]),
								.out1_I(mid_wire_I[i][(2*x+1)*w+(Data_Width-1):(2*x+1)*w])  // instead z = z+2
							
							);
						
						assign  mid_wire_R_new[i][2*x*w+(Data_Width-1):2*x*w] =mid_wire_R[i][2*x*w+(Data_Width-1):2*x*w];
						assign  mid_wire_I_new[i][2*x*w+(Data_Width-1):2*x*w] =mid_wire_I[i][2*x*w+(Data_Width-1):2*x*w];
						
	
						/*
						if(i==c-1) // last branch no connection of twiddle
						begin
							//genvar z;
							//for(z=0 ; z<FFT_size/2;z=z+1)
							//begin :gen6
						
								assign mid_wire_R_new[i][(2*x+1)*w+7:(2*x+1)*w] =mid_wire_R[i][(2*x+1)*w+7:(2*x+1)*w];
								assign mid_wire_I_new[i][(2*x+1)*w+7:(2*x+1)*w] =mid_wire_I[i][(2*x+1)*w+7:(2*x+1)*w];
							//end
							
						end
						else
						begin
						
							
							if(x<f[i])
							begin
								if((2**i) * x ==0)
								begin
									assign  mid_wire_R_new[i][(2*x+1)*w+7:(2*x+1)*w]=mid_wire_R[i][(2*x+1)*w+7:(2*x+1)*w];
									assign  mid_wire_I_new[i][(2*x+1)*w+7:(2*x+1)*w]=mid_wire_I[i][(2*x+1)*w+7:(2*x+1)*w];
									
									
								end
								if((2**i) * x ==1)
								begin
									
									complex_multiplier comp_mul_u6 (
									.Real_in(mid_wire_R[i][(2*x+1)*w+7:(2*x+1)*w]),
									.Imag_in(mid_wire_I[i][(2*x+1)*w+7:(2*x+1)*w]),
									.clk(clk),
									.rst(rst),
									.select(1'b0),
									.Real_out(mid_wire_R_new[i][(2*x+1)*w+7:(2*x+1)*w]),
									.Imag_out(mid_wire_I_new[i][(2*x+1)*w+7:(2*x+1)*w])
									);
									
									
									
									
									
									
								end
								if((2**i) * x ==2)
								begin
									assign  mid_wire_R_new[i][(2*x+1)*w+7:(2*x+1)*w]=mid_wire_I[i][(2*x+1)*w+7:(2*x+1)*w];
									assign  mid_wire_I_new[i][(2*x+1)*w+7:(2*x+1)*w]='d0- ( mid_wire_R[i][(2*x+1)*w+7:(2*x+1)*w] );
									
								end
								if((2**i) * x ==3)
								begin
									complex_multiplier comp_mul_u7(
									.Real_in(mid_wire_R[i][(2*x+1)*w+7:(2*x+1)*w]),
									.Imag_in(mid_wire_I[i][(2*x+1)*w+7:(2*x+1)*w]),
									.clk(clk),
									.rst(rst),
									.select(1'b1),
									.Real_out(mid_wire_R_new[i][(2*x+1)*w+7:(2*x+1)*w]),
									.Imag_out(mid_wire_I_new[i][(2*x+1)*w+7:(2*x+1)*w])
									);
									
									
									
								end
								
								
								
							end
							else
							begin
		
								if((2**i) * ( x%f[i] ) ==0)
								begin
									assign  mid_wire_R_new[i][(2*x+1)*w+7:(2*x+1)*w]=mid_wire_R[i][(2*x+1)*w+7:(2*x+1)*w];
									assign  mid_wire_I_new[i][(2*x+1)*w+7:(2*x+1)*w]=mid_wire_I[i][(2*x+1)*w+7:(2*x+1)*w];
									
									
								end
								if((2**i) * ( x%f[i] ) ==1)
								begin
									
									complex_multiplier comp_mul_u8 (
									.Real_in(mid_wire_R[i][(2*x+1)*w+7:(2*x+1)*w]),
									.Imag_in(mid_wire_I[i][(2*x+1)*w+7:(2*x+1)*w]),
									.clk(clk),
									.rst(rst),
									.select(1'b0),
									.Real_out(mid_wire_R_new[i][(2*x+1)*w+7:(2*x+1)*w]),
									.Imag_out(mid_wire_I_new[i][(2*x+1)*w+7:(2*x+1)*w])
									);
									
									
									
									
									
									
								end
								if((2**i) * ( x%f[i] ) ==2)
								begin
									assign  mid_wire_R_new[i][(2*x+1)*w+7:(2*x+1)*w]=mid_wire_I[i][(2*x+1)*w+7:(2*x+1)*w];
									assign  mid_wire_I_new[i][(2*x+1)*w+7:(2*x+1)*w]='d0- ( mid_wire_R[i][(2*x+1)*w+7:(2*x+1)*w] );
									
								end
								if((2**i) * ( x%f[i] ) ==3)
								begin
									complex_multiplier comp_mul_u9 (
									.Real_in(mid_wire_R[i][(2*x+1)*w+7:(2*x+1)*w]),
									.Imag_in(mid_wire_I[i][(2*x+1)*w+7:(2*x+1)*w]),
									.clk(clk),
									.rst(rst),
									.select(1'b1),
									.Real_out(mid_wire_R_new[i][(2*x+1)*w+7:(2*x+1)*w]),
									.Imag_out(mid_wire_I_new[i][(2*x+1)*w+7:(2*x+1)*w])
									);
									
									
									
								end
		
		
		
							end
							
						end
						*/	
							
							
							
							
							
							
							
							
							
							
							
					end
				end
				if(i==c-1) // last branch no connection of twiddle
				begin
					//genvar z;
					//for(z=0 ; z<FFT_size/2;z=z+1)
					//begin :gen6
				
						assign mid_wire_R_new[i][(2*x+1)*w+(Data_Width-1):(2*x+1)*w] =mid_wire_R[i][(2*x+1)*w+(Data_Width-1):(2*x+1)*w];
						assign mid_wire_I_new[i][(2*x+1)*w+(Data_Width-1):(2*x+1)*w] =mid_wire_I[i][(2*x+1)*w+(Data_Width-1):(2*x+1)*w];
					//end
					
				end
				
				
				else
				begin
				// if i ==1 and so on 
				
					if(x==0 || x==1)
					begin
						assign mid_wire_R_new[i][(2*x+1)*w+(Data_Width-1):(2*x+1)*w]= mid_wire_R[i][(2*x+1)*w+(Data_Width-1):(2*x+1)*w] ;
						assign mid_wire_I_new[i][(2*x+1)*w+(Data_Width-1):(2*x+1)*w]= mid_wire_I[i][(2*x+1)*w+(Data_Width-1):(2*x+1)*w] ;
								
					end
					if(x==2 || x==3)
					begin
						assign  mid_wire_R_new[i][(2*x+1)*w+(Data_Width-1):(2*x+1)*w]=mid_wire_I[i][(2*x+1)*w+(Data_Width-1):(2*x+1)*w];
						assign  mid_wire_I_new[i][(2*x+1)*w+(Data_Width-1):(2*x+1)*w]='d0- ( mid_wire_R[i][(2*x+1)*w+(Data_Width-1):(2*x+1)*w] );
					end
				end
			
			//f = (f/2) ;
			end
			
			
			
			
			
		
			
			
			
			
			
			
			
			
		
		end
		
		
		
		
    end

endgenerate





	// bit reversal at output 
		assign Real[0] = mid_wire_R_new[c-1][(Data_Width-1):0]  ;
		assign Imag[0] = mid_wire_I_new[c-1][(Data_Width-1):0]  ;
	
	
		assign Real[1] = mid_wire_R_new[c-1][4*w+(Data_Width-1):4*w]  ;
		assign Imag[1] = mid_wire_I_new[c-1][4*w+(Data_Width-1):4*w]  ;
	
	
		assign Real[2] = mid_wire_R_new[c-1][2*w+(Data_Width-1):2*w]  ;
		assign Imag[2] = mid_wire_I_new[c-1][2*w+(Data_Width-1):2*w]  ;
	
	
	
		assign Real[3] = mid_wire_R_new[c-1][6*w+(Data_Width-1):6*w]  ;
		assign Imag[3] = mid_wire_I_new[c-1][6*w+(Data_Width-1):6*w]  ;
	
	
	
		assign Real[4] = mid_wire_R_new[c-1][1*w+(Data_Width-1):1*w]  ;
		assign Imag[4] = mid_wire_I_new[c-1][1*w+(Data_Width-1):1*w]  ;
	
	
	
		assign Real[5] = mid_wire_R_new[c-1][5*w+(Data_Width-1):5*w]  ;
		assign Imag[5] = mid_wire_I_new[c-1][5*w+(Data_Width-1):5*w]  ;
	
	
		assign Real[6] = mid_wire_R_new[c-1][3*w+(Data_Width-1):3*w]  ;
		assign Imag[6] = mid_wire_I_new[c-1][3*w+(Data_Width-1):3*w]  ;
	
	
		assign Real[7] = mid_wire_R_new[c-1][7*w+(Data_Width-1):7*w]  ;
		assign Imag[7] = mid_wire_I_new[c-1][7*w+(Data_Width-1):7*w]  ;
	


/*
		assign Real[0] = mid_wire_R_new[0][(Data_Width-1):0]  ;
		assign Imag[0] = mid_wire_I_new[0][(Data_Width-1):0]  ;
	
	
		assign Real[1] = mid_wire_R_new[0][1*w+(Data_Width-1):1*w]  ;
		assign Imag[1] = mid_wire_I_new[0][1*w+(Data_Width-1):1*w]  ;
	
	
		assign Real[2] = mid_wire_R_new[0][2*w+(Data_Width-1):2*w]  ;
		assign Imag[2] = mid_wire_I_new[0][2*w+(Data_Width-1):2*w]  ;
	
	
	
		assign Real[3] = mid_wire_R_new[0][3*w+(Data_Width-1):3*w]  ;
		assign Imag[3] = mid_wire_I_new[0][3*w+(Data_Width-1):3*w]  ;
	
	
	
		assign Real[4] = mid_wire_R_new[0][4*w+(Data_Width-1):4*w]  ;
		assign Imag[4] = mid_wire_I_new[0][4*w+(Data_Width-1):4*w]  ;
	
	
	
		assign Real[5] = mid_wire_R_new[0][5*w+(Data_Width-1):5*w]  ;
		assign Imag[5] = mid_wire_I_new[0][5*w+(Data_Width-1):5*w]  ;
	
	
		assign Real[6] = mid_wire_R_new[0][6*w+(Data_Width-1):6*w]  ;
		assign Imag[6] = mid_wire_I_new[0][6*w+(Data_Width-1):6*w]  ;
	
	
		assign Real[7] = mid_wire_R_new[0][7*w+(Data_Width-1):7*w]  ;
		assign Imag[7] = mid_wire_I_new[0][7*w+(Data_Width-1):7*w]  ;
	*/
endmodule