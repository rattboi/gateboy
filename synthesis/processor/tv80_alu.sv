//
// TV80 8-Bit Microprocessor Core
// Based on the VHDL T80 core by Daniel Wallner (jesus@opencores.org)
//
// Copyright (c) 2004 Guy Hutchison (ghutchis@opencores.org)
//
// Permission is hereby granted, free of charge, to any person obtaining a 
// copy of this software and associated documentation files (the "Software"), 
// to deal in the Software without restriction, including without limitation 
// the rights to use, copy, modify, merge, publish, distribute, sublicense, 
// and/or sell copies of the Software, and to permit persons to whom the 
// Software is furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included 
// in all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, 
// EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF 
// MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. 
// IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY 
// CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, 
// TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE 
// SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
`include "tv80.pkg"
`include "tv80_alu.pkg"

module tv80_alu (
  output tv80::word Q,
  output tv80::word F_Out,

  // Inputs
  input Arith16,
  input Z16, 
  input [3:0] ALU_Op,
  input [5:0] IR,
  input [1:0] ISet,
  input tv80::word BusA,
  input tv80::word BusB,
  input tv80::word F_In
  );

  import tv80::*;
  import tv80_alu_definitions::*;

  parameter        Mode   = 3;
  parameter        Flag_C = 0;
  parameter        Flag_N = 1;
  parameter        Flag_P = 2;
  parameter        Flag_X = 3;
  parameter        Flag_H = 4;
  parameter        Flag_Y = 5;
  parameter        Flag_Z = 6;
  parameter        Flag_S = 7;

  function [4:0] AddSub4(input [3:0] A, [3:0] B, Sub, Carry_In);
      return { 1'b0, A } + { 1'b0, (Sub)?~B:B } + Carry_In;
  endfunction

  function [3:0] AddSub3(input [2:0] A, [2:0] B, Sub, Carry_In);
      return { 1'b0, A } + { 1'b0, (Sub)?~B:B } + Carry_In;
  endfunction

  function [1:0] AddSub1(input A, B, Sub, Carry_In);
      return { 1'b0, A } + { 1'b0, (Sub)?~B:B } + Carry_In;
  endfunction

  // AddSub variables (temporary signals)
  bit OverFlow_v;
  bit HalfCarry_v;
  bit Carry_v;
  bit [7:0] Q_v;      // adder output
  bit [7:0] BitMask;

  always_comb // Calculate adder output
    begin
      static logic Carry7_v;
      static logic UseCarry = 
          ALU_Op[1] ^ (!ALU_Op[2] && ALU_Op[0] && F_In[Flag_C]);

      BitMask = 8'b1 << 8'(IR[5:3]);

      {HalfCarry_v, Q_v[3:0]} = 
          AddSub4(BusA[3:0], BusB[3:0], ALU_Op[1], UseCarry);
      {Carry7_v, Q_v[6:4]}    = 
          AddSub3(BusA[6:4], BusB[6:4], ALU_Op[1], HalfCarry_v);
      {Carry_v, Q_v[7]}       = 
          AddSub1(BusA[7], BusB[7], ALU_Op[1], Carry7_v);

      OverFlow_v = Carry_v ^ Carry7_v;
    end // always_comb
  
    always_comb // Calculate Flags
        begin
        static logic [7:0] Q_t = 8'hxx;
        static logic [8:0] DAA_Q = {9{1'bx}};

        F_Out = F_In;
        unique case (ALU_Op)
        ADD, ADC,  SUB, SBC, AND, XOR, OR, CP: begin
            F_Out[Flag_N] = 1'b0;
            F_Out[Flag_C] = 1'b0;

            unique case (ALU_Op[2:0])
            ADD, ADC: begin
                Q_t = Q_v;
                F_Out[Flag_C] = Carry_v;
                F_Out[Flag_H] = HalfCarry_v;
                F_Out[Flag_P] = OverFlow_v;
            end
            SUB, SBC, CP: begin
                Q_t = Q_v;
                F_Out[Flag_N] = 1'b1;
                F_Out[Flag_C] = ~Carry_v;
                F_Out[Flag_H] = ~HalfCarry_v;
                F_Out[Flag_P] = OverFlow_v;
            end
            AND: begin
                Q_t[7:0] = BusA & BusB;
                F_Out[Flag_H] = 1'b1;
            end
            XOR: begin
                Q_t[7:0] = BusA ^ BusB;
                F_Out[Flag_H] = 1'b0;
            end
            OR: begin
                Q_t[7:0] = BusA | BusB;
                F_Out[Flag_H] = 1'b0;
            end
            endcase // case(ALU_OP[2:0])

            F_Out[Flag_X] = (ALU_Op[2:0] == CP) ? BusB[3] : Q_t[3];
            F_Out[Flag_Y] = (ALU_Op[2:0] == CP) ? BusB[5] : Q_t[5];
  
            F_Out[Flag_Z] = (Q_t[7:0] == 8'b0)? 
                                Z16 ? F_In[Flag_Z] : 1'b1
                            : 1'b0;

            F_Out[Flag_S] = Q_t[7];

            case (ALU_Op[2:0])
            ADD, ADC, SUB, SBC, CP: ;
            default :
                F_Out[Flag_P] = ~(^Q_t);
            endcase // case(ALU_Op[2:0])
                  
            if (Arith16 == 1'b1 ) begin
                F_Out[Flag_S] = F_In[Flag_S];
                F_Out[Flag_Z] = F_In[Flag_Z];
                F_Out[Flag_P] = F_In[Flag_P];
            end
        end // case 
              
        DAA: begin
          F_Out[Flag_H] = F_In[Flag_H];
          F_Out[Flag_C] = F_In[Flag_C];
          DAA_Q[7:0] = BusA;
          DAA_Q[8] = 1'b0;
          if (F_In[Flag_N] == 1'b0 ) 
          begin
                // After addition
                // Alow > 9 || H == 1
                if (DAA_Q[3:0] > 9 || F_In[Flag_H] == 1'b1 ) 
                begin
                    if ((DAA_Q[3:0] > 9) ) 
                        F_Out[Flag_H] = 1'b1;
                    else 
                        F_Out[Flag_H] = 1'b0;
                    DAA_Q = DAA_Q + 9'd6;
                end // if (DAA_Q[3:0] > 9 || F_In[Flag_H] == 1'b1 )
                // new Ahigh > 9 || C == 1
                if (DAA_Q[8:4] > 9 || F_In[Flag_C] == 1'b1 ) 
                    DAA_Q = DAA_Q + 9'd96; // 0x60
          end 
          else 
          begin
              // After subtraction
              if (DAA_Q[3:0] > 9 || F_In[Flag_H] == 1'b1 ) 
              begin
                  if (DAA_Q[3:0] > 5 ) 
                      F_Out[Flag_H] = 1'b0;
                  DAA_Q[7:0] = DAA_Q[7:0] - 8'd6;
              end
              if (BusA > 153 || F_In[Flag_C] == 1'b1 ) 
                  DAA_Q = DAA_Q - 9'd352; // 0x160
         end // else: !if(F_In[Flag_N] == 1'b0 )
              
              F_Out[Flag_X] = DAA_Q[3];
              F_Out[Flag_Y] = DAA_Q[5];
              F_Out[Flag_C] = F_In[Flag_C] || DAA_Q[8];
              Q_t = DAA_Q[7:0];
              
              if (DAA_Q[7:0] == 8'b00000000 ) 
                begin
              F_Out[Flag_Z] = 1'b1;
                end 
              else 
                begin
              F_Out[Flag_Z] = 1'b0;
                end
              
              F_Out[Flag_S] = DAA_Q[7];
              F_Out[Flag_P] = ~ (^DAA_Q);
            end // case: 4'b1100
          
          RLD, RRD:
              begin
              Q_t[7:4] = BusA[7:4];
              if (ALU_Op[0] == 1'b1 ) 
                  Q_t[3:0] = BusB[7:4];
              else 
                  Q_t[3:0] = BusB[3:0];
              F_Out[Flag_H] = 1'b0;
              F_Out[Flag_N] = 1'b0;
              F_Out[Flag_X] = Q_t[3];
              F_Out[Flag_Y] = Q_t[5];
              if (Q_t[7:0] == 8'b00000000 )
                  F_Out[Flag_Z] = 1'b1;
              else 
                  F_Out[Flag_Z] = 1'b0;
              F_Out[Flag_S] = Q_t[7];
              F_Out[Flag_P] = ~(^Q_t);
              end // case: RLD, RRD
          
          BIT:
            begin
              Q_t[7:0] = BusB & BitMask;
              F_Out[Flag_S] = Q_t[7];
              if (Q_t[7:0] == 8'b00000000 ) 
                  begin
                  F_Out[Flag_Z] = 1'b1;
                  F_Out[Flag_P] = 1'b1;
                  end 
              else 
                  begin
                  F_Out[Flag_Z] = 1'b0;
                  F_Out[Flag_P] = 1'b0;
                  end
              F_Out[Flag_H] = 1'b1;
              F_Out[Flag_N] = 1'b0;
              F_Out[Flag_X] = 1'b0;
              F_Out[Flag_Y] = 1'b0;
              if (IR[2:0] != 3'b110 ) 
                  begin
                  F_Out[Flag_X] = BusB[3];
                  F_Out[Flag_Y] = BusB[5];
                  end
            end // case: BIT
          
          SET:
            Q_t[7:0] = BusB | BitMask;
          
          RES:
            Q_t[7:0] = BusB & ~ BitMask;
          
          ROT:
              begin
              unique case (IR[5:3])
              ROT_RLC:
                   begin
                   Q_t[7:1] = BusA[6:0];
                   Q_t[0] = BusA[7];
                   F_Out[Flag_C] = BusA[7];
                   end
               
               ROT_RL:
                   begin
                   Q_t[7:1] = BusA[6:0];
                   Q_t[0] = F_In[Flag_C];
                   F_Out[Flag_C] = BusA[7];
                   end
               
               ROT_RRC:
                   begin
                   Q_t[6:0] = BusA[7:1];
                   Q_t[7] = BusA[0];
                   F_Out[Flag_C] = BusA[0];
                   end
               
               ROT_RR:
                   begin
                   Q_t[6:0] = BusA[7:1];
                   Q_t[7] = F_In[Flag_C];
                   F_Out[Flag_C] = BusA[0];
                   end
               
               ROT_SLA:
                   begin
                   Q_t[7:1] = BusA[6:0];
                   Q_t[0] = 1'b0;
                   F_Out[Flag_C] = BusA[7];
                   end
               
               ROT_SLL: // SLL (Undocumented) / SWAP
                 begin
               if (Mode == 3 ) 
                     begin
                   Q_t[7:4] = BusA[3:0];
                   Q_t[3:0] = BusA[7:4];
                   F_Out[Flag_C] = 1'b0;
                 end 
                   else 
                     begin
                   Q_t[7:1] = BusA[6:0];
                   Q_t[0] = 1'b1;
                   F_Out[Flag_C] = BusA[7];
                 end // else: !if(Mode == 3 )
                 end // case: 3'b110

               ROT_SRA:
                   begin
                   Q_t[6:0] = BusA[7:1];
                   Q_t[7] = BusA[7];
                   F_Out[Flag_C] = BusA[0];
                   end

               ROT_SRL:
                   begin
                   Q_t[6:0] = BusA[7:1];
                   Q_t[7] = 1'b0;
                   F_Out[Flag_C] = BusA[0];
                   end
             endcase // case(IR[5:3])

              F_Out[Flag_H] = 1'b0;
              F_Out[Flag_N] = 1'b0;
              F_Out[Flag_X] = Q_t[3];
              F_Out[Flag_Y] = Q_t[5];
              F_Out[Flag_S] = Q_t[7];
              if (Q_t[7:0] == 8'b00000000 ) 
                  F_Out[Flag_Z] = 1'b1;
              else 
                  F_Out[Flag_Z] = 1'b0;
              F_Out[Flag_P] = ~(^Q_t);

              if (ISet == 2'b00 ) begin
                  F_Out[Flag_P] = F_In[Flag_P];
                  F_Out[Flag_S] = F_In[Flag_S];
                  F_Out[Flag_Z] = F_In[Flag_Z];
              end
          end // case: ROT
          default: begin  // Invalid
            //assert(0) else $warning("Invalid ALU operation %b", ALU_Op);
            F_Out = '1;
            Q_t =   '1;
          end
          endcase // case(ALU_Op)
          Q = Q_t;
      end
endmodule // T80_ALU
