module led_ctl_by_uart(clk,RXD,led1,led2,bps_clkx4,motor_pwm);
input clk;
input RXD;
output reg led1;
output reg led2;
output wire bps_clkx4/*synthesis keep*/;   

output [3:0] motor_pwm;

   
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

always@(posedge clk or posedge reset)
begin
	if(reset) begin
				led1<=1'd0;//all off.
				led2<=1'd0;
	          end
	else begin
			if(Rx_Done_Sig) begin
								case(RxData)
									8'h33: begin led1<=1'd0; end //off
									8'h66: begin led2<=1'd0; end //off
									8'h88: begin led1<=1'd1; end //on
									8'haa: begin led2<=1'd1; end //on
									default: begin led1<=1'd0;led2<=1'd0;end //all off.
								endcase
							end
		 end
end



//pwm module
wire M1_Start_En_Sig;
wire M2_Start_En_Sig;
wire M1_Done_Sig;
wire M2_Done_Sig;
pwm_module instance1_pwm_module(.clk(clk),//input,49.152MHz
								.reset(reset),//input,global reset.
								.Start_En_Sig(M1_Start_En_Sig),//input,trigger input.
								.pwm1(motor_pwm[0]),//output,pwm1 of Motor IC.
								.pwm2(motor_pwm[1]),//output,pwm2 of Motor IC.
								.Done_Sig(M1_Done_Sig));//output, done.
pwm_module instance2_pwm_module(.clk(clk),//input,49.152MHz
								.reset(reset),//input,global reset.
								.Start_En_Sig(M2_Start_En_Sig),//input,trigger input.
								.pwm1(motor_pwm[2]),//output,pwm1 of Motor IC.
								.pwm2(motor_pwm[3]),//output,pwm2 of Motor IC.
								.Done_Sig(M2_Done_Sig));//output, done.
endmodule