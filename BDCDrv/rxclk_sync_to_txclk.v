//we cannot use rx_done signal to trigger tx_start of UART.
//because the clock frequency of RX is 16x TxClock.
//Therefore the TxClock is much more slower than RxClock, cannot lock the rx_done correctly.
//so we use SysClock to lock the rx_done, and expand&Sync it to TxClk.
module rxclk_sync_to_txclk(clk,reset,rx_done,txclk,tx_start);
input clk;
input reset;
input rx_done;
input txclk;

output reg tx_start/*synthesis noprune*/;

//check the falling edge of rx_done to hit that moment of received data valid.
reg [1:0] rx_done_buf;
wire neg_rx_done=rx_done_buf[1]&(~rx_done_buf[0])/*synthesis keep*/;
reg neg_rx_done_trigger/*synthesis noprune*/;

//check the raising edge of txclk.
reg [1:0] txclk_buf;
wire neg_txclk=(~txclk_buf[0])&txclk_buf[1]/*synthesis keep*/;
wire pos_txclk=txclk_buf[0]&(~txclk_buf[1])/*synthesis keep*/;

always @(posedge clk or posedge reset)
begin
	if(reset) begin
				rx_done_buf<=2'b00;
				txclk_buf=2'b00;
			  end
	else begin
			rx_done_buf<={rx_done_buf[0],rx_done};
			txclk_buf={txclk_buf[0],txclk};
		 end
end

//to keep tx_start 2 clock cycle.
always @(posedge clk or posedge reset)
begin
	if(reset) begin
				tx_start<=1'b0;	
				neg_rx_done_trigger<=1'b0;
			  end
	else begin
			if(neg_rx_done)
					neg_rx_done_trigger<=1'b1;
			else if(neg_rx_done_trigger==1'b1 && neg_txclk)
					tx_start<=1'b1;
				 else if(neg_rx_done_trigger==1'b1 && pos_txclk ) begin
						 	 										tx_start<=1'b0;
						 	 										neg_rx_done_trigger<=1'b0;
						 	 								     end
					  else
					  		tx_start<=tx_start;
					  		
	     end
end
endmodule