module tb();
   DataBus db();
   Dummy DUT(db);
   Memory MUT(db);
   bit [db.DATA_SIZE-1:0] r;
   bit [db.ADDR_SIZE-1:0] address;
   int        numPassed = 0;

   
   initial begin
      $display("decoder mask: %x", MUT.DECODER_MASK);
      db.write(123, 0);
      #1 if (db.read(0) == 123) begin
         numPassed++;
      end
      else
        $display("Could not transfer byte...");

      for (int i = 0; i < 100; i++) begin
         r = $urandom;
         address = (i & ~MUT.DECODER_MASK) + MUT.BASE_ADDR;
         #1 db.write(r, address);
         #1 if (db.read(address) != r)
           $display("Could not transfer byte %x to addr %x", r, address);
         else
           numPassed++;
      end
      $display("Passed %d tests", numPassed);
      $finish;
   end
endmodule
