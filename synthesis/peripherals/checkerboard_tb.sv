// This is an example test that uses the testrunner interface. Use it
// as an example when writing your own tests.



// Note that tests are included in the Test package, and therefore
// need C-style include guards. This also means that the class can
// access stuff in the Test namespace for free
`ifndef __CHECKERBOARD_TB__
`define __CHECKERBOARD_TB__

// all tests extend Test::BaseTest
class checkerboard_tb extends BaseTest;

   // build a tile, and dump it out as the first tile
   virtual task runTest(output int numPassed, int numFailed);

      string checkerboard_tile [8]  = '{"33330000",
                                        "33330000",
                                        "33330000",
                                        "33330000",
                                        "00003333",
                                        "00003333",
                                        "00003333",
                                        "00003333"};

      string zero_tile [8] =          '{"33333333",
                                        "31111113",
                                        "31333313",
                                        "31333313",
                                        "31333313",
                                        "31333313",
                                        "31111113",
                                        "33333333"};

      bit    stat;
      Lcd firstpic;

      for (int i = 0; i < VRAM_BACKGROUND1_SIZE; i++) begin
         db.write(0,VRAM_BACKGROUND1_ADDR+i);
         end
      writeTile(0, genTile(checkerboard_tile));
      writeTile(256, genTile(zero_tile));
      db.write(8'h80, 16'hFF40);
      waitForImage(stat);
      waitForImage(stat);
      firstpic = cntrl.lcd;

      db.write(8'h90, 16'hFF40);

      waitForImage(stat);
      assert(cntrl.lcd != firstpic) numPassed++; 
      else begin
         DebugPrint("Resultant images are the same!");
         numFailed++;
      end
         writeLCD(firstpic, "out1.pgm");
         writeLCD(cntrl.lcd, "out2.pgm");
        
   endtask // runTest

   // called by test runner to get the name of the test. returns a
   // string. is optional.
   virtual function string getName();
      getName = "CheckerboardTest";
   endfunction // getName


endclass
`endif
