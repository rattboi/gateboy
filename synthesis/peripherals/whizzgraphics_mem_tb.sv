// This file contains tests to verify that the memory locations in the
// DMG graphics driver can be accessed properly

module w_mem_tb();
   import video_types::*;
   bit clk = 0;
   DataBus db(clk);
   wire renderComplete;
   Lcd lcd;
   bit  reset = 1;
   whizgraphics #(.DEBUG_OUT(0)) DUT(.*, .db(db.peripheral), .drawline(clk));
   bit [db.DATA_SIZE-1:0] r;
   bit [db.ADDR_SIZE-1:0] address;
   int        numPassed = 0;
   int        numFailed = 0;
   bit [db.DATA_SIZE-1:0] d;
   
   initial forever #10 clk = ~clk;

   task tickleBus(int baseaddr, int size);
      bit [db.ADDR_SIZE-1:0] address;
      for (int i = 0; i < size; i++) begin : write 
         if (i >= size) disable write;
         r = $urandom;
         address = i + baseaddr;
         db.write(r, address);
         db.read(address,d);
         if (d != r) begin
           $display("Could not transfer byte %x to addr %x", r, address);
            numFailed++;
         end
         else begin
            numPassed++;
         end
      end 
      
   endtask
   
   initial begin
      // Test the different sections of the graphics memory
      $display("Testing OAM...");
      tickleBus(DUT.OAM_LOC, DUT.OAM_SIZE);
      $display("Testing VRAM BGND1...");
      tickleBus(DUT.VRAM_BACKGROUND1_ADDR, DUT.VRAM_BACKGROUND1_SIZE);
      $display("Testing VRAM BGND2...");
      tickleBus(DUT.VRAM_BACKGROUND2_ADDR, DUT.VRAM_BACKGROUND2_SIZE);
      $display("Testing LCD PALETTE...");
      tickleBus(DUT.LCD_PALLETE_ADDR, DUT.LCD_PALLETE_SIZE);
      $display("Testing LCD POS...");
      tickleBus(DUT.LCD_POS_ADDR, DUT.LCD_POS_SIZE);
      $display("Testing LCD WIN...");
      tickleBus(DUT.LCD_WIN_ADDR, DUT.LCD_WIN_SIZE);
      $display("Testing VRAM TILES...");
      tickleBus(DUT.VRAM_TILES_ADDR, DUT.VRAM_TILES_SIZE);

      $display("Passed %d tests", numPassed);
      $display("Failed %d tests", numFailed);
      $display("Attempting to draw pretty picture...");

      // try to write out the image, but have a 900 cycle timeout
      reset = 0;
      fork : tmpfork
         begin 
            repeat(900)@(posedge clk); 
            $display("aww... timeout."); 
            disable tmpfork; 
         end
         begin 
            wait(renderComplete); 
            $display("yay! art.");
            writeLCD(lcd, "out.pgm");
            disable tmpfork; 
         end
      join
      
      

      $finish;
   end
endmodule
