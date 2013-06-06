// Represents a piece of memory attached to the bus
//TODO: add comments
module Memory (interface db);
   parameter SIZE_BITS = 4;
   parameter BASE_ADDR = 16'h5000;
   localparam DECODER_MASK = (1 << SIZE_BITS) - 1;
   localparam SIZE = (1 << SIZE_BITS);
   bit [db.DATA_SIZE-1:0] tx_reg;
   bit  [db.DATA_SIZE-1:0] memory [SIZE];
   bit                    enable;

   assign db.data = (enable) ? tx_reg : 'z;   

   
   always @(posedge db.clk)  begin
      if(db.writing() && db.selected(BASE_ADDR, SIZE)) begin
         memory[db.addr & DECODER_MASK] = db.data;
      end
      else if(db.reading && db.selected(BASE_ADDR, SIZE)) begin
        tx_reg = memory[db.addr & DECODER_MASK];
         enable = 1;
      end
      else
        enable = 0;
   end


     
endmodule
