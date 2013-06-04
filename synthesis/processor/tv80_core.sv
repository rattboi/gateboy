//
// TV80 8-Bit Microprocessor Core
// Based on the VHDL T80 core by Daniel Wallner (jesus@opencores.org)
//
// Copyright (c) 2004 Guy Hutchison (ghutchis@opencores.org)
//
// Permission is hereby granted, free of charge, to any person obtaining a 
// copy of this software and associated doutcumentation files (the "Software"), 
// to deal in the Software without restriction, including without limitation 
// the rights to use, copy, modify, merge, publish, distribute, sublicense, 
// and/or sell copies of the Software, and to permit persons to whom the 
// Software is furnished to dout so, subject to the following conditions:
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

`include "tv80_alu.pkg"

module tv80_core (  // Inputs
                    input           reset_n, 
                    input           clk,      
                    input           cen,      
                    input           wait_n, 
                    input           int_n, 
                    input           nmi_n, 
                    input           busrq_n, 
                    input   [7:0]   dinst, 
                    input   [7:0]   di,
                    // Outputs
                    output  logic         m1_n,         
                    output  logic         iorq, 
                    output                no_read, 
                    output                write, 
                    output  logic         rfsh_n, 
                    output  logic         halt_n, 
                    output  logic         busak_n, 
                    output  logic [15:0]  A, 
                    output  logic [7:0]   dout, 
                    output  logic [6:0]   mc, 
                    output  logic [6:0]   ts, 
                    output  logic         intcycle_n, 
                    output  logic         IntE, 
                    output  logic         stop, 
                    output        [15:0]  BC,
                    output        [15:0]  DE,
                    output        [15:0]  HL,
                    output        [7:0]   F,
                    output        [7:0]   ACC,
                    output        [15:0]  PC,
                    output        [15:0]  SP,
                    output                IntE_FF1, 
                    output                IntE_FF2, 
                    output                INT_s    
  );
  
  parameter Mode = 3;   // 0 => Z80, 1 => Fast Z80, 2 => 8080, 3 => GB
  parameter IOWait = 1; // 0 => Single cycle I/O, 1 => Std I/O cycle

  parameter Flag_C = 4;
  parameter Flag_N = 0;
  parameter Flag_P = 1;
  parameter Flag_X = 2;
  parameter Flag_H = 5;
  parameter Flag_Y = 6;
  parameter Flag_Z = 7;
  parameter Flag_S = 3;        

  parameter     aNone    = 3'b111;
  parameter     aBC      = 3'b000;
  parameter     aDE      = 3'b001;
  parameter     aXY      = 3'b010;
  parameter     aIOA     = 3'b100;
  parameter     aSP      = 3'b101;
  parameter     aZI      = 3'b110;

  // Registers
  logic [7:0]     Ap, Fp;
  logic [7:0]     I;
  logic [7:0]     R = 0;
  logic [7:0]     RegDIH;
  logic [7:0]     RegDIL;
  wire [15:0]   RegBusA;
  wire [15:0]   RegBusB;
  wire [15:0]   RegBusC;
  logic [2:0]     RegAddrA_r;
  logic [2:0]     RegAddrA;
  logic [2:0]     RegAddrB_r;
  logic [2:0]     RegAddrB;
  logic [2:0]     RegAddrC;
  logic           RegWEH;
  logic           RegWEL;
  logic           Alternate;

  // Help Registers
  logic [15:0]    TmpAddr;        // Temporary address logicister
  logic [7:0]     IR;             // Instruction logicister
  logic [1:0]     ISet;           // Instruction set selector
  logic [15:0]    RegBusA_r;

  logic [15:0]    ID16;
  logic [7:0]     Save_Mux;

  logic [6:0]     tstate;
  logic [6:0]     mcycle;
  logic           last_mcycle, last_tstate;
  logic           Halt_FF;
  logic           BusReq_s;
  logic           BusAck;
  logic           ClkEn;
  logic           NMI_s;
  logic [1:0]     IStatus;

  logic [7:0]     DI_Reg;
  logic           T_Res;
  logic [1:0]     XY_State;
  logic [2:0]     Pre_XY_F_M;
  logic           NextIs_XY_Fetch;
  logic           XY_Ind;
  logic           No_BTR;
  logic           BTR_r;
  logic           Auto_Wait;
  logic           Auto_Wait_t1;
  logic           Auto_Wait_t2;
  logic           IncDecZ;

  // ALU signals
  tv80::word      BusB;
  tv80::word      BusA;

  wire [7:0]      ALU_Q;
  tv80::word      F_Out;

  // Registered micro code outputs
  logic [4:0]     Read_To_Reg_r;
  logic           Arith16_r;
  logic           Z16_r;
  logic [3:0]     ALU_Op_r;
  logic           Save_ALU_r;
  logic           PreserveC_r;
  logic [2:0]     mcycles;

  // Micro code outputs
  wire [2:0]    mcycles_d;
  wire [2:0]    tstates;
  logic           IntCycle;
  logic           NMICycle;
  wire          Inc_PC;
  wire          Inc_WZ;
  wire [3:0]    IncDec_16;
  wire [1:0]    Prefix;
  wire          Read_To_Acc;
  wire          Read_To_Reg;
  wire [3:0]     Set_BusB_To;
  wire [3:0]     Set_BusA_To;

  logic [3:0]    ALU_Op;
  wire           Save_ALU;
  wire           PreserveC;
  wire           Arith16;
  wire [2:0]     Set_Addr_To;
  wire           Jump;
  wire           JumpE;
  wire           JumpXY;
  wire           Call;
  wire           RstP;
  wire           LDZ;
  wire           LDW;
  wire           LDSPHL;
  wire           iorq_i;
  wire [2:0]     Special_LD;
  wire           ExchangeDH;
  wire           ExchangeRp;
  wire           ExchangeAF;
  wire           ExchangeRS;
  wire           I_DJNZ;
  wire           I_CPL;
  wire           I_CCF;
  wire           I_SCF;
  wire           I_RETN;
  wire           I_BT;
  wire           I_BC;
  wire           I_BTR;
  wire           I_RLD;
  wire           I_RRD;
  wire           I_INRC;
  wire           SetDI;
  wire           SetEI;
  wire [1:0]     IMode;
  wire           Halt;

  logic [15:0]     PC16;
  logic [15:0]     PC16_B;
  logic [15:0]     SP16, SP16_A, SP16_B;
  logic [15:0]     ID16_B;
  
  tv80_mcode #(Mode, Flag_C, Flag_N, Flag_P, Flag_X, Flag_H, Flag_Y, Flag_Z, Flag_S) i_mcode
    ( .*,      
     .MCycle               (mcycle),
     .MCycles              (mcycles_d),
     .TStates              (tstates),
     .IORQ                 (iorq_i),
     .NoRead               (no_read),
     .Write                (write)
     );

  tv80_alu #(Mode, Flag_C, Flag_N, Flag_P, Flag_X, Flag_H, Flag_Y, Flag_Z, Flag_S) i_alu
    (
     .*,
     .Arith16              (Arith16_r),
     .Z16                  (Z16_r),
     .ALU_Op               (ALU_Op_r),
     .IR                   (IR[5:0]),
     .F_In                 (F),
     .Q                    (ALU_Q)
     );
  
  // first comb block
  always_comb
  begin
    if (mcycles > 0)
      last_mcycle = mcycle[mcycles -1];
    else 
      last_mcycle = 1'bx;

    if (tstates > 0)
      last_tstate = tstate[tstates -1];
    else 
      last_tstate = 1'bx;        
  end
  
  // second comb block
  always_comb
  begin
    ClkEn = cen && ~ BusAck;
    T_Res = (last_tstate) ? 1'b1 : 1'b0;
    
    if (XY_State != 2'b00 && XY_Ind == 1'b0 &&
        ((Set_Addr_To == aXY) ||
         (mcycle[0] && IR == 8'b11001011) ||
         (mcycle[0] && IR == 8'b00110110)))
      NextIs_XY_Fetch = 1'b1;
    else 
      NextIs_XY_Fetch = 1'b0;

    case ({ExchangeRp,Save_ALU_r})
      2'b11, 2'b10: Save_Mux = BusB;
      2'b00       : Save_Mux = DI_Reg;
      2'b01       : Save_Mux = ALU_Q;
    endcase
  end
  
  // first sequential block
  always_ff @(posedge clk)
    begin
      if (~reset_n)
      begin // resets
        // low reset signals
        { PC, A, TmpAddr, IR, ISet, XY_State, IStatus, mcycles, dout, Alternate, Read_To_Reg_r,
          Arith16_r, BTR_r, Z16_r, ALU_Op_r, Save_ALU_r, PreserveC_r, XY_Ind } <= #1 '0;
        
        // high reset signals
        { ACC, F, Ap, Fp, SP } <= #1 '1;
        
        // others 
        I <= #1 8'hFE;
        `ifdef TV80_REFRESH 
          R <= #1 '0; 
        `endif
      end 
        
      else 
        begin
          if (ClkEn == 1'b1 ) 
            begin
              {ALU_Op_r, Save_ALU_r, Read_To_Reg_r} <= #1 '0;
              mcycles <= #1 mcycles_d;

              if (IMode != 2'b11 ) 
                IStatus <= #1 IMode;

              Arith16_r   <= #1 Arith16;
              PreserveC_r <= #1 PreserveC;
              
              if (ISet == 2'b10 && ALU_Op[2] == 1'b0 && ALU_Op[0] == 1'b1 && mcycle[2] ) 
                Z16_r <= #1 1'b1;
              else 
                Z16_r <= #1 1'b0;

              if (mcycle[0] && (tstate[1] | tstate[2] | tstate[3] )) 
              begin
                if (tstate[2] && wait_n == 1'b1 ) 
                begin
                  `ifdef TV80_REFRESH // ifdef
                    if (Mode < 2 ) 
                    begin
                      A      <= #1 {I, R};
                      R[6:0] <= #1 R[6:0] + 1;
                    end
                  `endif // endif
                  
                  // PC
                  if (Jump == 1'b0 && Call == 1'b0 && NMICycle == 1'b0 && IntCycle == 1'b0 
                        && ~ (Halt_FF == 1'b1 || Halt == 1'b1) ) 
                    PC <= #1 PC16;

                  // IR
                  if (IntCycle == 1'b1 && IStatus == 2'b01 ) 
                    IR <= #1 '1;
                  else if (Halt_FF == 1'b1 || (IntCycle == 1'b1 && IStatus == 2'b10) || NMICycle == 1'b1 ) 
                    IR <= #1 '0;
                  else 
                    IR <= #1 dinst;

                  // ISet
                  ISet <= #1 2'b00;
                  
                  // Prefix dependent assignments
                  case (Prefix)
                    2'b11: XY_State   <= #1 (IR[5] == 1'b1) ? 2'b10 : 2'b01;
                            
                    2'b10: begin
                            ISet      <= #1 Prefix;
                            XY_State  <= #1 2'b00;
                            XY_Ind    <= #1 1'b0;
                          end
                          
                    2'b01: ISet       <= #1 Prefix;
                    
                    2'b00: begin
                            XY_State  <= #1 '0;
                            XY_Ind    <= #1 '0;
                          end
                  endcase
                end // if (tstate == 2 && wait_n == 1'b1 )
              end // (mcycle[0] && (tstate[1] | tstate[2] | tstate[3] )) 
              
              else //  (mcycle[0] && (tstate[1] | tstate[2] | tstate[3] ))  == FALSE
              // original comment: either (mcycle > 1) OR (mcycle == 1 AND tstate > 3)
              begin
                if (mcycle[5]) 
                begin
                  XY_Ind <= #1 1'b1;
                  ISet <= #1 (Prefix == 2'b01) ? 2'b01 : ISet;
                end
                
                if (T_Res) 
                begin
                  BTR_r <= #1 (I_BT || I_BC || I_BTR) && ~ No_BTR;
                  
                  if (Jump) 
                    {A, PC} <=  #1 {2{DI_Reg, TmpAddr[7:0]}};
                  
                  else if (JumpXY) 
                    {A, PC} <= #1 {2{RegBusC}};

                  else if (Call || RstP) 
                    {A, PC} <= #1 {2{TmpAddr}};

                  else if (last_mcycle && NMICycle) 
                    {A, PC} <= #1 {2{16'b0000000001100110}};
                  
                  else if (mcycle[2] && IntCycle && IStatus == 2'b10) 
                    {A, PC} <=  #1 {2{I, TmpAddr[7:0]}};
                  
                  else 
                  begin
                    case (Set_Addr_To)
                      aXY : A <= #1 (XY_State == 2'b00) ? RegBusC : (NextIs_XY_Fetch) ? PC : TmpAddr;
                      aIOA : begin  
                              A[15:8] <= #1 (Mode == 3) ? '1 : (Mode == 2) ? DI_Reg : ACC;
                              A[7:0]  <= #1 DI_Reg;
                            end
                      aSP : A <= #1 SP;
                      aBC : A <= #1 (Mode == 3 && iorq_i) ? {8'hFF, RegBusC[7:0]} : RegBusC;                    
                      aDE : A <= #1 RegBusC;                    
                      aZI : A <= #1 (Inc_WZ) ? TmpAddr + 1'b1 : {DI_Reg, TmpAddr[7:0]};
                      default : A <= #1 PC;
                    endcase // case(Set_Addr_To)
                  end // else: !if(mcycle[2] && IntCycle == 1'b1 && IStatus == 2'b10 )

                  Save_ALU_r <= #1 Save_ALU;
                  ALU_Op_r <= #1 ALU_Op;
                  
                  if (I_CPL) 
                  begin // CPL
                    ACC       <= #1 ~ ACC;
                    F[Flag_Y] <= #1 ~ ACC[5];
                    F[Flag_H] <= #1 1'b1;
                    F[Flag_X] <= #1 ~ ACC[3];
                    F[Flag_N] <= #1 1'b1;
                  end
                  
                  if (I_CCF) 
                  begin // CCF
                    F[Flag_C] <= #1 ~ F[Flag_C];
                    F[Flag_Y] <= #1 ACC[5];
                    F[Flag_H] <= #1 F[Flag_C];
                    F[Flag_X] <= #1 ACC[3];
                    F[Flag_N] <= #1 1'b0;
                  end
                  
                  if (I_SCF) // SCF
                  begin
                    F[Flag_C] <= #1 1'b1;
                    F[Flag_Y] <= #1 ACC[5];
                    F[Flag_H] <= #1 1'b0;
                    F[Flag_X] <= #1 ACC[3];
                    F[Flag_N] <= #1 1'b0;
                  end
                end // if (T_Res == 1'b1 )
                

                if (tstate[2] && wait_n == 1'b1 ) 
                begin
                  if (ISet == 2'b01 && mcycle[6] ) 
                    IR <= #1 dinst;
                  if (JumpE || Inc_PC || BTR_r) 
                    PC <= #1 PC16;
                  if (RstP) 
                    TmpAddr <= #1 { 10'h0, IR[5:3], 3'h0 };
                end
                
                if (tstate[3] && mcycle[5] ) 
                  TmpAddr <= #1 SP16;

                if (((tstate[2] && wait_n == 1'b1) || (tstate[4] && mcycle[0]) ) && IncDec_16[2:0] == 3'b111 )
                  SP <= #1 SP16;

                if (LDSPHL) 
                  SP <= #1 RegBusC;

                if (ExchangeAF) 
                begin
                  Ap <= #1 ACC;
                  ACC <= #1 Ap;
                  Fp <= #1 F;
                  F <= #1 Fp;
                end
                
                if (ExchangeRS) 
                  Alternate <= #1 ~ Alternate;
              end // else: !if(mcycle  == 3'b001 && tstate(2) == 1'b0 )

              if (tstate[3]) 
              begin
                  TmpAddr[7:0]  <= #1 (LDZ) ? DI_Reg : TmpAddr[7:0];
                  TmpAddr[15:8] <= #1 (LDZ) ? DI_Reg : TmpAddr[15:8];

                if (Special_LD[2] == 1'b1 ) 
                  case (Special_LD[1:0])
                    2'b00 : begin
                              ACC <= #1 I;
                              F[Flag_P] <= #1 IntE_FF2;
                            end
                    
                    2'b01 : begin
                              ACC <= #1 R;
                              F[Flag_P] <= #1 IntE_FF2;
                            end
                    
                    2'b10 : I <= #1 ACC;
                    
                    `ifdef TV80_REFRESH                        
                    default: R <= #1 ACC;
                    `else
                    default: ;
                    `endif                        
                  endcase
              end // if (tstate == 3 )
              
              if ((I_DJNZ == 1'b0 && Save_ALU_r == 1'b1) || ALU_Op_r == 4'b1001 ) 
              begin
                if (Mode == 3) 
                begin
                  F[7:5] <= #1 F_Out[7:5];
                  F[4]   <= #1 (PreserveC_r == 1'b0) ? F_Out[4] : F[4];
                end 
                
                else 
                begin
                  F[7:1] <= #1 F_Out[7:1];
                  F[Flag_C] <= #1 (PreserveC_r == 1'b0) ? F_Out[0] : F[Flag_C];
                end
              end // if ((I_DJNZ == 1'b0 && Save_ALU_r == 1'b1) || ALU_Op_r == 4'b1001 )
              
              if (T_Res == 1'b1 && I_INRC == 1'b1 ) 
              begin
                {F[Flag_H], F[Flag_N]} <= #1 '0;
                F[Flag_Z] <= #1 (DI_Reg[7:0] == '0) ? 1'b1 : 1'b0;
                F[Flag_S] <= #1 DI_Reg[7];
                F[Flag_P] <= #1 ~ (^DI_Reg[7:0]);
              end // if (T_Res == 1'b1 && I_INRC == 1'b1 )
              
              if (tstate[1] && Auto_Wait_t1 == 1'b0 ) 
              begin
                dout <= #1 BusB;
                if (I_RLD == 1'b1 ) 
                begin
                  dout[3:0] <= #1 BusA[3:0];
                  dout[7:4] <= #1 BusB[3:0];
                end
                if (I_RRD == 1'b1 ) 
                begin
                  dout[3:0] <= #1 BusB[7:4];
                  dout[7:4] <= #1 BusA[3:0];
                end
              end

              if (T_Res) 
              begin
                Read_To_Reg_r[4:0]  <= #1 {Read_To_Reg, Set_BusA_To};
                
                if (Read_To_Acc == 1'b1 ) 
                  Read_To_Reg_r[4:0] <= #1 5'b10111;
              end

              if (tstate[1] && I_BT) 
              begin
                F[Flag_X] <= #1 ALU_Q[3];
                F[Flag_Y] <= #1 ALU_Q[1];
                F[Flag_H] <= #1 1'b0;
                F[Flag_N] <= #1 1'b0;
              end
              
              if (I_BC || I_BT) 
                F[Flag_P] <= #1 IncDecZ;

              if ((tstate[1] && Save_ALU_r == 1'b0 && Auto_Wait_t1 == 1'b0) ||
                  (Save_ALU_r == 1'b1 && ALU_Op_r != 4'b0111) ) 
              begin
                case (Read_To_Reg_r)
                  5'b10111 : ACC <= #1 Save_Mux;
                  5'b10110 : dout <= #1 Save_Mux;
                  5'b11000 : SP[7:0] <= #1 Save_Mux;
                  5'b11001 : SP[15:8] <= #1 Save_Mux;
                  5'b11011 : F <= #1 Save_Mux;
                  default  : ;
                endcase
              end // if ((tstate == 1 && Save_ALU_r == 1'b0 && Auto_Wait_t1 == 1'b0) ||...              
            end // if (ClkEn == 1'b1 )         
        end // else: !if(reset_n == 1'b0 )
    end
  
// second sequential block
  //-------------------------------------------------------------------------
  //
  // BC('), DE('), HL('), IX && IY
  //
  //-------------------------------------------------------------------------
  always @ (posedge clk)
  begin
    if (ClkEn == 1'b1 ) 
    begin
      // Bus A / Write
      RegAddrA_r <= #1  { Alternate, Set_BusA_To[2:1] };
      
      if (XY_Ind == 1'b0 && XY_State != 2'b00 && Set_BusA_To[2:1] == 2'b10 ) 
        RegAddrA_r <= #1 { XY_State[1],  2'b11 };

      // Bus B
      RegAddrB_r <= #1 { Alternate, Set_BusB_To[2:1] };
      if (XY_Ind == 1'b0 && XY_State != 2'b00 && Set_BusB_To[2:1] == 2'b10 ) 
        RegAddrB_r <= #1 { XY_State[1],  2'b11 };

      // Address from logicister
      RegAddrC <= #1 { Alternate,  Set_Addr_To[1:0] };
      
      // Jump (HL), LD SP,HL
      if ((JumpXY == 1'b1 || LDSPHL == 1'b1) ) 
        RegAddrC <= #1 { Alternate, 2'b10 };
      if (((JumpXY == 1'b1 || LDSPHL == 1'b1) && XY_State != 2'b00) || (mcycle[5]) ) 
        RegAddrC <= #1 { XY_State[1],  2'b11 };
        
      if (I_DJNZ == 1'b1 && Save_ALU_r == 1'b1 && Mode < 2 ) 
        IncDecZ <= #1 F_Out[Flag_Z];

      if ((tstate[2] || (tstate[3] && mcycle[0])) && IncDec_16[2:0] == 3'b100 ) 
        IncDecZ <= #1 (ID16 == 0) ? 1'b0 : 1'b1; 
      
      RegBusA_r <= #1 RegBusA;
    end
    
  end // always @ (posedge clk)
  
// RegAddr block
  always_comb
  begin
    // RegAddrA
    if ((tstate[2] || (tstate[3] && mcycle[0] && IncDec_16[2] == 1'b1)) && XY_State == 2'b00)
      RegAddrA = { Alternate, IncDec_16[1:0] };
    else if ((tstate[2] || (tstate[3] && mcycle[0] && IncDec_16[2] == 1'b1)) && IncDec_16[1:0] == 2'b10)
      RegAddrA = { XY_State[1], 2'b11 };
    else if (ExchangeDH == 1'b1 && tstate[3])
      RegAddrA = { Alternate, 2'b10 };
    else if (ExchangeDH == 1'b1 && tstate[4])
      RegAddrA = { Alternate, 2'b01 };
    else
      RegAddrA = RegAddrA_r;
    
    // RegAddrB
    RegAddrB = (ExchangeDH == 1'b1 && tstate[3]) ? {Alternate, 2'b01} : RegAddrB_r;
  end
  
// ReqWEL/RegWEH block
  always_comb
  begin
    RegWEH = 1'b0;
    RegWEL = 1'b0;
    
    if ((tstate[1] && Save_ALU_r == 1'b0 && Auto_Wait_t1 == 1'b0) ||
        (Save_ALU_r == 1'b1 && ALU_Op_r != 4'b0111) ) 
    begin
      case (Read_To_Reg_r)
        5'b10000 , 5'b10001 , 5'b10010 , 5'b10011 , 5'b10100 , 5'b10101:
          {RegWEH, RegWEL} = {~Read_To_Reg_r[0], Read_To_Reg_r[0]};
        default: {RegWEH, RegWEL} = '0;
      endcase // case(Read_To_Reg_r)
    end // if ((tstate == 1 && Save_ALU_r == 1'b0 && Auto_Wait_t1 == 1'b0) ||...
    
    if (ExchangeDH == 1'b1 && (tstate[3] || tstate[4]))
      {RegWEH, RegWEL} = '1;

    if (IncDec_16[2] == 1'b1 && ((tstate[2] && wait_n == 1'b1 && mcycle != 3'b001) || (tstate[3] && mcycle[0])) ) 
      {RegWEH, RegWEL} = (IncDec_16[1:0] == '1) ? {RegWEH, RegWEL} : '1;
  end // always @ *
  
// RegDIH/RegDIL block
  always_comb
  begin
    if (ExchangeDH == 1'b1 && tstate[3] ) 
      {RegDIH, RegDIL} = RegBusB[15:0];

    else if (ExchangeDH == 1'b1 && tstate[4] )
      {RegDIH, RegDIL} = RegBusA_r[15:0];

    else if (IncDec_16[2] == 1'b1 && ((tstate[2] && mcycle != 3'b001) || (tstate[3] && mcycle[0])) ) 
      {RegDIH, RegDIL} = ID16[15:0];

    else
      {RegDIH, RegDIL} = {2{Save_Mux}};
  end

  tv80_reg i_reg
    (
     .*,
     .CEN                  (ClkEn),
     .WEH                  (RegWEH),
     .WEL                  (RegWEL),
     .AddrA                (RegAddrA),
     .AddrB                (RegAddrB),
     .AddrC                (RegAddrC),
     .DIH                  (RegDIH),
     .DIL                  (RegDIL),
     .DOAH                 (RegBusA[15:8]),
     .DOAL                 (RegBusA[7:0]),
     .DOBH                 (RegBusB[15:8]),
     .DOBL                 (RegBusB[7:0]),
     .DOCH                 (RegBusC[15:8]),
     .DOCL                 (RegBusC[7:0])
     );

  //-------------------------------------------------------------------------
  // Bus Block
  //-------------------------------------------------------------------------
  always @ (posedge clk)
  begin
    if (ClkEn == 1'b1 ) 
    begin
      case (Set_BusB_To)
        4'b0111: BusB <= #1 ACC;
        4'b0000 , 4'b0001 , 4'b0010 , 4'b0011 , 4'b0100 , 4'b0101: 
          BusB <= #1 (Set_BusB_To[0]) ? RegBusB[7:0] : RegBusB[15:8];
        4'b0110 : BusB <= #1 DI_Reg;
        4'b1000 : BusB <= #1 SP[7:0];
        4'b1001 : BusB <= #1 SP[15:8];
        4'b1010 : BusB <= #1 8'b00000001;
        4'b1011 : BusB <= #1 F;
        4'b1100 : BusB <= #1 PC[7:0];
        4'b1101 : BusB <= #1 PC[15:8];
        4'b1110 : BusB <= #1 8'b00000000;
        default : BusB <= #1 8'hxx;
      endcase

      case (Set_BusA_To)
        4'b0111 : BusA <= #1 ACC;
        4'b0000 , 4'b0001 , 4'b0010 , 4'b0011 , 4'b0100 , 4'b0101 :
          BusA <= #1 (Set_BusA_To[0]) ? RegBusA[7:0] : RegBusA[15:8];
        4'b0110 : BusA <= #1 DI_Reg;
        4'b1000 : BusA <= #1 SP[7:0];
        4'b1001 : BusA <= #1 SP[15:8];
        4'b1010 : BusA <= #1 8'b00000000;
        default : BusB <= #1  8'hxx;
      endcase
    end
  end

  //-------------------------------------------------------------------------
  // Generate external control signals
  //-------------------------------------------------------------------------
`ifdef TV80_REFRESH
  always @ (posedge clk)
  begin
    if (reset_n == 1'b0 ) 
      rfsh_n <= #1 '1;
    else if (cen) 
      rfsh_n <= #1 (mcycle[0] && ((tstate[2]  && wait_n == 1'b1) || tstate[3])) ? '0 : '1;
    else 
      rfsh_n <= '1;
  end
`endif  

// second control signal block
  always_comb
  begin
    mc = mcycle;
    ts = tstate;
    DI_Reg = di;
    halt_n = ~ Halt_FF;
    busak_n = ~ BusAck;
    intcycle_n = ~ IntCycle;
    IntE = IntE_FF1;
    iorq = iorq_i;
    stop = I_DJNZ;
  end

  //-----------------------------------------------------------------------
  // Syncronise inputs
  //-----------------------------------------------------------------------
  always @ (posedge clk)
  begin : sync_inputs
    if (reset_n == 1'b0 ) 
      {BusReq_s, INT_s, NMI_s} <= #1 '0;

    else if (cen)
    begin 
      BusReq_s <= #1 ~ busrq_n;
      INT_s <= #1 ~ int_n;  
      NMI_s <= #1 (NMICycle) ? '0 : '1;
    end
  end  

  //-----------------------------------------------------------------------
  // Main state machine
  //-----------------------------------------------------------------------
  always @ (posedge clk)
  begin
    if (reset_n == 1'b0 ) 
    begin
      mcycle <= #1 7'b0000001;
      tstate <= #1 7'b0000001;
      Pre_XY_F_M <= #1 3'b000;
      Halt_FF <= #1 1'b0;
      BusAck <= #1 1'b0;
      NMICycle <= #1 1'b0;
      IntCycle <= #1 1'b0;
      IntE_FF1 <= #1 1'b0;
      IntE_FF2 <= #1 1'b0;
      No_BTR <= #1 1'b0;
      Auto_Wait_t1 <= #1 1'b0;
      Auto_Wait_t2 <= #1 1'b0;
      m1_n <= #1 1'b1;
    end 
    
    else if (cen)
    begin
      if (T_Res) 
        Auto_Wait_t1 <= #1 (T_Res) ? 1'b0 : (Auto_Wait || iorq_i);
       
      Auto_Wait_t2 <= #1 Auto_Wait_t1;
      No_BTR <= #1 (I_BT && (~ IR[4] || ~ F[Flag_P])) ||
                (I_BC && (~ IR[4] || F[Flag_Z] || ~ F[Flag_P])) ||
                (I_BTR && (~ IR[4] || F[Flag_Z]));
                
      if (tstate[2]) 
      begin
        if (SetEI) 
          {IntE_FF1, IntE_FF2} <= #1 '1;
        if (I_RETN) 
          IntE_FF1 <= #1 IntE_FF2;
      end
      
      if (tstate[3] && SetDI)
        {IntE_FF1, IntE_FF2} <= #1 '0;

      if (IntCycle || NMICycle)
        Halt_FF <= #1 1'b0;
      
      if (mcycle[0] && tstate[2] && wait_n == 1'b1 ) 
        m1_n <= #1 1'b1;
      
      if (!(BusReq_s == 1'b1 && BusAck == 1'b1)) 
      begin
        BusAck <= #1 1'b0;
        
        if (T_Res && ((tstate[2] && wait_n == 1'b0 ))) 
        begin
          Halt_FF <= #1 (Halt) ? '1 : Halt_FF;
          
          if (BusReq_s == 1'b1 ) 
            BusAck <= #1 1'b1;
          
          else // busreq == 0
          begin
            tstate <= #1 7'b0000010;
            if (NextIs_XY_Fetch == 1'b1 ) 
            begin
              mcycle <= #1 7'b0100000;
              Pre_XY_F_M <= #1 mcycle[2:0];
              
              if (IR == 8'b00110110 && Mode == 0 ) 
                Pre_XY_F_M <= #1 3'b010;
            end 
            
            else if ((mcycle[6]) || (mcycle[5] && Mode == 1 && ISet != 2'b01) ) 
              mcycle <= #1 1'b1 << (Pre_XY_F_M + 1'b1);                              

            else if ((last_mcycle) || No_BTR == 1'b1 ||
                     (mcycle[1] && I_DJNZ == 1'b1 && IncDecZ == 1'b1) ) 
            begin
              m1_n <= #1 1'b0;
              mcycle <= #1 7'b0000001;
              IntCycle <= #1 1'b0;
              NMICycle <= #1 1'b0;
              if (NMI_s == 1'b1 && Prefix == 2'b00 ) 
              begin
                NMICycle <= #1 1'b1;
                IntE_FF1 <= #1 1'b0;
              end 
              else if ((IntE_FF1 == 1'b1 && INT_s == 1'b1) && Prefix == 2'b00 && SetEI == 1'b0 ) 
              begin
                IntCycle <= #1 1'b1;
                IntE_FF1 <= #1 1'b0;
                IntE_FF2 <= #1 1'b0;
              end
            end 
            else 
              mcycle <= #1 { mcycle[5:0], mcycle[6] };
          end
        end 
        
        else if ( ~(Auto_Wait == 1'b1 && Auto_Wait_t2 == 1'b0) &&  // verilog has no "nor" operator
                 ~(IOWait == 1 && iorq_i == 1'b1 && Auto_Wait_t1 == 1'b0) ) 
          tstate <= #1 { tstate[5:0], tstate[6] };   
      end
      
      if (tstate[0]) 
        m1_n <= #1 1'b0;
    end
  end
  
// second state machine sequential block
  always_comb
  begin
    PC16_B = (JumpE) ? {{8{DI_Reg[7]}}, DI_Reg} : (BTR_r) ? -16'd2 : 1'b1;

    if (tstate[3])
    begin
      SP16_A = RegBusC;
      SP16_B = { {8{DI_Reg[7]}}, DI_Reg };
    end
    
    else
    begin
      // suspect that ID16 and SP16 could be shared
      SP16_A = SP;
      
      if (IncDec_16[3] == 1'b1)
        SP16_B = -16'd1;
      else
        SP16_B = 1;
    end

    if (IncDec_16[3])  
      ID16_B = -16'd1;
    else
      ID16_B = 1;

    ID16 = RegBusA + ID16_B;
    PC16 = PC + PC16_B;
    SP16 = SP16_A + SP16_B;
  end // always @ *
  
// third state machine sequential block (can be replaced with the following)
  assign Auto_Wait = ((IntCycle == 1'b1 || NMICycle == 1'b1 ) && mcycle[0]) ? 1'b1 : 1'b0;
endmodule // T80

