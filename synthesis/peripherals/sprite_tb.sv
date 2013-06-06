// This is an example test that uses the testrunner interface. Use it
// as an example when writing your own tests.



// Note that tests are included in the Test package, and therefore
// need C-style include guards. This also means that the class can
// access stuff in the Test namespace for free
`ifndef __SPRITE_TB__
`define __SPRITE_TB__

// all tests extend Test::BaseTest
class sprite_tb extends BaseTest;

   // build a tile, and dump it out as the first tile
   virtual task runTest(output int numPassed, int numFailed);
      // this tile is whit at the edges, and black in the middle
      string tmptile [8]  = '{"33330000",
                              "33330000",
                              "33330000",
                              "33330000",
                              "00000000",
                              "00000000",
                              "00000000",
                              "00000000"};
      
      bit    stat;
      Lcd goodpic;
      
      db.write(8'h82, 16'hff40);

      db.write(1, OAM_LOC+2);
      writeTile(1, genTile(tmptile));
      
      // get the original image
      waitForImage(stat);
      waitForImage(stat);
      goodpic = cntrl.lcd;

      // yflip
      db.write(8'h02, OAM_LOC+3);
      waitForImage(stat);
      assert(goodpic != cntrl.lcd) numPassed++;
      else begin
         DebugPrint("yflipped image is same!");
         writeLCD(goodpic, "SpriteTest.pgm");
         numFailed++;
      end

      // xflip
      db.write(8'h02, OAM_LOC+3);
      waitForImage(stat);
      assert(goodpic != cntrl.lcd) numPassed++;
      else begin
         DebugPrint("xflipped image is same!");
         writeLCD(goodpic, "SpriteTest.pgm");
         numFailed++;
      end

      // xy flip
      db.write(8'h06, OAM_LOC+3);
      waitForImage(stat);
      assert(goodpic != cntrl.lcd) numPassed++;
      else begin
         DebugPrint("x and yflipped image is same!");
         writeLCD(goodpic, "SpriteTest.pgm");
         numFailed++;
      end

      

   endtask // runTest

   // called by test runner to get the name of the test. returns a
   // string. is optional.
   virtual function string getName();
      getName = "SpriteTest";
   endfunction // getName


endclass
`endif //  `ifndef __WHIZZGRAPHICS_TB__

