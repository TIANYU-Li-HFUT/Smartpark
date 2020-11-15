module	bluetooth(
							clk				,
							reset			,
							hc05_rx			,
		        			hc05_tx			,
		        			data_out
);
        input        wire         clk;
        input        wire         reset;
        input        wire         hc05_rx;

        output                    hc05_tx;
        output       reg [7:0]    data_out;

		wire			[ 7:0]	data		    ;
		wire					    data_vld	;
	    wire			[ 7:0]	rx_data	;
		wire					    rx_vld		;
		

       parameter  CLK_FREQ = 24000000;
       parameter  UART_BPS = 9600;


       always @ (posedge clk) 
 
           data_out  <= rx_data;



		tx						tx_inst_hc05
		(
			.clk				(clk		),
			.reset	            (reset		),
			.rx_vld	            (data_vld	),
			.rx_data	        (rx_data		),
			.tx                 (hc05_tx	)

		);
		

		
		rx           #(
    .CLK_FREQ (CLK_FREQ),
    .UART_BPS (UART_BPS)
)          rx_inst_hc_05
		(
			 .clock				(clk		),
			 .reset	            (reset		),
			 .uart_rxd		        (hc05_rx	),
			 .uart_data	        (rx_data	),
			 .uart_done	        (rx_vld		)
		);
		


		
		
endmodule