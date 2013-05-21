module tb();
   DataBus db();
   Dummy DUT(db);

   initial begin
      db.write(123, 0);
      #1 if (db.read(0) == 123)
        $display("Success!");
      else
        $display("Could not transfer byte...");
      $finish;
   end
endmodule
