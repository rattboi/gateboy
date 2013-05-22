typedef enum bit[2:0] {
  REG_B,
  REG_C,
  REG_D,
  REG_E,
  REG_H,
  REG_L,
  MEM_HL,
  REG_A } reg_name;

task reg_lookup(input reg_name r, output [7:0] retval)
  begin
    case (r)
      REG_B:
        retval = registerfile.r8bit.B;

      REG_C:
        retval = registerfile.r8bit.C;

      REG_D:
        retval = registerfile.r8bit.D;

      REG_E:
        retval = registerfile.r8bit.E;

      REG_H:
        retval = registerfile.r8bit.H;

      REG_L:
        retval = registerfile.r8bit.L;

      MEM_HL:
        // not final at all
        // make some blocking call to read mem 4 cycles
        retval = Mem[registerfile.r16bit.HL];

      REG_A:
        retval = registerfile.r8bit.A;
    endcase
  end
endtask

task decode_single(input [7:0] opcode);
  begin
    casex(opcode)


    endcase
  end
endtask

task decode_CB(input [7:0] opcode);
  begin

  end
endtask

task decode(input [7:0] opcode);
  begin
    if (opcode != 0xCB)
      decode_single(opcode);
    else
      //FETCH next opcode
      decode_CB(next_opcode);
  end
endtask

