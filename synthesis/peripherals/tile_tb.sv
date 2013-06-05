// This is an example test that uses the testrunner interface. Use it
// as an example when writing your own tests.



// Note that tests are included in the Test package, and therefore
// need C-style include guards. This also means that the class can
// access stuff in the Test namespace for free
`ifndef __TILE_TB__
`define __TILE_TB__

// all tests extend Test::BaseTest
class tile_tb extends BaseTest;

   // build a tile, and dump it out as the first tile
   virtual task runTest(output int numPassed, int numFailed);
      string tmptile [8]  = '{"33333333",
                              "32222223",
                              "32111123",
                              "32100123",
                              "32100123",
                              "32111123",
                              "32222223",
                              "33333333"};
      bit    stat;
      writeTile(0, tmptile);
      cntrl.resetDUT();
      waitForImage(stat);
      if (stat) begin
        writeLCD(cntrl.lcd, "TileTest.pgm");
         numPassed++;
      end else numFailed++;
   endtask // runTest

   // called by test runner to get the name of the test. returns a
   // string. is optional.
   virtual function string getName();
      getName = "TileTest";
   endfunction // getName


endclass
`endif //  `ifndef __WHIZZGRAPHICS_TB__

