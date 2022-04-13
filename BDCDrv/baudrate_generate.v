module baudrate_generate(clk,reset,txclk,rxclk,txclkx4,rxclkx4);
input clk;
input reset;
output reg txclk;
output reg rxclk;
output reg txclkx4;
output reg rxclkx4;
//clk=49.152MHz
//baud_rate=9600
//txclk=49.152MHz/(2*9600)=2560
//we use calc.exe to check 2560 need 12bits.
//parameter CNT_TXCLK=12'd2560;
parameter CNT_TXCLK=12'd2559;
reg [11:0] cnt4txclk;
//txclkx4=49.152MHz/(2*9600*4)=640
parameter CNT_TXCLKx4=12'd640;
reg [11:0] cnt4txclkx4;

//we use 16x oversample
//rxclk=49.152MHz/(2*9600*16)=160
//we use calc.exe to check 160 needs 8bits to 
parameter CNT_RXCLK=8'd160;
reg [7:0] cnt4rxclk;
//rxclkx4=49.152MHz/(2*9600*16*4)=40
parameter CNT_RXCLKx4=8'd40;
reg [11:0] cnt4rxclkx4;


//generate tx clock.
always@(posedge clk or posedge reset)
begin
	if(reset)
		begin
			txclk<=0;
			cnt4txclk<=12'd0;
		end
	else
		if(cnt4txclk==CNT_TXCLK)
			begin
				txclk<=~txclk;
				cnt4txclk<=12'd0;
			end
		else
			cnt4txclk<=cnt4txclk+1'b1;
end

//generate rx clock.
always@(posedge clk or posedge reset)
begin
	if(reset)
		begin
			rxclk<=0;
			cnt4rxclk<=8'd0;
		end
	else
		if(cnt4rxclk==CNT_RXCLK)
			begin
				rxclk<=~rxclk;
				cnt4rxclk<=8'd0;
			end
		else
			cnt4rxclk<=cnt4rxclk+1'b1;
end

//generate txclkx4 clock.
always@(posedge clk or posedge reset)
begin
	if(reset)
		begin
			txclkx4<=0;
			cnt4txclkx4<=8'd0;
		end
	else
		if(cnt4txclkx4==CNT_TXCLKx4)
			begin
				txclkx4<=~txclkx4;
				cnt4txclkx4<=8'd0;
			end
		else
			cnt4txclkx4<=cnt4txclkx4+1'b1;
end

//generate rxclkx4 clock.
always@(posedge clk or posedge reset)
begin
	if(reset)
		begin
			rxclkx4<=0;
			cnt4rxclkx4<=8'd0;
		end
	else
		if(cnt4rxclkx4==CNT_RXCLKx4)
			begin
				rxclkx4<=~rxclkx4;
				cnt4rxclkx4<=8'd0;
			end
		else
			cnt4rxclkx4<=cnt4rxclkx4+1'b1;
end
endmodule