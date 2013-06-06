// This is an example test that uses the testrunner interface. Use it
// as an example when writing your own tests.

//TODO: comments

// Note that tests are included in the Test package, and therefore
// need C-style include guards. This also means that the class can
// access stuff in the Test namespace for free
`ifndef __VBLANK_TB__
`define __VBLANK_TB__

// all tests extend Test::BaseTest
class vblank_tb extends BaseTest;

   // the meat and potatoes of the test. This task is executed to run
   // the test. The number of passed and failed subtests are returned.
   virtual task runTest(output int numPassed, int numFailed);
      LcdStatus status;
      bit retval;
      db.write(8'h80, 16'hff40);
      waitForImage(retval);
      db.read(LCD_STAT_ADDR, status);
      if (status.Fields.Mode != RENDER_VBLANK) begin
         DebugPrint("Device does not enter VBlank at end of render");
         numFailed++;
      end else numPassed++;
   endtask // runTest

   // called by test runner to get the name of the test. returns a
   // string. is optional.
   virtual function string getName();
      getName = "VBlankTest";
   endfunction // getName


endclass
`endif //  `ifndef __WHIZZGRAPHICS_TB__ //TODO: this is also wrong, andy
