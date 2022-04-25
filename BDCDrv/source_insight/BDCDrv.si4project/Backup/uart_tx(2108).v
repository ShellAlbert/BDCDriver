
module uart_tx(clk,reset,start,data_in,txd,done,busy);
input clk;
input reset;
input start;
input [7:0] data_in;

output reg txd;
output reg done;
output reg busy;

parameter IDLE=3'b000;
parameter START_BIT=3'b001;
parameter DATA_BITS=3'b010;
parameter STOP_BIT=3'b011;

reg[2:0] fsm=3'b000 /*synthesis preserve*/;
// to store a copy of input data.
reg[7:0] data_in_lock /*synthesis preserve*/;
reg[2:0] bitIndex /*synthesis preserve*/;

always@(posedge clk or posedge reset)
begin
	if(reset) begin
			fsm<=IDLE; //IDLE state.
			end
	else
		case(fsm)
			IDLE:begin //IDLE state.
					txd<=1'b1;//drive high for idle.
					done<=1'b0;
					busy<=1'b0;
					bitIndex<=3'd0;
					data_in_lock<=8'd00;
					if(start==1'b1) begin
								data_in_lock<=data_in;
								fsm<=START_BIT; 
							  end
					else
							fsm<=IDLE;
					end
			START_BIT:begin //StartBits state.
						txd<=1'b0; //start bit(from high to low).
						busy<=1'b1;//now is busy.
						fsm<=DATA_BITS;
						end
			DATA_BITS:begin //DataBits state.
						txd<=data_in_lock[bitIndex];
						if(bitIndex==7'b111) //bitIndex[1]&bitIndex[2]...&bitIndex[N]==1
							fsm<=STOP_BIT;
						else
							bitIndex<=bitIndex+1'b1;
						end
			STOP_BIT:begin //StopBits state.
						done<=1'b1;
						fsm<=IDLE;
						end
		endcase
end
endmodule
