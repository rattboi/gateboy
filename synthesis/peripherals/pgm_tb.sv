// Test the 
module pgm_tb();
   import video_types::*;
   Lcd picture1;
   Lcd picture2;
   initial begin
      for (int i = 0; i < 144; i++)
        for (int j = 0; j < 160; j++)
          picture1[i][j] = 2'h3;
      writeLCD(picture1, "asdf.pgm");
      picture2 =readLCD("asdf.pgm");
      if (picture1 == picture2) 
        $display("yay they are equal");
      else
        $display("dammit");
      $finish;
   end
endmodule
