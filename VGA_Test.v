module VGA_Test(

	input CLK,
	output  reg [3:0]VGA_R,
	output  reg [3:0]VGA_G,
	output  reg [3:0]VGA_B,
	output  reg VGA_HS,
	output  reg VGA_VS
);


	reg [ 9:0 ]hcnt;
	reg [ 9:0 ]vcnt;
	

	parameter HMAX = 800;
	parameter HVALID = 640;
	parameter HPULSE = 96;
	parameter HBPORCH = 16;

	parameter VMAX = 521;
	parameter VVALID = 480;
	parameter VPULSE = 2;
	parameter VBPORCH = 10;
	
	
	reg vga_clk;
    always @(posedge CLK) begin
        vga_clk = ~vga_clk;
        
	end
	
	
	
	
	always @(posedge vga_clk)
		begin
			if ( hcnt == HMAX - 1 )
				hcnt <= 0;
			 else
				hcnt <= hcnt + 1;
		end
		
		
	// vcnt
	always @(posedge vga_clk)
		begin
			if ( hcnt == HMAX - 1 ) 
				begin
					if ( vcnt == VMAX - 1 )
						vcnt <= 0;
					else
						vcnt <= vcnt + 1;
			 end else
				vcnt <= vcnt;
			 
		end
			
	always @(posedge vga_clk)
	  begin
		 // Vsynv
		 if ((vcnt >= (VVALID + VBPORCH)) && (vcnt < (VVALID + VBPORCH + VPULSE)))
			VGA_VS = 1'b0 ;
		 else
			VGA_VS = 1'b1 ;

		 // Hsync
		 if ((hcnt >= (HVALID + HBPORCH)) && (hcnt < (HVALID + HBPORCH + HPULSE)))
			VGA_HS = 1'b0 ;
		 else
			VGA_HS = 1'b1 ;
	  end
	  
	 // color
	always @(posedge vga_clk)
		begin
		  if ((vcnt < VVALID ) && (hcnt < HVALID))
			 begin
				VGA_R   <= hcnt[3:0];
				VGA_G   <=  4'b1111;
				VGA_B   <=  4'b1111;
			 end
		  else
			 begin
				VGA_R <= 4'b0000;
				VGA_G <= 4'b0000;
				VGA_B <= 4'b0000;
		 end
		end
		
endmodule
