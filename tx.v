module		tx(
				clk					,
				reset				,
				rx_vld				,
				rx_data			,
			    tx
);
		input    wire     clk;
		input    wire     reset;
		input    wire     rx_vld;
		input    wire     [7:0] rx_data;
		output  reg       tx;
		parameter					BPS_END	=	13'd2500	;
		parameter					BIT_END	=	4'd9		;
		
		reg			[ 7:0]		rx_data_temp				;
		reg						tx_flag						;
	    reg			[12:0]		bps_cnt						;
        wire						add_bps_cnt					;
        wire						end_bps_cnt					;
        reg			[ 3:0]		bit_cnt						;
        wire						add_bit_cnt					;
        wire						end_bit_cnt					;

		
		always @(posedge clk or negedge reset)begin
			if(reset==0)
				rx_data_temp	<=	0		;
			else if(rx_vld)
				rx_data_temp	<=	rx_data	;
		end
		
		always @(posedge clk or negedge reset)begin
			if(reset==0)
				tx_flag	<=	0		;
			else if(end_bit_cnt)
				tx_flag	<=	0		;
			else if(rx_vld)
				tx_flag	<=	1		;
		end
		
		always @(posedge clk or negedge reset)begin
        	if(reset==0)
        		bps_cnt	<=	0		;
        	else if(add_bps_cnt)begin
        		if(end_bps_cnt)
        			bps_cnt	<=	0	;
        		else
        			bps_cnt	<=	bps_cnt + 1	;
        	end
        end
        assign		add_bps_cnt	=	tx_flag	;
        assign		end_bps_cnt	=	add_bps_cnt	&&	bps_cnt==BPS_END-1	;
        
        always @(posedge clk or negedge reset)begin
        	if(reset==0)
        		bit_cnt	<=	0		;
        	else if(add_bit_cnt)begin
        		if(end_bit_cnt)
        			bit_cnt	<=	0	;
        		else
        			bit_cnt	<=	bit_cnt + 1	;
        	end
        end
        assign		add_bit_cnt	=	end_bps_cnt	;
        assign		end_bit_cnt	=	add_bit_cnt	&&	bit_cnt==BIT_END-1	;
		
		always @(posedge clk or negedge reset)begin
			if(reset==0)
				tx	<=	1		;
			else if(tx_flag)begin
				if(add_bit_cnt && bit_cnt!=8)
					tx	<=		rx_data_temp[bit_cnt]	;
				else if(bit_cnt==0)	
					tx	<=		0	;
			end
			else 
					tx	<=		1	;
		end
		
endmodule