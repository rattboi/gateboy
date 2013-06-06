`ifndef __VBLANK_TB__
`define __VBLANK_TB__

// Tests that the VBLANK flag is set at the end of each rendered frame
class vblank_tb extends BaseTest;

   virtual task runTest(output int numPassed, int numFailed);
      LcdStatus status;
      bit retval;
      db.write(8'h80, LCDC_ADDR);
      waitForImage(retval);
      db.read(LCD_STAT_ADDR, status);
      if (status.Fields.Mode != RENDER_VBLANK) begin
         DebugPrint("Device does not enter VBlank at end of render");
         numFailed++;
      end else numPassed++;
   endtask

   virtual function string getName();
      getName = "VBlankTest";
   endfunction


endclass
`endif
