module top_clk_prescale(clk,clk_out);
input clk;
output clk_out;


//generate reset signal.
wire reset;
power_on_reset u0 (.clk(clk),//input,49.152MHz.
					.reset(reset));//output.

clk_prescale u1(.clk(clk),//input.
				.reset(reset),//input.
				.clk_main(clk_out));//output.
endmodule