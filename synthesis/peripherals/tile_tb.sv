`ifndef __TILE_TB__
`define __TILE_TB__

// Tests that the background can be shifted in the x and y directions,
// and that shift to its maximum value, the display wraps around
class tile_tb extends BaseTest;

   // build a tile, and dump it out as the first tile
   virtual task runTest(output int numPassed, int numFailed);
      // this tile is whit at the edges, and black in the middle
      string tmptile [8]  = '{"33333333",
                              "32222223",
                              "32111123",
                              "32100123",
                              "32100123",
                              "32111123",
                              "32222223",
                              "33333333"};


      
      Lcd goodpic;
      
      db.write(8'h90, 16'hff40);
      for (int i = 0; i < VRAM_BACKGROUND1_SIZE; i++) begin
         db.write(1,VRAM_BACKGROUND1_ADDR+i);
         end
      writeTile(1, genTile(tmptile));
      
      // get the original image
      waitForImage();
      waitForImage();
      goodpic = cntrl.lcd;

      // enable sprites
      db.write(8'h92, 16'hff40);
      waitForImage();
      assert(goodpic == cntrl.lcd) numPassed++;
      else begin
         DebugPrint("Sprites are not transparent for color 0!");
         numFailed++;
      end
      
      db.write(4, 16'hff42);
      waitForImage();
      assert(goodpic != cntrl.lcd)
        numPassed++;
      else begin
         DebugPrint("Image scrolled in y dimension is not correct!");
         writeLCD(cntrl.lcd, "TileTest.pgm");
         writeLCD(goodpic, "TileTestGood.pgm");
         numFailed++;
      end

      assert(cntrl.lcd[0][4] == 0) numPassed++;
      else begin
         DebugPrint("Didn't get black value on the top edge");
         numFailed++;
      end
      
      db.write(8, 16'hff42);
      waitForImage();
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
      waitForImage();
      // the pix must be different
      assert(goodpic != cntrl.lcd)
        numPassed++;
      else begin
         DebugPrint("Image scrolled in x dimension is not correct!");
         writeLCD(cntrl.lcd, "TileTest.pgm");
         writeLCD(goodpic, "TileTestGood.pgm");
         numFailed++;
      end



      assert(cntrl.lcd[3][0] == 0) numPassed++;
      else begin
         DebugPrint("Didn't get black value on the right edge");
         numFailed++;
      end


      db.write(8, 16'hff43);
      waitForImage();
      assert(goodpic == cntrl.lcd)
        numPassed++;
      else begin
         DebugPrint("Image scrolled in x by tile multiple does not match!");
         writeLCD(cntrl.lcd, "TileTest.pgm");
         writeLCD(goodpic, "TileTestGood.pgm");
         numFailed++;
      end

      // wrapped ALL THE WAY!
      db.write(248, 16'hff42);
      db.write(248, 16'hff43);
      waitForImage();
      assert(goodpic == cntrl.lcd)
        numPassed++;
      else begin
         DebugPrint("Image scrolled all the way in both directions does not match!");
         writeLCD(cntrl.lcd, "TileTest.pgm");
         writeLCD(goodpic, "TileTestGood.pgm");
         numFailed++;
      end

   endtask

   virtual function string getName();
      getName = "TileTest";
   endfunction // getName


endclass
`endif

