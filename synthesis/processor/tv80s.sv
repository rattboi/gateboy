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

module tv80s (  // Inputs
                input           reset_n,
                input           clk,
                input           wait_n,
                input           int_n,
                input           nmi_n,
                input           busrq_n,
                input     [7:0] di,

                // Outputs
                output          m1_n,
                output   logic  mreq_n,
                output   logic  iorq_n,
                output   logic  rd_n,
                output   logic  wr_n,
                output          rfsh_n,
                output          halt_n,
                output          busak_n,
                output   [15:0] A,
                output   [7:0]  dout,
                output   [15:0] BC,
                output   [15:0] DE,
                output   [15:0] HL,
                output   [7:0]  ACC,
                output   [7:0]  F,
                output   [15:0] PC,
                output   [15:0] SP, 
                output          IntE_FF1,
                output          IntE_FF2,
                output          INT_s
  );

  parameter   Mode =    3; // 0 => Z80, 1 => Fast Z80, 2 => 8080, 3 => GB
  parameter   T2Write = 1; // 0 => wr_n active in T3, /=0 => wr_n active in T2
  parameter   IOWait  = 1; // 0 => Single cycle I/O, 1 => Std I/O cycle
  localparam  cen =     1'b1;

  wire          intcycle_n;
  wire          no_read;
  wire          write;
  wire          iorq;
  logic [7:0]   di_reg;
  wire  [6:0]   mcycle;
  wire  [6:0]   tstate;

  tv80_core #(Mode, IOWait) i_tv80_core (
    .cen (cen),
    .m1_n (m1_n),
    .iorq (iorq),
    .no_read (no_read),
    .write (write),
    .rfsh_n (rfsh_n),
    .halt_n (halt_n),
    .wait_n (wait_n),
    .int_n (int_n),
    .nmi_n (nmi_n),
    .reset_n (reset_n),
    .busrq_n (busrq_n),
    .busak_n (busak_n),
    .clk (clk),
    .IntE (),
    .stop (),
    .A (A),
    .dinst (di),
    .di (di_reg),
    .dout (dout),
    .mc (mcycle),
    .ts (tstate),
    .intcycle_n (intcycle_n),
    .BC (BC),
    .DE (DE),
    .HL (HL),
    .F (F),
    .ACC (ACC),
    .PC (PC),
    .SP (SP),
    .IntE_FF1(IntE_FF1),
    .IntE_FF2(IntE_FF2),
    .INT_s(INT_s)
    );

  always_ff @(posedge clk)
  begin
    if (!reset_n)
    begin
      rd_n   <= #1 1'b1;
      wr_n   <= #1 1'b1;
      iorq_n <= #1 1'b1;
      mreq_n <= #1 1'b1;
      di_reg <= #1 0;
    end

    else
    begin
      rd_n   <= #1 1'b1;
      wr_n   <= #1 1'b1;
      iorq_n <= #1 1'b1;
      mreq_n <= #1 1'b1;

      if (mcycle[0])
      begin
        if (tstate[1] || (tstate[2] && wait_n == 1'b0))
        begin
          rd_n <= #1 ~ intcycle_n;
          mreq_n <= #1 ~ intcycle_n;
          iorq_n <= #1 intcycle_n;
        end
      `ifdef TV80_REFRESH
        if (tstate[3])
          mreq_n <= #1 1'b0;
      `endif
      end // if (mcycle[0])
      else
      begin
        if ((tstate[1] || (tstate[2] && wait_n == 1'b0)) && no_read == 1'b0 && write == 1'b0)
        begin
          rd_n <= #1 1'b0;
          iorq_n <= #1 ~ iorq;
          mreq_n <= #1 iorq;
        end
        if (T2Write == 0)
        begin
          if (tstate[2] && write == 1'b1)
          begin
            wr_n <= #1 1'b0;
            iorq_n <= #1 ~ iorq;
            mreq_n <= #1 iorq;
          end
        end
        else
        begin
          if ((tstate[1] || (tstate[2] && wait_n == 1'b0)) && write == 1'b1)
          begin
            wr_n <= #1 1'b0;
            iorq_n <= #1 ~ iorq;
            mreq_n <= #1 iorq;
          end
        end // else: !if(T2write == 0)

      end // else: !if(mcycle[0])

      if (tstate[2] && wait_n == 1'b1)
        di_reg <= #1 di;
    end // else: !if(!reset_n)
  end // always @ (posedge clk or negedge reset_n)
endmodule // t80s
