module rx_core(clk,reset,H2L_Sig,RXD,Rx_En_Sig,bps_clk,Rx_Data,Rx_Done_Sig);
input clk;
input reset;
input H2L_Sig;
input RXD;
input Rx_En_Sig;
input bps_clk;

output [7:0] Rx_Data;
output Rx_Done_Sig;

//counter driven design pattern.
reg [3:0] i;
//temporary variables.
reg [7:0] rData;
reg isDone;
always@(posedge clk or posedge reset)
begin
	if(reset) begin
				i<=4'd0;
				rData<=8'd0;
				isDone<=1'b0;
	          end
	else if(Rx_En_Sig) begin
						 case(i)
						 		4'd0: if(H2L_Sig) begin i<=i+1'b1; end //falling-edge,trigger start.
						 		4'd1: if(bps_clk) begin i<=i+1'b1; end //start bit, ignore it.
						 		4'd2,4'd3,4'd4,4'd5,4'd6,4'd7,4'd8,4'd9: //data bits, lock in.
						 			  if(bps_clk) begin i<=i+1'b1;rData[i-2]<=RXD; end  
						 		4'd10: if(bps_clk) begin i<=i+1'b1; end //parity bit,ignore it.
						 		4'd11: if(bps_clk) begin i<=i+1'b1; end //stop bit, ignore it.
						 		4'd12: begin i<=i+1'b1; isDone<=1'b1;end 
						 		4'd13: begin i<=1'b0; isDone<=1'b0; end
						 endcase
	     				end
end
assign Rx_Data=rData;
assign Rx_Done_Sig=isDone;
endmodule