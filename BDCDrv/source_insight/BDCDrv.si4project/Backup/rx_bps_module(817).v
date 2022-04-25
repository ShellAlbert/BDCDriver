module rx_bps_module(clk,reset,bps_clk);
input clk;
input reset;
output bps_clk;

//49.152MHz/9600=5120
//since counter starts from 0, so here is 5120-1=5119.
reg[15:0] counter;
always@(posedge clk or posedge reset)
begin
	if(reset)
		counter<=16'd0;
	else if(counter==16'd5119)
		counter<=16'd0;
	else 
		counter<=counter+1'b1;
end

//get the center position,5120/2=2560.
assign bps_clk=(counter==16'd2560)?1'b1:1'b0;

endmodule