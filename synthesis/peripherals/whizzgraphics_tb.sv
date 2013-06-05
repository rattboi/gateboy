`ifndef __WHIZZGRAPHICS_TB__
`define __WHIZZGRAPHICS_TB__

class whizzgraphics extends BaseTest;
   
   virtual task runTest(output int numPassed, int numFailed);
      bit [0:7] r,d;
      bit [0:15] address;
      numPassed = 0;
      numFailed = 0;
      for (int i = 0; i < 4*40; i++) begin 
         r = $urandom;
         address = i + 16'hfe00;
   
         db.write(r, address);
         db.read(address,d);
         if (d == r) begin
           numPassed++;
         end else begin
           BaseTest::DebugPrint($psprintf("writing to addr %x Failed", address));
           numFailed++;
         end
      end
   endtask // runTest

   virtual function string getName();
      getName = "SkeletonTest";
   endfunction // getName


endclass
`endif //  `ifndef __WHIZZGRAPHICS_TB__
