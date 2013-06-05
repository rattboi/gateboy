// implements a runner for a bunch of test objects
module TestRunner();

   // import everything
   import Test::*;
   import video_types::*;
   
   BaseTest tests[$];
   bit clk = 0;
   DataBus db(clk);
   Control cntrl(clk);
   whizgraphics #(.DEBUG_OUT(0)) DUT(.db(db.peripheral), .cntrl(cntrl.DUT));

   // setup the clock
   initial forever #10 clk = ~clk;
   
   initial begin
      // for each test that you create, you need to create an instance
      // and add it to this queue:
      automatic  whizzgraphics wg = new;
      automatic  w_mem_tb wmem = new;
      automatic vblank_tb vb= new;
      tests.push_front(vb);
      tests.push_front(wg);      
      tests.push_front(wmem);


      // is logging enabled?
      BaseTest::DebugLevel = LOG_DISABLED;

      // the meat of the simulation, and the beauty of the test runner
      // system. Each test get the following done to it:
      while (tests.size() > 0) begin
         // keep track of the number of passfails
         int numPassed, numFailed;
         // handle to the current test
         BaseTest t;
         // pull out a test
         t = tests.pop_front();
         // connect the interfaces
         t.db = db;
         t.cntrl = cntrl;
         cntrl.resetDUT();
         // display the name of the current test?
         // TODO: make this work better
         $display("Testing %s", t.getName());
         // run the actual test
         t.runTest(numPassed, numFailed);
         // display the results of this test
         $display("Passed Tests: %0d", numPassed);
         $display("Failed Tests: %0d", numFailed);

      end
      $finish;      
   end
endmodule
