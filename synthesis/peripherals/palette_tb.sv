module palette_tb();
   import video_types::*;
   bit clk = 0;
   DataBus db(clk);

   wire renderComplete;
   Lcd lcd;
   bit  reset = 0;
   whizgraphics #(.DEBUG_OUT(1)) DUT(.*, .db(db.peripheral), .drawline(clk));
   bit [db.DATA_SIZE-1:0] r;
   bit [db.ADDR_SIZE-1:0] address;
   int        numPassed = 0;
   int        numFailed = 0;
   bit [db.DATA_SIZE-1:0] d;
      
   task resetWhizgraphics();
      reset = 1;
      @db.clk; reset = 0;
   endtask
   

   initial forever #10 clk = ~clk;
   
   initial begin
      PaletteType p;
      Color tmpcolor;
      resetWhizgraphics();
      p = p.first();
      do begin 
        for(int j = 0; j < 4; j++) begin
          tmpcolor = DUT.lcdPalletes.Data.indexedPalettes[p].indexedColors[j];
          if (tmpcolor != j) begin
             $display("incorrect palette value: expected %0d for color %0d of palette %s, got ",
                      j,j,p.name(), tmpcolor);
             numFailed++;
          end else begin
             numPassed++;
          end
        end
         p = p.next();         
      end while (p != p.first());
      
      
      $display("Passed %d tests", numPassed);
      $display("Failed %d tests", numFailed);
      $finish;
   end
endmodule
