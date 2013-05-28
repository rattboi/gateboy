module tb();

   bit clk = 0;
   DataBus db(clk);
//   Dummy DUT(db);
   Memory MUT(db.peripheral);
   bit [db.DATA_SIZE-1:0] r;
   bit [db.ADDR_SIZE-1:0] address;
   int        numPassed = 0;
   bit [db.DATA_SIZE-1:0] d;
   
   initial forever #10 clk = ~clk;
   
   initial begin

      for (int i = 0; i < 900; i++) begin
         r = $urandom;
         address = (i & MUT.DECODER_MASK) + MUT.BASE_ADDR;
         db.write(r, address);
         db.read(address,d);
         if (d != r)
           $display("Could not transfer byte %x to addr %x", r, address);
         else begin
            $display("read %x from addr %x", d, address);
            numPassed++;
         end
      end
      db.read(16'h5100,d);
      if(d != 'z) 
        $display("Did not read high z value from un allocated addr");
      
      $display("Passed %d tests", numPassed);
      $finish;
   end
endmodule
