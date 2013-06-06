`ifndef __SPRITE_TB__
`define __SPRITE_TB__

// Bunch of tests to demonstrate the sprite flip registers work
class sprite_tb extends BaseTest;

   virtual task runTest(output int numPassed, int numFailed);
      // one quadrant of this tile is white: used to demonstrate that
      // the sprite can be flipped
      string tmptile [8]  = '{"33330000",
                              "33330000",
                              "33330000",
                              "33330000",
                              "00000000",
                              "00000000",
                              "00000000",
                              "00000000"};
      
      Lcd goodpic;
      // enable lcd and sprites
      db.write(8'h82, LCDC_ADDR);

      // load the tile number for the sprite
      db.write(1, OAM_LOC+2);
      writeTile(1, genTile(tmptile));
      
      // get the original image
      waitForImage();
      waitForImage();
      goodpic = cntrl.lcd;

      // yflip
      db.write(8'h02, OAM_LOC+3);
      waitForImage();
      assert(goodpic != cntrl.lcd) numPassed++;
      else begin
         DebugPrint("yflipped image is same!");
         writeLCD(goodpic, "SpriteTest.pgm");
         numFailed++;
      end

      // xflip
      db.write(8'h02, OAM_LOC+3);
      waitForImage();
      assert(goodpic != cntrl.lcd) numPassed++;
      else begin
         DebugPrint("xflipped image is same!");
         writeLCD(goodpic, "SpriteTest.pgm");
         numFailed++;
      end

      // xy flip
      db.write(8'h06, OAM_LOC+3);
      waitForImage();
      assert(goodpic != cntrl.lcd) numPassed++;
      else begin
         DebugPrint("x and yflipped image is same!");
         writeLCD(goodpic, "SpriteTest.pgm");
         numFailed++;
      end

   endtask
   virtual function string getName();
      getName = "SpriteTest";
   endfunction


endclass
`endif

