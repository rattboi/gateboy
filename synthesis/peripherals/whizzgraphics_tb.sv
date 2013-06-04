module w_tb();
   import video_types::*;
   bit clk = 0;
   DataBus db(clk);
   wire drawline;
   wire renderComplete;
   Lcd lcd;
   bit  reset = 0;
   whizgraphics #(.DEBUG_OUT(1)) DUT(.*, .db(db.peripheral));
   bit [db.DATA_SIZE-1:0] r;
   bit [db.ADDR_SIZE-1:0] address;
   int        numPassed = 0;
   int        numFailed = 0;
   bit [db.DATA_SIZE-1:0] d;
   
   initial forever #10 clk = ~clk;
   
   initial begin

      for (int i = 0; i < 900; i++) begin : stop
         if (i >= DUT.OAM_SIZE)
           disable stop;
         r = $urandom;
         address = (i & DUT.OAM_MASK) + DUT.OAM_LOC;
         db.write(r, address);
         db.read(address,d);
         if (d == r) 
            numPassed++;
         else
           numFailed++;

      end
      
      $display("Passed %d tests", numPassed);
      $display("Failed %d tests", numFailed);
      $finish;
   end
endmodule
