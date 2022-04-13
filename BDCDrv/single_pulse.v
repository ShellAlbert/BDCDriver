module single_pulse(clk,reset,pulse_out);
input clk;
input reset;
output reg pulse_out;

//input clk=9600,
//here we want 1hz pulse.
//9600/(2*1Hz)=4800 (need 16bits to store)
reg[15:0] counter;
always@(posedge clk or posedge reset)
begin
	if(reset) begin
				counter<=16'd0;
				pulse_out<=1'b0;
				end
	else begin
			if(counter==16'd4800) begin
										pulse_out<=1'b1;
										counter<=16'd0;
									end
			else begin
					counter<=counter+1'b1;	
					pulse_out<=1'b0;
					end
			end
end
endmodule