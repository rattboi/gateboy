module tb_render();
	import video_types::*;

	localparam ACTIVE   = 1'b1;
	localparam INACTIVE = 0'b0;

	int a;
	int b;


	bit clk = 0;
   DataBus db(clk);
   logic drawline;
   wire renderComplete;
   bit  reset = 0;
   Lcd lcd;
	whizgraphics #(.DEBUG_OUT(0)) DUT(.*, .db(db.peripheral));

   // simple task to reset the whizgraphics hardware: necessary in
   // order to load the default palette.
   // TODO: This code is repro'd in palette_tb.sv
   // Code needs to by DRYer   
   task resetWhizgraphics();
      reset = 1;
      @db.clk; reset = 0;
   endtask

	function void ChangeBGMap(int x, int y, int TileNum);

		if(x > 31 || y > 31 || TileNum > 384)
			return;
		else
		begin
			DUT.vramBackground1.BackgroundMap[x][y] = TileNum;
			DUT.vramBackground2.BackgroundMap[x][y] = TileNum;
 		end

	endfunction


    initial 
    begin
        resetWhizgraphics();
		  //Change the background map to something different
		  ChangeBGMap(5,5,3);
		  $display("BGMAP: %b", DUT.vramBackground1.BackgroundMap[5][5]);

		  foreach(DUT.vramBackground1.BackgroundMap[a,b]);
		  begin
		     if(DUT.vramBackground1.BackgroundMap[a][b] != '0)
			     $display("BGMAP has a tile !=0");
		  end
		  
        //write data to tiles
        for(int i = 0; i < 32; i++)
        begin
            DUT.SetTilePixelValue(0, 0, i, 2'b00);
            DUT.SetTilePixelValue(0, 2, i, 2'b01);
            DUT.SetTilePixelValue(0, 4, i, 2'b10);
            DUT.SetTilePixelValue(0, 6, i, 2'b11);
        end
    //$display("Row 0: %b", DUT.tiles.Data[0].rows[0]);
    $display("Row 1: %b", DUT.tiles.Data[0].rows[1]);
    DUT.lcdPosition.Data.ScrollX = 1;
    end



	initial forever #10 clk = ~clk;

	assign drawline = clk;

	always @* begin
		if(renderComplete)
        begin
            writeLCD(lcd, "out1.pgm");
			   $finish;
        end
	end

	final begin
		$display("tb_render is done");
	end

endmodule
