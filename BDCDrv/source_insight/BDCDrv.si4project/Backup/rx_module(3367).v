module rx_module(clk,reset,RXD,Rx_En_Sig,RxData,Rx_Done_Sig,bps_clkx4);
input clk;
input reset;
input RXD;
input Rx_En_Sig;

output [7:0] RxData/*synthesis keep*/;
output Rx_Done_Sig/*synthesis keep*/;
output bps_clkx4/*synthesis nopure*/;

wire H2L_Sig;
H2L_Detect u0(.clk(clk),//input,49.152MHz
				.reset(reset),//input,reset signal.
				.RXD(RXD),//physical RXD pin.
				.H2L_Sig(H2L_Sig));//output,High to Low, falling edge.

wire rx_bps;
rx_bps_module u1(.clk(clk),//49.152Mhz input
				.reset(reset),//input,reset signal.
				.bps_clk(rx_bps),//output,mid-position of 9600Hz.
				.bps_clkx4(bps_clkx4));//output,sample clock.

rx_core u2(.clk(clk),//input,49.152Mhz
			.reset(reset),//input, system reset.
			.H2L_Sig(H2L_Sig),//negedge of RXD.
			.RXD(RXD),//input,physical RXD pin.
			.Rx_En_Sig(Rx_En_Sig),//input,receive enable signal.
			.bps_clk(rx_bps),//input,receive bps clock.
			.Rx_Data(RxData),//output,received data.
			.Rx_Done_Sig(Rx_Done_Sig));//output,received done.
endmodule