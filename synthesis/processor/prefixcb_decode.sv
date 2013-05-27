task prefixcb_decode(input opcode);
begin

  alias REG_NUM           = opcode[2:0];

  localparam ROT_INST     = 8'b000x_xxxx;
    alias C_bit           = opcode[4];
      localparam USE_C    = 0;
    alias DIR_bit         = opcode[3];
      localparam LEFT     = 0;
      localparam RIGHT    = 1;

  localparam SA_INST      = 8'b0010_xxxx;
    alias shift_dir       = opcode[3];
      // LEFT and RIGHT localparams above are consistant for Arithmatic Shifts.

  localparam SWAP_INST    = 8'b0011_0xxx;

  localparam SRL_INST     = 8'b0011_1xxx;

  localparam BIT_INST     = 8'b01xx_xxxx;
  localparam RES_INST     = 8'b10xx_xxxx;
  localparam SET_INST     = 8'b11xx_xxxx;
    alias bit_num         = opcode[5:3];


  always_comb
  begin
    unique casex(opcode)
      ROT_INST:   begin // Rotate Instructions
        // get register contents
        case({C_bit,DIR_bit})
          { USE_C, LEFT }:  ;// rotate left through C
          {~USE_C, LEFT }:  ;// rotate left
          { USE_C, RIGHT}:  ;// rotate right, through C
          {~USE_C, RIGHT}:  ;// rotate right
        endcase
        // write contents back
      end

      SA_INST:    begin  // Arithmatic Shift Instructions
        // get register contents
        if (shift_dir == LEFT) ; // arithmatic shift left
        else ;                   // arithmatic shift right
        // write contents back
      end

      SWAP_INST:  begin// Swap instructions
        // wat is swap
      end

      SRL_INST:   begin // Logical Shift Right
        // get register contents
        // value >> 1; value [7] = value[6]
        // write contents back
      end

      BIT_INST:   begin // Bit Check Instruction
        // get register contents
        // use bit_num to indes into result and set flags
      end

      RES_INST:   begin // Bit Reset Instruction
        // get register contents
        // use bit_num to indes into result and set clear
        // write contents back
      end

      SET_INST:   begin // Bit Set Instruction
        // get register contents
        // use bit_num to indes into result and set bit
        // write contents back
      end
    endcase
  end
endtask

