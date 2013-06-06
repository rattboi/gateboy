// This is an example test that uses the testrunner interface. Use it
// as an example when writing your own tests.



// Note that tests are included in the Test package, and therefore
// need C-style include guards. This also means that the class can
// access stuff in the Test namespace for free
`ifndef __WHIZZGRAPHICS_TB__
`define __WHIZZGRAPHICS_TB__

// all tests extend Test::BaseTest
class whizzgraphics extends BaseTest;

   // the meat and potatoes of the test. This task is executed to run
   // the test. The number of passed and failed subtests are returned.
   virtual task runTest(output int numPassed, int numFailed);
      bit [0:7] r,d;
      bit [0:15] address;
      numPassed = 0;
      numFailed = 0;
      //TODO: use parameters
      for (int i = 0; i < 4*40; i++) begin 
         r = $urandom;
         address = i + 16'hfe00;
   
         db.write(r, address);
         db.read(address,d);
         if (d == r) begin
           numPassed++;
         end else begin
           // Use the static function BaseTest::DebugPrint to print debug messages
           DebugPrint($psprintf("writing to addr %x Failed", address));
           numFailed++;
         end
      end
   endtask // runTest

   // called by test runner to get the name of the test. returns a
   // string. is optional.
   virtual function string getName();
      getName = "SkeletonTest";
   endfunction // getName


endclass
`endif //  `ifndef __WHIZZGRAPHICS_TB__
