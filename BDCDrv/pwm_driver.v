module pwm_driver(clk,reset,out1,out2);
input clk,reset;
output reg out1,out2;

// clk=49.152MHz=49152kHz=49152000Hz
// pwm frequency,49152kHz/100kHz=491
// prescale=491/2=12'd245
//more frequency low, more speed slow.
//100hz
//(49.152MHz/100Hz)/2=245760=20'd245760
parameter PRESCALE_100KHZ=20'd245760;
reg [19:0] cnt_100khz;
always @(posedge clk or posedge reset)
begin
	if(reset)
		cnt_100khz<=20'd0;
	else
		if(cnt_100khz==PRESCALE_100KHZ)
			cnt_100khz<=20'd0;
		else
			cnt_100khz<=cnt_100khz+1'b1;
end

always @(posedge clk or posedge reset)
begin
	if(reset)
		begin
			out1<=1'b0;
			out2<=1'b0;
		end
	else
		if(cnt_100khz==PRESCALE_100KHZ)
			out1<=~out1;
		else
			out1<=out1;
end
endmodule