module clk_prescale(clk,reset,clk_main);
input clk;
input reset;
output reg clk_main;


//the equation should be 49.152MHz/(2*counter)
//the threshold value of counter is counter-1.
//here we let counter equals 10,
//then we get 49.152MHz/(2*10)=2.4576MHz.
//but the threshold is counter-1=10-1=9.
reg [7:0] counter;
always@(posedge clk or posedge reset)
begin
	if(reset)	begin
					counter<=0;
					clk_main<=8'b0;
				end
	else if(counter==8'd9)	begin
								counter<=8'd0;
								clk_main=~clk_main;
							end
		else
			counter<=counter+1'b1;
end
endmodule