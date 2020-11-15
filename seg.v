module	smg_disp(
			clk					,
			reset				,
			hc_data				,	
			seg_sel				,
			seg_ment		
);  
       input      wire            clk;
       input      wire            reset;
       input      wire  [15:0]  hc_data;
       output    reg   [7:0]   seg_sel;
       output    reg   [6:0]   seg_ment;

		parameter				TIME_REF	=		50_000			;
        parameter				SEG_NUM		=		8				;
        
        parameter      			DATA0      	=       7'b0000001  	;
        parameter      			DATA1      	=       7'b1001111  	;
        parameter      			DATA2      	=       7'b0010010  	;
        parameter      			DATA3      	=       7'b0000110  	;
        parameter      			DATA4      	=       7'b1001100  	;
        parameter      			DATA5      	=       7'b0100100  	;
        parameter      			DATA6      	=       7'b0100000  	;
        parameter      			DATA7      	=       7'b0001111  	;
        parameter      			DATA8      	=       7'b0000000  	;
        parameter      			DATA9      	=       7'b0000100  	;
		
		reg			[15:0]	cnt_ref				;
		wire					    end_cnt_ref		;
		reg			[ 2:0]	cnt_seg			;
		wire					    add_cnt_seg	;
		wire					    end_cnt_seg	;
		reg			[ 15:0]	rx_data_reg		;
		reg			[ 3:0]	seg_data			;
		
		always @(posedge clk or negedge reset)begin
			if(reset==0)
				rx_data_reg	<=	0				;
			else 
				rx_data_reg	<=	hc_data			;
		end
		
		always @(posedge clk or negedge reset)begin
			if(reset==0)
				cnt_ref	<=	0	;
			else if(end_cnt_ref)
				cnt_ref	<=	0	;
			else 
				cnt_ref	<=	cnt_ref	+1	;
		end
		assign	end_cnt_ref	=	cnt_ref==TIME_REF-1	;
		
		always @(posedge clk or negedge reset)begin
			if(reset==0)
				cnt_seg	<=	0	;
			else if(add_cnt_seg)begin
				if(end_cnt_seg)
					cnt_seg	<=	0	;
				else
					cnt_seg	<=	cnt_seg	+1	;
			end
		end
		assign	add_cnt_seg	=	end_cnt_ref	;
		assign	end_cnt_seg	=	add_cnt_seg	&&	cnt_seg==SEG_NUM-1	;
		
		always @(posedge clk or negedge reset)begin
			if(reset==0)
				seg_sel	<=	8'b1111_1111	;
			else begin
				case(cnt_seg)
					0:
						seg_sel	<=	8'b0111_1111	;
					1:
						seg_sel	<=	8'b1011_1111	;
					2:
						seg_sel	<=	8'b1101_1111	;
					3:
						seg_sel	<=	8'b1110_1111	;
					
					default:
						seg_sel	<=	8'b1111_1111	;
				endcase
			end
		end
		
		always @(*)begin
			case(cnt_seg)
				0:
					seg_data	=	rx_data_reg[3:0]	;
				1:
					seg_data	=	rx_data_reg[7:4]	;
				2: 
				    seg_data	=	rx_data_reg[11:8]	;
				3:
				    seg_data	=	rx_data_reg[15:12]	;	
				default
					seg_data	=	0			;
			endcase
		end
		
		always @(posedge clk or negedge reset)begin
			if(reset==0)
				seg_ment	<=	DATA0	;
			else begin
				case(seg_data)
					0:
						seg_ment	<=	DATA0	;
					1:
						seg_ment	<=	DATA1	;
					2:
						seg_ment	<=	DATA2	;
					3:
						seg_ment	<=	DATA3	;
					4:
						seg_ment	<=	DATA4	;
					5:
						seg_ment	<=	DATA5	;
					6:
						seg_ment	<=	DATA6	;
					7:
						seg_ment	<=	DATA7	;
					8:
						seg_ment	<=	DATA8	;
					9:
						seg_ment	<=	DATA9	;
					default:
						seg_ment	<=	seg_ment	;
				endcase
			end
		end
		
endmodule