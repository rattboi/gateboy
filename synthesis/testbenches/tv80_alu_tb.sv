/* tv80-alu testbench
*  project: gateboy
*
*/

module testbench;

import tv80::*;
import tv80_alu_definitions::*;



/* ALU inputs */
bit       Arith16;
bit       Z16;
bit [3:0] ALU_Op;
bit [5:0] IR;
bit [1:0] ISet;
word      BusA;
word      BusB;
word      F_In;
word      Q;
word      F_Out;


tv80_alu alu(
  Q, F_Out,  // Outputs
  Arith16, Z16, ALU_Op, IR, ISet, BusA, BusB, F_In); // Inputs


always begin 
    $display("Testing things and stuff");
    $finish();
end

endmodule

class alu_inputs;
 
  import tv80_alu_definitions::*;

  rand  bit       Arith16;
  rand  bit       Z16;
  randc ALU_Op_t  ALU_Op;
  rand  bit [5:0] IR;
  rand  bit [1:0] ISet;
  rand  word      BusA;
  rand  word      BusB;
  rand  word      F_In;


constraint add {
  ALU_Op == ADD;
}

constraint sub {
  ALU_Op == SUB;
}


endclass
