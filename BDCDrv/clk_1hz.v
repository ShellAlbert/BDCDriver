module clk1hz(clk,reset,clk_1hz);
input clk;
input reset;
output clk_1hz;

//49.152MHz/(2*1Hz)=24576000
//use calc.exe we found 24576000 needs 7*4bits=28bis to store.
reg [27:0] cnt_1hz;
reg clk_freq_1hz;
always@(posedge clk or posedge reset)
begin
	if(reset) begin
				cnt_1hz<=28'd0;
				clk_freq_1hz=1'b0;
				end
	else begin
			if(cnt_1hz==28'd24576000) begin
										clk_freq_1hz=~clk_freq_1hz;
										cnt_1hz<=28'd0;
										end
			else
				cnt_1hz<=cnt_1hz+1'b1;
			end
end
assign clk_1hz=clk_freq_1hz;
endmodule