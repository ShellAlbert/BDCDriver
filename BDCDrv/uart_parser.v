(*preserve*) module uart_parser(clk,reset,Start_En_Sig,Rx_Done_Sig,Data_In,led,motor_pwm,Done_Sig);
input clk;
input reset;
input Start_En_Sig;
input Rx_Done_Sig;
input [7:0] Data_In;

output reg [1:0] led;
output [3:0] motor_pwm;
output reg Done_Sig/*synthesis preserve*/;

//55 aa MotorNo. 	Cmd 	Checksum.
//55 aa 01/02 		01 		xx 
//checksum=55+aa+MotorNo.+Cmd
//cmd list
//31:Tiny step move.
//32:Small step move.
//33:Normal step move.
//34:Large step move.


//led1 on: 	55 aa 03 01 03 
//led1 off:	55 aa 03 00 02
//led2 on:	55 aa 04 01 04
//led2 off: 55 aa 04 00 03

reg [7:0] data_buf[4:0]/*synthesis noprune*/;
//data input counter,5(d)=101(b)
reg [2:0] counter/*synthesis preserve*/;
reg [1:0] continous_run;

//pwm module
reg M1_Start_En_Sig;
reg M2_Start_En_Sig;
wire M1_Done_Sig/*synthesis keep*/;
wire M2_Done_Sig/*synthesis keep*/;
reg [3:0] work_mode;
pwm_module instance1_pwm_module(.clk(clk),//input,49.152MHz
								.reset(reset),//input,global reset.
								.Start_En_Sig(M1_Start_En_Sig),//input,trigger input.
								.work_mode(work_mode),//input,work mode.
								.pwm1(motor_pwm[0]),//output,pwm1 of Motor IC.
								.pwm2(motor_pwm[1]),//output,pwm2 of Motor IC.
								.Done_Sig(M1_Done_Sig));//output, done.
pwm_module instance2_pwm_module(.clk(clk),//input,49.152MHz
								.reset(reset),//input,global reset.
								.Start_En_Sig(M2_Start_En_Sig),//input,trigger input.
								.work_mode(work_mode),//input,work mode.
								.pwm1(motor_pwm[2]),//output,pwm1 of Motor IC.
								.pwm2(motor_pwm[3]),//output,pwm2 of Motor IC.
								.Done_Sig(M2_Done_Sig));//output, done.

always@(posedge clk or posedge reset)
begin
	if(reset)	begin
					data_buf[0]<=8'd0;
					data_buf[1]<=8'd0;
					data_buf[2]<=8'd0;
					data_buf[3]<=8'd0;
					data_buf[4]<=8'd0;
					counter<=3'd0;
					Done_Sig<=1'b0;
					continous_run[0]<=1'b0;
					continous_run[1]<=1'b0;
					led[0]<=1'b0;
					led[1]<=1'b0;
				end
	else if(Start_En_Sig)	begin
								Done_Sig<=1'b0;
								if(Rx_Done_Sig)	begin
													data_buf[counter]<=Data_In;
													counter<=counter+1'b1;
												end
								 if(counter==3'd5)	begin
															counter<=3'd0;
															//check each bytes.
															if(data_buf[0]==8'h55 && data_buf[1]==8'haa && data_buf[2]==8'h01)	begin //motor-1.
																																	case(data_buf[3])
																																		8'h31:begin work_mode<=4'd0;M1_Start_En_Sig<=1'b1; end
																																		8'h32:begin work_mode<=4'd1;M1_Start_En_Sig<=1'b1; end
																																		8'h33:begin work_mode<=4'd2;M1_Start_En_Sig<=1'b1; end
																																		8'h34:begin work_mode<=4'd3;M1_Start_En_Sig<=1'b1; end
																																		
																																		//continous mode on.
																																		8'h81:begin continous_run[0]<=1'b1;work_mode<=4'd15;M1_Start_En_Sig<=1'b1; end
																																		//continous mode off.
																																		8'h82:begin continous_run[0]<=1'b0;work_mode<=4'd15;M1_Start_En_Sig<=1'b1; end
																																		default: begin M1_Start_En_Sig<=1'b0; end
																																	endcase
																																end
															else if(data_buf[0]==8'h55 && data_buf[1]==8'haa && data_buf[2]==8'h02)	begin //motor-2.
																																		case(data_buf[3])
																																			8'h31:begin work_mode<=4'd0;M2_Start_En_Sig<=1'b1; end
																																			8'h32:begin work_mode<=4'd1;M2_Start_En_Sig<=1'b1; end
																																			8'h33:begin work_mode<=4'd2;M2_Start_En_Sig<=1'b1; end
																																			8'h34:begin work_mode<=4'd3;M2_Start_En_Sig<=1'b1; end
																																			
																																			//continous mode on.
																																			8'h34:begin continous_run[1]<=1'b1;work_mode<=4'd15;M2_Start_En_Sig<=1'b1; end
																																			//continous mode off.
																																			8'h34:begin continous_run[1]<=1'b0;work_mode<=4'd15;M2_Start_En_Sig<=1'b1; end
																																			default: begin M2_Start_En_Sig<=1'b0; end
																																		endcase
																																	end
															else if(data_buf[0]==8'h55 && data_buf[1]==8'haa && data_buf[2]==8'h03)	begin //led1.
																																		case(data_buf[3])
																																			8'h01:	begin //checksum.
																																						if(data_buf[0]+data_buf[1]+data_buf[2]+data_buf[3]==data_buf[4])
																																							led[0]<=1'b1;
																																					end //on
																																			8'h02: begin
																																						if(data_buf[0]+data_buf[1]+data_buf[2]+data_buf[3]==data_buf[4])
																																							led[0]<=1'b0;
																																				   end //off
																																			default: begin led[0]<=1'b0; end
																																		endcase
																																	end
															else if(data_buf[0]==8'h55 && data_buf[1]==8'haa && data_buf[2]==8'h04)	begin //led2.
																																		case(data_buf[3])
																																			8'h01:	begin //checksum.
																																						if(data_buf[0]+data_buf[1]+data_buf[2]+data_buf[3]==data_buf[4])
																																							led[1]<=1'b1;
																																					end //on
																																			8'h02:	begin //checksum.
																																						if(data_buf[0]+data_buf[1]+data_buf[2]+data_buf[3]==data_buf[4])
																																							led[1]<=1'b0;
																																					end //off
																																			default: begin led[1]<=1'b0; end
																																		endcase
																																	end
															//process done.
															Done_Sig<=1'b1;
														end
								else begin
										if(M1_Done_Sig)	begin
															M1_Start_En_Sig<=1'b0;
														end
										if(M2_Done_Sig)	begin
															M2_Start_En_Sig<=1'b0;
														end
									end
							end
end


endmodule