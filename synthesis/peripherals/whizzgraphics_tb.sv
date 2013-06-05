module w_tb();
   import video_types::*;
   bit clk = 0;
   DataBus db(clk);
   Control cntrl(clk);
   whizgraphics #(.DEBUG_OUT(1)) DUT(.db(db.peripheral), .cntrl(cntrl.DUT));
   bit [db.DATA_SIZE-1:0] r;
   bit [db.ADDR_SIZE-1:0] address;
   int        numPassed = 0;
   int        numFailed = 0;
   bit [db.DATA_SIZE-1:0] d;
   
   initial forever #10 clk = ~clk;
   
   initial begin

      for (int i = 0; i < DUT.OAM_SIZE; i++) begin 
         r = $urandom;
         address = i + DUT.OAM_LOC;
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
