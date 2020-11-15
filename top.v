/*
 * @Author: QYL
 * @Date: 2020-11-01 17:56:11
 * @LastEditTime: 2020-11-01 21:45:50
 * @LastEditors: Please set LastEditors
 * @Description: In User Settings Edit
 * @FilePath:picorv32_prj\picorv_anlu\picorv_anlu.srcs\sources_1\new\top.v
 */



module top(
    input sysclk, 
    input areset_n, // Active Low

    //Trace Interface
    input trace_mid,
    input trace_left,
    input trace_right,
    input trace_left_f,
    input trace_right_f,

    //Ultrasonic Interface
    input hc_echo,
    output hc_trig,
    output hc_pwm,
    //bluetooch
    input hc05_rx,
    output run_d1  ,  
    output run_d2  ,      
    output pwm_r1 ,         
    output pwm_r2  ,          //control driving
    output pwm_t  ,            //control turning
    output park_f ,
    output    wire   [7:0]   seg_sel,
    output    wire [6:0]   seg_ment,
    output audio
);
     
    parameter DriveBaseAddr = 32'h4000_0000;
    parameter TraceBaseAddr = 32'h4001_0000;
    parameter TimerBaseAddr = 32'h4002_0000;
    parameter HcBaseAddr    = 32'h4003_0000;
    parameter BlueteechBaseAddr = 32'h4004_0000;
    parameter AudioBaseAddr = 32'h4005_0000 ;
 
    // Wishbone Interface
    wire mem_valid;
    wire mem_ready;
    wire [31:0] mem_addr;
    wire [31:0] mem_wdata;
    wire [3:0] mem_wstrb;
    wire [31:0] mem_rdata;
    //SRAM Interface
    reg        smem_ready;
    wire [31:0] smem_rdata;
	
	wire        smem_valid;
  	wire [3:0]  smem_wstrb;
	wire [31:0] smem_addr;
	wire [31:0] smem_wdata;
	wire [1:0] run_d ;
	wire [1:0] run_d1, run_d2;   
	wire  pwm_r;     
	wire pwm_r1 ;       
	wire pwm_r2;            //control driving
	wire pwm_t  ;          //control turning
	wire park_f ;
    wire irq;
    wire timer_irq;

    reg rst_s1,rst_s2;
    wire rst_sync,rst_sync_n;
    
    assign run_d1 = run_d;
    assign run_d2 = run_d;
    
    always @ (posedge sysclk, negedge areset_n)  
      if (!areset_n) begin   
        rst_s1 <= 1'b0;  
        rst_s2 <= 1'b0;  
      end  
      else begin  
        rst_s1 <= 1'b1;  
        rst_s2 <= rst_s1;  
      end  
  
    assign rst_sync_n = rst_s2; 
    assign rst_sync = ~rst_s2;

    assign irq = {31'h0,timer_irq};
    

    assign smem_valid = mem_valid;
	assign smem_wstrb = mem_wstrb;
  	assign smem_addr  = mem_addr;
	assign smem_wdata = mem_wdata;

    assign mem_ready = (smem_valid & smem_ready) | 
                                     drive_ack   |
                                     trace_ack   |
                                     hc_ack      |
                                     timer_ready |
                                     bluetooch_ack|
                                     audio_ack   ;

    assign mem_rdata = (smem_valid & smem_ready)?    smem_rdata                 :
                      drive_ack?                     {31'h0,park_f}             :
                      trace_ack?                     {27'h0,trace_dir}          :
                      hc_ack?                        {16'h0,hc_s}               :
                      bluetooch_ack?                 {24'h0,bluetooch_dataout}  :
                      audio_ack?                     {27'h0, audio}             :
               
                                                     32'h0                      ;    


//Aduio Interface
reg [4:0] audio;
reg audio_ack;
always @(posedge sysclk) begin
  if(rst_sync)
    audio_ack <= 1'b0;
  else if(mem_valid & (mem_addr==AudioBaseAddr) & !audio_ack)
    audio_ack <= 1'b1;
  else 
    audio_ack <= 1'b0;
end


always @(posedge sysclk) begin
  if(rst_sync) begin
    audio <= 5'b00000;
  end else if(mem_valid & mem_wstrb[0] & audio_ack) begin //write
    audio <= mem_wdata[4:0];    

  end
end  

//Drive Interface
reg drive_en;   
reg [4:0] turn;
reg [1:0] park;
wire park_f;
reg drive_ack;

always @(posedge sysclk) begin
  if(rst_sync)
    drive_ack <= 1'b0;
  else if(mem_valid & ((mem_addr>=DriveBaseAddr) & (mem_addr<=DriveBaseAddr+'h8)) & !drive_ack)
    drive_ack <= 1'b1;
  else 
    drive_ack <= 1'b0;
end

always @(posedge sysclk) begin
  if(rst_sync) begin
    drive_en <= 1'b0;turn <= 5'h0;park <= 2'h0;
  end else if(mem_valid & mem_wstrb[0] & drive_ack) begin //write
    case(mem_addr)
      DriveBaseAddr: drive_en <= mem_wdata[0];
      DriveBaseAddr+'h4: turn <= mem_wdata[4:0];
      DriveBaseAddr+'h8:  park <= mem_wdata[1:0];
      default:;
    endcase
  end
end  
//////////////////

//Trace Interface
wire [4:0] trace_dir;
reg trace_ack;
always @(posedge sysclk) begin
  if(rst_sync)
    trace_ack <= 1'b0;
  else if(mem_valid & (mem_addr==TraceBaseAddr) & !trace_ack)
    trace_ack <= 1'b1;
  else 
    trace_ack <= 1'b0;
end
//////////////////


//Ultrasonic Interface
wire [3:0]s_g,s_s,s_b,s_q;
wire [15:0] hc_s = {s_q,s_b,s_s,s_g};
wire hc_pwm;
wire  hc_echo;
wire  hc_trig;
reg hc_ack;
always @(posedge sysclk) begin
  if(rst_sync)
    hc_ack <= 1'b0;
  else if(mem_valid & (mem_addr==HcBaseAddr) & !hc_ack)
    hc_ack <= 1'b1;
  else 
    hc_ack <= 1'b0;
end

//blueteech Interface
wire [7:0] bluetooch_dataout;
reg  bluetooch_ack;

always @(posedge sysclk)
    if(rst_sync)
        bluetooch_ack <= 1'b0;
     else if(mem_valid & (mem_addr==BlueteechBaseAddr) & !bluetooch_ack)
        bluetooch_ack <= 1'b1;
      else 
        bluetooch_ack <= 1'b0;




smg_disp   u_seg_disp(
.clk         (sysclk    ),
.reset       (rst_sync_n),
.hc_data     (hc_s      ),
.seg_ment    (seg_ment  ),
.seg_sel     (seg_sel   )
   );

hc_sr04 hc_sr04_inst(
.clk    (sysclk     ),
.rst_n  (rst_sync_n ),
.echo   (hc_echo    ),
.trig   (hc_trig    ),
.park   (park       ),
.hc_pwm (hc_pwm     ),
.s_g    (s_g        ),
.s_s    (s_s        ),
.s_b    (s_b        ),
.s_q    (s_q        )
);


drive drive_inst( 
.clk            (sysclk),
.drive_en       (drive_en),
.turn           (turn), 
.park           (park),
.run_d          (run_d),
.pwm_r          (pwm_r),    //control driving
.pwm_t          (pwm_t),    //control turning
.park_f         (park_f)     //park finish
);

speed speed_inst(
.clk    (sysclk     ), 
.turn   (turn       ),
.park   (park       ),
.pwm_r  (pwm_r      ),
.pwm1   (pwm_r1     ),
.pwm2   (pwm_r2     )

    );
    
trace trace_inst(
.clk     (sysclk       ),
.mid     (trace_mid    ), 
.left    (trace_left   ), 
.right   (trace_right  ), 
.left_f  (trace_left_f ), 
.right_f (trace_right_f),    //left_far  right_far
.dir     (trace_dir    )
 );
 
 bluetooth bluetooth_inst(
.clk		  (sysclk           ),
.reset		  (rst_sync_n       ),
.hc05_rx	  (hc05_rx          ),
.hc05_tx	  (                 ),
.data_out     (bluetooch_dataout) 
);

  //timer irq
  timing timer_inst(
    .clk      (sysclk),
    .rst      (rst_sync),

    .valid    (mem_valid&(mem_addr>=TimerBaseAddr)&(mem_addr<=TimerBaseAddr+32'h4)),
    .strb     (mem_wstrb    ),
    .addr     (mem_addr[2:0]),
    .data_i   (mem_wdata    ),
    .ready    (timer_ready  ),
    .irq      (timer_irq    )
 );
   
  picorv32 #(.ENABLE_REGS_DUALPORT(0)) _picorv32(
    .clk      (sysclk     ),
    .resetn   (rst_sync_n ),
    .trap     (trap       ),
    .mem_valid(mem_valid  ),
    .mem_instr(mem_instr  ),
    .mem_ready(mem_ready  ),
    .mem_addr (mem_addr   ),
    .mem_wdata(mem_wdata  ),
    .mem_wstrb(mem_wstrb  ),
    .mem_rdata(mem_rdata  ),
    .irq      (irq        )
  );

  ram_2k_32 _ram_2k_32(sysclk, smem_addr[12:2], smem_wdata, smem_rdata, smem_wstrb, smem_valid && (smem_addr<32'h4000));

  always @(posedge sysclk)
		if(smem_valid && !smem_ready && (smem_addr<32'h4000))
			smem_ready <= 1;
		else 
			smem_ready <= 0;

endmodule


module ram_2k_32(
  input clk,
  input [10:0] addr,
  input [31:0] din,
  output [31:0] dout,
  input we,
  input en
);
 
  reg [31:0] mem[0:4095];

  initial
  begin
  $readmemh ("C:/Users/DELL/Desktop/FPGA/picorv32_prj/WorkSpace/demo/Debug/ram.hex", mem); //windows folder
	 // $readmemh ("D:/FPGA_PRJ/picorv32_prj/WorkSpace/demo/Debug/ram.hex", mem); //windows folder
	  //$readmemh ("/home/ise/ISE14.7_share/FPGA_PRJ/picorv32-Xilinx-ISE/WorkSpace/pico_spi_uart/Debug/ram.hex", mem); //linux folder
  end
  reg [10:0] addr1;
 
  always @(posedge clk)
    if (en) begin
      addr1 <= addr;
      if (we)
        mem[addr] <= din;
    end      

  assign dout = mem[addr1];

endmodule
