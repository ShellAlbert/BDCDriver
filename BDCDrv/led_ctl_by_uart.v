module led_ctl_by_uart(clk,RXD,led1,led2,bps_clkx4,motor_pwm);
input clk;
input RXD;
output reg led1;
output reg led2;
output wire bps_clkx4/*synthesis keep*/;   

output [3:0] motor_pwm/*synthesis keep*/;

   
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

//pwm module
reg M1_Start_En_Sig;
reg M2_Start_En_Sig;
wire M1_Done_Sig/*synthesis keep*/;
wire M2_Done_Sig/*synthesis keep*/;
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
									8'h88: begin led1<=1'd1; M1_Start_En_Sig<=1'b1; end //on
									8'haa: begin led2<=1'd1; M2_Start_En_Sig<=1'b1; end //on
									default: begin led1<=1'd0;led2<=1'd0;end //all off.
								endcase
							end
			if(M1_Done_Sig) begin
								M1_Start_En_Sig<=1'b0;
							end
			if(M2_Done_Sig) begin
								M2_Start_En_Sig<=1'b0;
							end
		 end
end




endmodule