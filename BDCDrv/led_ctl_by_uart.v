module led_ctl_by_uart(clk,RXD,led1,led2,bps_clkx4,motor_pwm,parse_done_sig);
input clk;
input RXD;
output led1;
output led2;
output wire bps_clkx4/*synthesis keep*/;   

output [3:0] motor_pwm/*synthesis keep*/;
output parse_done_sig;
   
//generate reset signal.
wire reset;
power_on_reset u0 (.clk(clk),//input,49.152MHz.
					.reset(reset));//output.

reg Rx_En_Sig;
wire [7:0] RxData;
wire Rx_Done_Sig;

rx_module u1(.clk(clk),//input,49.152MHz.
			.reset(reset),//input,system reset.
			.RXD(RXD),//input,physical pin of uart.
			.Rx_En_Sig(Rx_En_Sig),//input
			.RxData(RxData),//ouput.
			.Rx_Done_Sig(Rx_Done_Sig),//output.
			.bps_clkx4(bps_clkx4));//output.

//generate Rx_En_Sig.
always@(posedge clk or posedge reset)
begin
	if(reset) begin
				Rx_En_Sig<=1'd0;
	          end
	else begin
			if(Rx_Done_Sig) 
					Rx_En_Sig<=1'd0;
			else
					Rx_En_Sig<=1'd1;
		 end
end

reg parse_start_en_sig;
wire parse_done_sig;
wire [1:0] led;
uart_parser inst_uart_parser(.clk(clk),//input,49.152MHz
							.reset(reset),//input,system reset.
							.Start_En_Sig(parse_start_en_sig),//input,
							.Rx_Done_Sig(Rx_Done_Sig), //input,
							.Data_In(RxData), //input,
							.led(led), //output.
							.motor_pwm(motor_pwm),//output.
							.Done_Sig(parse_done_sig));//output,
assign led1=led[0];
assign led2=led[1];
//generate parse_start_en_sig.
always@(posedge clk or posedge reset)
begin
	if(reset) begin
				parse_start_en_sig<=1'd0;
	          end
	else begin
			if(parse_done_sig) 
					parse_start_en_sig<=1'd0;
			else
					parse_start_en_sig<=1'd1;
		 end
end

endmodule