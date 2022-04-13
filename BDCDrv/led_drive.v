module led_drive(clk,reset,led1,led2,data_out);

input clk,reset;
output reg led1,led2;
output reg[7:0] data_out;
// clk=49.152MHz=49152kHz=49152000Hz
// led1,49152kHz/2Hz=24576000=32'd24576000
parameter CNT_LED1_PRESCALE=32'd24576000;
// led2,49152kHz/10Hz=4915200=32'd4915200
parameter CNT_LED2_PRESCALE=32'd4915200;

reg [31:0] cnt_led1 = 32'd0;
reg [31:0] cnt_led2 = 32'd0;
always @ (posedge clk or posedge reset)
begin
	if(reset)
		begin
			cnt_led1<=32'd0;
			cnt_led2<=32'd0;
		end
	else
		begin
			if(cnt_led1 == CNT_LED1_PRESCALE)
				cnt_led1 <= 32'd0;
			else
				cnt_led1 <= cnt_led1 + 1'b1;
				
			if(cnt_led2 == CNT_LED2_PRESCALE)
				cnt_led2 <= 32'd0;
			else
				cnt_led2 <= cnt_led2 + 1'b1;
		end
end

always @ (posedge clk or posedge reset)
begin
	if(reset)
		begin
			led1<=1'b0; //off
			led2<=1'b0; //off
			data_out=8'd0;
		end
	else
		begin
			if(cnt_led1 == CNT_LED1_PRESCALE) begin
												led1<=~led1; //reverse
												if(data_out==8'd255)
														data_out<=8'd0;
												else
														data_out<=data_out+1'b1;
											end
			else
					led1<=led1;
					
			if(cnt_led2 == CNT_LED2_PRESCALE)
					led2<=~led2; //reverse
			else
					led2<=led2;
		end
end

endmodule