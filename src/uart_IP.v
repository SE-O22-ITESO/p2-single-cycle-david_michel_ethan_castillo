// Coder:           David Adrian Michel Torres, Eduardo Ethandrake Castillo Pulido
// Date:            16/03/23
// File:			     uart_IP.v
// Module name:	  uart_IP
// Project Name:	  risc_v_top
// Description:	  UART IP

module uart_IP #(parameter DATA_WIDTH = 32) (
	//inputs
	input [(DATA_WIDTH-1):0] wd, address,
	input we, clk, rst_n,
	//outputs
	output [(DATA_WIDTH-1):0] rd,
	//Connected to board
	input rx,
	output tx
);

//Module wires
wire uart_tx_finish, rx_flag, tx_busy;
wire [7:0] rx_data;

//Risk-V  --  Memory_Map   --   UART
//10010024       4                1     Tx data (FPGA)
//10010028       8                2     TX start sending data
//1001002c       c                3     TX Finish sending data
//10010030       10               4     Rx data (FPGA)
//10010034       14               5     Data processed from UART to Risk V
//10010038       18               6     Clear RX data
//1001003C       1c               7     Tx is processing data

//Reg to retain uart_val value
reg [31:0] uart_val [0:7];

//UART full duplex module
uart_full_duplex UART_full_duplex(
	 //Platform signals
	 .clk(clk),
    .rst_n(rst_n),
	 //Rx
    .rx(rx), //Input from Serial console
	 .Rx_Data(rx_data), //Decoded data
	 .rx_flag(rx_flag), //Indication that we finish reception
	 .rx_flag_clr(uart_val[6][0]), //To clear state
	 //Tx
	 .tx(tx), //Output to serial console
	 .tx_data(uart_val[1][7:0]), //Decoded data
    .tx_send(uart_val[2][0]), //Indication to send the data
	 .tx_finish(uart_tx_finish), //Indication that UART finish to transmit data
	 .tx_busy(tx_busy) //Indication that UART is working in Tx
);

always @(posedge clk, negedge rst_n) begin
	if(!rst_n) begin
		uart_val[0] <= 32'h0; //Not used
		uart_val[1] <= 32'h0; //Tx data
		uart_val[2] <= 32'h0; //Start sending data - Tx
		uart_val[3] <= 32'h0; //Finish sending data - Tx
		uart_val[4] <= 32'h0; //Rx Data
		uart_val[5] <= 32'h0; //Data received
		uart_val[6] <= 32'h0; //Rx flag clear
		uart_val[7] <= 32'h0; //Uart is busy - Tx
	end else begin
		if(we) begin
			uart_val[address] <= wd;
		end
		//Assign the finish of sending data
		uart_val[3] <= {{31{1'b0}},uart_tx_finish};
		//Save Rx data from UART
		uart_val[4] <= {{24{1'b0}},rx_data};
		//UART Rx received a data
		uart_val[5] <= {{31{1'b0}},rx_flag};
		//UART Tx is processing data
		uart_val[7] <= {{31{1'b0}},tx_busy};
	end
end

// Reading if memory read enable
assign rd = uart_val[address];

endmodule