// This file contains tests to verify that the memory locations in the
// DMG graphics driver can be accessed properly
`ifndef __MEM_TB__
`define __MEM_TB__

class w_mem_tb extends BaseTest;

   
   virtual task tickleBus(int baseaddr, int size, output int numPassed, int numFailed);
      bit [15:0] address;
      bit [7:0] r,d;

      for (int i = 0; i < size; i++) begin : write 
         if (i >= size) disable write;
         r = $urandom;
         address = i + baseaddr;
         db.write(r, address);
         db.read(address,d);
         if (d != r) begin
           DebugPrint($psprintf("Could not transfer byte %x to addr %x", r, address));
            numFailed++;
         end
         else begin
            numPassed++;
         end
      end 
   endtask

   
   virtual task runTest(output int numPassed, numFailed);
      int p,f;
      bit SuccessState;
      cntrl.resetDUT();      
      // Test the different sections of the graphics memory
      DebugPrint("Testing OAM...");
      tickleBus(OAM_LOC, OAM_SIZE,  p,f);
      numPassed +=p; numFailed+=f;
      DebugPrint("Testing VRAM BGND1...");
      tickleBus(VRAM_BACKGROUND1_ADDR, VRAM_BACKGROUND1_SIZE, p,f);
      numPassed +=p; numFailed+=f;
      DebugPrint("Testing VRAM BGND2...");
      tickleBus(VRAM_BACKGROUND2_ADDR, VRAM_BACKGROUND2_SIZE,p,f);
      numPassed +=p; numFailed+=f;
      DebugPrint("Testing LCD PALETTE...");
      tickleBus(LCD_PALLETE_ADDR, LCD_PALLETE_SIZE,p,f);
      numPassed +=p; numFailed+=f;
      DebugPrint("Testing LCD POS...");
      tickleBus(LCD_POS_ADDR, LCD_POS_SIZE,p,f);
      numPassed +=p; numFailed+=f;
      DebugPrint("Testing LCD CONTROL REGISTER...");
      tickleBus(LCDC_ADDR, LCDC_SIZE,p,f);
      numPassed +=p; numFailed+=f;
      DebugPrint("Testing LCD WIN...");
      tickleBus(LCD_WIN_ADDR, LCD_WIN_SIZE,p,f);
      numPassed +=p; numFailed+=f;
      DebugPrint("Testing VRAM TILES...");
      tickleBus(VRAM_TILES_ADDR, VRAM_TILES_SIZE,p,f);
      numPassed +=p; numFailed+=f;

      // try to write out the image, but have a 900 cycle timeout
      cntrl.resetDUT();
      
      waitForImage(SuccessState);
      if(SuccessState) begin
         writeLCD(cntrl.lcd, "out.pgm");
         numPassed++;
      end
      else begin
         numFailed++;
         DebugPrint("Could not Create Image");
      end
   endtask
   
   virtual function string getName();
      getName = "MemoryTest";
   endfunction
endclass
`endif





