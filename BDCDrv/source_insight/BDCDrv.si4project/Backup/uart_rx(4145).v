module uart_rx(clk,reset,serial_in,parallel_out,done,busy,err);
input clk;
input reset;
input serial_in/*synthesis keep*/;

output reg [7:0] parallel_out;
output reg done;
output reg busy;
output reg err;

//finite state machine.
parameter STATE_IDLE=2'b00;
parameter STATE_DATA_BITS=2'b01;
parameter STATE_STOP_BIT=2'b10;
reg [1:0] my_fsm/*synthesis preserve*/;

//shift register for input data.用于下降沿检测
wire negedge_rxd/*synthesis keep*/;
//rx线默认为高电平，有起始位时，为低电平。
//previous_state=1 & current_state=1 结果为1，此时没有起始位。
//previous_state=1 & current_state=0 结果为0，此时就是下降沿。
reg [1:0] shift_serial_in;

assign negedge_rxd=shift_serial_in[1]&(~shift_serial_in[0]);

//temporary store input data.
reg [7:0] received_data/*synthesis noprune*/;
//count clocks for 16x oversample.//2^4=16.
reg [3:0] clock_count/*synthesis noprune*/;

//bit index.2^3=8bits.
reg [2:0] bitIndex/*synthesis noprune*/;

always@(posedge clk or posedge reset)
begin
	if(reset) begin
				parallel_out<=8'd0;
				received_data<=8'd0;
				bitIndex<=3'd0;
				shift_serial_in<=2'd0;
				clock_count<=4'd0;
				done<=1'b0;
				busy<=1'b0;
				err<=1'b0;
				my_fsm<=STATE_IDLE;
	          end
	else begin
			//delay one clock cycle, used to check falling edge.
			shift_serial_in<={shift_serial_in[0],serial_in};
			case(my_fsm)
				STATE_IDLE: begin
									done<=1'b0;  
									if(clock_count==4'd8) begin
																clock_count<=4'd0;
																my_fsm<=STATE_DATA_BITS;
																busy<=1'b1;
																received_data<=8'd0;
																bitIndex<=3'd0;
															end
									else if(negedge_rxd || clock_count!=4'd0) begin
																				//check bit to make sure it's still low.
																				if(&shift_serial_in) begin
																										err<=1'b1;
																										clock_count<=4'd0;
																										my_fsm<=STATE_IDLE;
																									 end
																				else
																					clock_count<=clock_count+1'b1;
																			  end	
							end
				STATE_DATA_BITS: begin 									
									if(clock_count==4'd15) begin
																clock_count<=4'd0;
																received_data[bitIndex]<=shift_serial_in[0];
																if(bitIndex==3'd7) begin
																				bitIndex<=3'd0;
																				my_fsm<=STATE_STOP_BIT;
																	  			end
																else
																		bitIndex<=bitIndex+1'b1;
									                 		end
									else
										clock_count<=clock_count+1'b1;
								 end
				STATE_STOP_BIT: begin 
									if(clock_count==4'd15) begin
																clock_count<=4'd0;
																my_fsm<=STATE_IDLE;
																done<=1'b1;
																busy<=1'b0;
																parallel_out<=received_data;
														   end
									else begin
											clock_count<=clock_count+1'b1;
											//check bit to make sure it's still high in 16xsample period.
											//if not, error possible occured.
											//|shift_serial_in 按位与,所有位为1时,=True.
											if(!(|shift_serial_in)) begin
																		err<=1'b1;
																		my_fsm<=STATE_IDLE;
																	end
										 end
								end
				default:  my_fsm<=STATE_IDLE;
			endcase
	     end
end
endmodule