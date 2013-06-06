module tb_render();
	import video_types::*;

	localparam PASSED   = 1'b0;
	localparam FAILED   = 0'b1;
	localparam TILE_NUM = 384;

	bit clk = 0;
   DataBus db(clk);
   Control cntrl(clk);
	whizgraphics #(.DEBUG_OUT(1)) DUT(.db(db.peripheral), .cntrl(cntrl.DUT));

   // simple task to reset the whizgraphics hardware: necessary in
   // order to load the default palette.
   // TODO: This code is repro'd in palette_tb.sv
   // Code needs to by DRYer   
   task resetWhizgraphics();
      cntrl.reset = 1;
      @db.clk; cntrl.reset = 0;
   endtask


	//Background corrolates to vramBackground1 data structure
	function void ChangeBGMap(int x, int y, int TileNum);

		if(x > 31 || y > 31 || TileNum > 384)
			return;
		else
		begin
			DUT.vramBackground1.BackgroundMap[x][y] = TileNum;
 		end

	endfunction

	//Window corrolates to vramBackground2 data structure
	function void ChangeWindowMap(int x, int y, int TileNum);

		if(x > 31 || y > 31 || TileNum > TILE_NUM)
			return;
		else
			DUT.vramBackground2.BackgroundMap[x][y] = TileNum;

	endfunction

	//Check to see if ExpectedVal is equal to that of what is
	//Stored at the x and y coordinates of of the BG map
	function bit BGTileCompare(int x, int y, int ExpectedVal);
		if(x > 31 || y > 31 || ExpectedVal > TILE_NUM)
			return FAILED;
		else if(DUT.vramBackground1.BackgroundMap[x][y] == ExpectedVal)
			return PASSED;
		else
			return FAILED;

	endfunction


   initial 
   begin
		  //This function needs to happen in order to
		  // have whizgraphics module render
        resetWhizgraphics();

		  //Change the background map to something different
		  //ChangeBGMap(0,0,1);
		  $display("Tile compare: %b", BGTileCompare(5,5,3));

        //write data to tiles
        for(int i = 0; i < 32; i++)
        begin
            DUT.SetTilePixelValue(0, 0, i, 2'b00);
            DUT.SetTilePixelValue(0, 1, i, 2'b01);
            DUT.SetTilePixelValue(0, 2, i, 2'b10);
            DUT.SetTilePixelValue(0, 3, i, 2'b11);
            DUT.SetTilePixelValue(0, 4, i, 2'b00);
            DUT.SetTilePixelValue(0, 5, i, 2'b01);
            DUT.SetTilePixelValue(0, 6, i, 2'b10);
            DUT.SetTilePixelValue(0, 7, i, 2'b11);
        end

        //write test sprite tile
        DUT.SetTilePixelValue(1, 0, 0, 2'b10);
        DUT.SetTilePixelValue(1, 1, 0, 2'b10);
        DUT.SetTilePixelValue(1, 2, 0, 2'b10);
        DUT.SetTilePixelValue(1, 0, 1, 2'b10);
        DUT.SetTilePixelValue(1, 1, 1, 2'b10);
        DUT.SetTilePixelValue(1, 2, 1, 2'b10);
        DUT.SetTilePixelValue(1, 0, 2, 2'b10);
        DUT.SetTilePixelValue(1, 1, 2, 2'b10);
        DUT.SetTilePixelValue(1, 2, 2, 2'b10);

        DUT.oam_table.Attributes[0].Fields.Tile = 1;
        DUT.oam_table.Attributes[0].Fields.XPosition = 10;
        DUT.oam_table.Attributes[0].Fields.YPosition = 10;

        //DUT.lcdPosition.Data.ScrollX = 250;


	 	//DUT.lcdPalletes.Data.indexedPalettes[PALETTE_BACKGROUND].raw = 8'h1b;

        DUT.lcdControl.Fields.SpriteEnable = 1;
        DUT.lcdControl.Fields.LCDEnable = 1;

         $display("Tile Data:");
         for(int i = 0; i < 4; i++)
         begin
            $display("%d: %p", i, DUT.tiles.Data[i]);
         end
    end

	initial forever #10 clk = ~clk;

	//Stuff to do after initial blocks
	always @* begin
		if(cntrl.renderComplete)
        begin
            writeLCD(cntrl.lcd, "out1.pgm");
			   $finish;
        end
	end

	//Final block of the test bench
	final begin
		$display("tb_render is done");
	end

endmodule
