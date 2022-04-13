module power_on_reset(clk,reset);

input clk;
output reset;

//clk=49.152MHz
//baud_rate=9600
//txclk=49.152MHz/(2*9600)=2560
//we use calc.exe to check 2560 need 12bits.
//parameter CNT_TXCLK=12'd2560;
parameter CNT_TXCLK=12'd2559;
reg [11:0] cnt4txclk;
reg txclk;

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



reg [31:0] count = 0;

always @(posedge clk) 
begin
		if(txclk) begin
					if(count == 32'h0xfffffff) 
						count <= count;
					else
						count <= count + 1'b1;
		end
end

assign reset = (count==32'h0xffffffe) ? 1'b1 : 1'b0; // power on reset high for 2000ms
endmodule