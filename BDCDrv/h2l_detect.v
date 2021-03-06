module H2L_Detect(clk,reset,RXD,H2L_Sig);
input clk;
input reset;
input RXD;
output H2L_Sig/*synthesis keep*/;

reg H2L_F1;
reg H2L_F2;
always@(posedge clk or posedge reset)
begin
	if(reset) begin
				H2L_F1<=1'b1;
				H2L_F2<=1'b1;
		      end
	else begin
			H2L_F1<=RXD;
			H2L_F2<=H2L_F1;
	     end
end
assign H2L_Sig=H2L_F2 & !H2L_F1;

endmodule