// This is an example test that uses the testrunner interface. Use it
// as an example when writing your own tests.


// Skeleton Testbench, useable as a template
`ifndef __SKEL_TB__
`define __SKEL_TB__
// all tests extend Test::BaseTest
class skel_tb extends BaseTest;

   // the meat and potatoes of the test. This task is executed to run
   // the test. The number of passed and failed subtests are returned.
   virtual task runTest(output int numPassed, int numFailed);
           numPassed++;
   endtask

   // called by test runner to get the name of the test. returns a
   // string. is optional.
   virtual function string getName();
      getName = "SkeletonTest";
   endfunction


endclass
`endif
