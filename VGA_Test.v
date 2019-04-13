module VGA_Test(

	input CLK,
	output  reg [3:0]VGA_R, //4bitアナログ色信号
	output  reg [3:0]VGA_G,
	output  reg [3:0]VGA_B,
	output  reg VGA_HS, //水平同期
	output  reg VGA_VS  //垂直同期
);


	reg [ 9:0 ]hcnt; //水平方向のclkカウント
	reg [ 9:0 ]vcnt; //垂直方向のlineカウント
	reg [ 9:0 ]framecnt; //1フレームごとのカウンタ

	parameter HMAX = 800;	//VGAタイミングチャートの各パラメータ
	parameter HVALID = 640;
	parameter HPULSE = 96;
	parameter HBPORCH = 16;

	parameter VMAX = 521;
	parameter VVALID = 480;
	parameter VPULSE = 2;
	parameter VBPORCH = 10;
	
	
	reg vga_clk; //VGA用クロック


    always @(posedge CLK)begin //システムクロック50MHzを分周して25MHzに
		vga_clk = ~vga_clk;     
	end
	
	
	
	
	always @(posedge vga_clk)begin //水平方向のカウンタ 800clkでリセット
		if ( hcnt == HMAX - 1 )
			hcnt <= 0;
		else
			hcnt <= hcnt + 1;
	end
		
		
	always @(posedge vga_clk)begin	//垂直方向のリセット 520line目の799clkでリセット
			if ( hcnt == HMAX - 1 ) begin
				if ( vcnt == VMAX - 1 )begin
					vcnt <= 0;
					end
				else
				vcnt <= vcnt + 1;
				end 
			else
				vcnt <= vcnt;
	end

	
	reg half_VS;	//30fpsでアニメーションするために垂直同期信号を分周する
    always @(posedge VGA_VS) begin
        half_VS = ~half_VS;     
	end

	always @(posedge half_VS)begin //60フレームで元に戻る
		if(framecnt == 59)
			framecnt <= 0;
		else
			framecnt <= framecnt + 1;
	end
			
	always @(posedge vga_clk)begin
		//垂直同期信号の生成 489 ~ 491lineまでOFF
		if ((vcnt >= (VVALID + VBPORCH)) && (vcnt < (VVALID + VBPORCH + VPULSE)))
			VGA_VS = 1'b0 ;
		 else
			VGA_VS = 1'b1 ;

		 //水平同期信号の生成 655~751clkまでOFF
		 if ((hcnt >= (HVALID + HBPORCH)) && (hcnt < (HVALID + HBPORCH + HPULSE)))
			VGA_HS = 1'b0 ;
		 else
			VGA_HS = 1'b1 ;
	  end
	  
	 // color
	always @(posedge vga_clk)begin
			if ((vcnt < VVALID ) && (hcnt < HVALID))begin //有効画素の時描画する
				if( (vcnt > 0 + 8 * framecnt)&&(vcnt < 120 + 8 *framecnt) && (hcnt > 0 + 10 * framecnt ) && (hcnt < 320 + 10 * framecnt))begin
					//長方形の場所をframecntによって変更することでアニメーション
					VGA_R   <= 	vcnt[3:0];//グラデーション
					VGA_G   <=  4'b0000;
					VGA_B   <=  4'b1111;
				end
				else begin
					VGA_R   <= 	4'b1111;
					VGA_G   <=  4'b0000;
					VGA_B   <=  4'b0000;
				end
			end
		  	else begin //有効画素外
				VGA_R <= 4'b0000;
				VGA_G <= 4'b0000;
				VGA_B <= 4'b0000;
			end
	end
endmodule
