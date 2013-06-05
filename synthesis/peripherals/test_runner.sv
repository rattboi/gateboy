// implements a runner for a bunch of test objects

module TestRunner();
   import Test::*;
   import video_types::*;
   BaseTest tests[$];
   bit clk = 0;
   DataBus db(clk);
   Control cntrl(clk);
   whizgraphics #(.DEBUG_OUT(0)) DUT(.db(db.peripheral), .cntrl(cntrl.DUT));
   initial forever #10 clk = ~clk;
   initial begin
      automatic  whizzgraphics wg = new;
      tests.push_front(wg);
      BaseTest::DebugLevel = LOG_ENABLED;
      while (tests.size() > 0) begin
         int numPassed, numFailed;
         BaseTest t;
         t = tests.pop_front();
         t.db = db;
         t.cntrl = cntrl;
         $display("Testing %m", t);
         t.runTest(numPassed, numFailed);
         $display("Passed Tests: %0d", numPassed);
         $display("Failed Tests: %0d", numFailed);
         $finish;
      end
      
   end
endmodule
