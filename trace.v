module trace(
                 input wire clk,
                 input wire mid, left, right, left_f, right_f,   //left_far  right_far
                 output reg  [4:0] dir

 );

  always @ (posedge clk)

    dir <= {left_f, left,  mid, right, right_f};

endmodule
 