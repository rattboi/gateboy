// Represents a piece of memory attached to the bus

module Memory (interface db);
   parameter SIZE_BITS = 4;
   parameter BASE_ADDR = 16'h1000;
   localparam DECODER_MASK = ('1  << SIZE_BITS);
   localparam SIZE = (1'b1 << SIZE_BITS);
   bit [db.DATA_SIZE-1:0] tx_reg;
   bit [db.DATA_SIZE-1:0] memory [SIZE-1:0];


   assign db.data = (db.reading() && db.selected(BASE_ADDR,DECODER_MASK)) ? tx_reg : 'z;   
   
   always_latch  begin
      if(db.writing() && db.selected(BASE_ADDR, DECODER_MASK)) begin
         memory[db.addr & ~DECODER_MASK] = db.data;
      end
   end

   always_latch
     if(db.reading && db.selected(BASE_ADDR, DECODER_MASK))
       tx_reg = memory[db.addr & ~DECODER_MASK];
     
endmodule
