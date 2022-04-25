module led_ctl_by_uart(clk,RXD,led1,led2,bps_clkx4);
input clk;
input RXD;
output reg led1;
output reg led2;
output wire bps_clkx4/*synthesis keep*/;

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
				led1<=1'd1;
				led2<=1'd1;
	          end
	else begin
			if(Rx_Done_Sig) begin
								case(RxData)
									8'h33: begin led1<=1'd0; end
									8'h66: begin led2<=1'd0; end
									8'h88: begin led1<=1'd1; end
									8'haa: begin led2<=1'd1; end
								endcase
							end
		 end
end
endmodule