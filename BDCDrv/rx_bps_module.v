module rx_bps_module(clk,reset,bps_clk);
input clk;
input reset;
output bps_clk/*synthesis keep*/;

//frequency=2.4576MHz/(2*counter)
//2.4576MHz/9600=256
//so here,counter=256/2=128.
//since counter starts from 0, so here is 128-1=127.
reg[7:0] counter;
always@(posedge clk or posedge reset)
begin
	if(reset)
		counter<=8'd0;
	else if(counter==8'd127)
		counter<=8'd0;
	else 
		counter<=counter+1'b1;
end

//get the center position,128/2=64.
assign bps_clk=(counter==8'd64)?1'b1:1'b0;
endmodule