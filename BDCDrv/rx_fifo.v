module rx_fifo(clk,reset,put_pulse,put_byte,full,empty);
input clk;
input reset;
input put_pulse;
input [7:0] put_byte;
output full/*synthesis keep*/;
output empty/*synthesis keep*/;

//the maximum capacity of fifo.
reg [7:0] array [0:9]/*synthesis noprune*/;
//remeber valid data numbers.
reg [7:0] used/*synthesis noprune*/;

//fifo is full.
assign full=(used==8'd10)?1'b1:1'b0;
//fifo is empty.
assign empty=(used==8'd0)?1'b1:1'b0;

reg [7:0] i;
always@(posedge clk or posedge reset)
begin
	if(reset) begin
				used<=8'd0;			
	          end
	else begin
			if(put_pulse && !full) begin
									array[used]<=put_byte;
									used<=used+1'b1;
			                       end
		 end
end
endmodule