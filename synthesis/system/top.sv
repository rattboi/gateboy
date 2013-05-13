
module top(input CLOCK_50);

int a = 0;

always_ff@(posedge CLOCK_50)
    a = a + 1;


endmodule
