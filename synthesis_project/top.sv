/* Project: Gateboy
 * Authors: Tyler Tricker
 * 
 * Description: top level module
 */
 
 module top(
 input bit clk);
 
 always @(posedge clk)
     $display("click");
 
 endmodule
 