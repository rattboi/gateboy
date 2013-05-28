/* tv80-alu testbench
*  project: gateboy
*
*/

module testbench;

typedef bit[7:0] word;

/* ALU inputs */
bit       Arith16;
bit       Z16;
bit [3:0] ALU_Op;
bit [5:0] IR;
bit [1:0] ISet;
word      BusA;
word      BusB;
word      Q;
word      F_Out;

tv80_alu alu(
  Q, F_Out,  // Outputs
  Arith16, Z16, ALU_Op, IR, ISet, BusA, BusB, F_In); // Inputs

// This enum is order
typedef enum bit[3:0] {
    ADD, //0000
    ADC, //0001
    SUB, //0010
    SDC, //0011
    AND, //0100
    XOR, //0101
    OR,  //0110
    CP,  //0111
    ROT  //1000
    BIT, //1001
    SET, //1010
    RES, //1011
    DAA, //1100
    RLD, //1101
    RRD, //1110
} alu_operation;


always begin 
    $display("Testing things and stuff");
    $finish();
end

endmodule
