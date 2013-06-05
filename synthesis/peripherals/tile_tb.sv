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
      Lcd goodpic;
      writeTile(0, tmptile);
      cntrl.resetDUT();

      // get the original image
      waitForImage(stat);
      goodpic = cntrl.lcd;

      db.write(4, 16'hff42);
      waitForImage(stat);
      assert(goodpic != cntrl.lcd)
        numPassed++;
      else begin
         DebugPrint("Image scrolled in y dimension is not correct!");
         writeLCD(cntrl.lcd, "TileTest.pgm");
         writeLCD(goodpic, "TileTestGood.pgm");
         numFailed++;
      end
      db.write(8, 16'hff42);
      waitForImage(stat);
      assert(goodpic == cntrl.lcd)
        numPassed++;
      else begin
         DebugPrint("Image scrolled in y by tile multiple does not match!");
         writeLCD(cntrl.lcd, "TileTest.pgm");
         writeLCD(goodpic, "TileTestGood.pgm");
         numFailed++;
      end
      db.write(0, 16'hff42);

      
      // Set the x to scroll up by half of a tile
      db.write(4, 16'hff43);
      waitForImage(stat);
      // the pix must be different
      assert(goodpic != cntrl.lcd)
        numPassed++;
      else begin
         DebugPrint("Image scrolled in x dimension is not correct!");
         writeLCD(cntrl.lcd, "TileTest.pgm");
         writeLCD(goodpic, "TileTestGood.pgm");
         numFailed++;
      end
      db.write(8, 16'hff43);
      waitForImage(stat);
      assert(goodpic == cntrl.lcd)
        numPassed++;
      else begin
         DebugPrint("Image scrolled in x by tile multiple does not match!");
         writeLCD(cntrl.lcd, "TileTest.pgm");
         writeLCD(goodpic, "TileTestGood.pgm");
         numFailed++;
      end
      
   endtask // runTest

   // called by test runner to get the name of the test. returns a
   // string. is optional.
   virtual function string getName();
      getName = "TileTest";
   endfunction // getName


endclass
`endif //  `ifndef __WHIZZGRAPHICS_TB__

