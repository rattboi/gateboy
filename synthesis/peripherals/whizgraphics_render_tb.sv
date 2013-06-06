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
    


    //=================================
    //Testbench infrastructure
    //=================================
    int testCount = 0;
    int renderCount = 0;
    
    task TestSetup();
        //reset graphics system
        resetWhizgraphics(); 
    endtask

    function void TestTeardown();
        testCount++;
        renderCount = 0;
    endfunction

    //save file every time a render completes
    always @(posedge cntrl.renderComplete)
    begin
        writeLCD(cntrl.lcd, $psprintf("outputs/render_tb_out_%0d_%0d.pgm", testCount, renderCount));
        renderCount++;
        if(renderCount > 2)
            $finish;
    end

	final begin
        $display("Finished %d tests in tb_render", testCount);
	end


    //=================================
    // Common test helper functions
    //=================================
    function CreateTestTiles();
        static string checkerboardTileStr [8] = { "33330000",
                                           "33330000",
                                           "33330000",
                                           "33330000",
                                           "00003333",
                                           "00003333",
                                           "00003333",
                                           "00003333"};

        static string crossTileStr [8]        = { "00033000",
                                           "00033000",
                                           "00033000",
                                           "33333333",
                                           "33333333",
                                           "00033000",
                                           "00033000",
                                           "00033000"};

        static string vGradientTileStr [8]    = { "00000000",
                                           "00000000",
                                           "11111111",
                                           "11111111",
                                           "22222222",
                                           "22222222",
                                           "33333333",
                                           "33333333"};

        static string hGradientTileStr [8]    = { "00112233",
                                           "00112233",
                                           "11112233",
                                           "11112233",
                                           "22112233",
                                           "22112233",
                                           "33112233",
                                           "33112233"};

        //Tile 0 = black
        DUT.tiles.Data[0] = '0;
        //Tile 1 = checkerboard
        DUT.tiles.Data[1] = genTile(checkerboardTileStr);
        //Tile 2 = checkerboard
        DUT.tiles.Data[2] = genTile(crossTileStr);
        //Tile 3 = checkerboard
        DUT.tiles.Data[3] = genTile(vGradientTileStr);
        //Tile 4 = checkerboard
        DUT.tiles.Data[4] = genTile(hGradientTileStr);

    endfunction

    //=================================
    // Simple background test
    //=================================
    task test_background1();
        $display("Test 1");
        CreateTestTiles();
        DUT.lcdControl.Fields.LCDEnable = 1;
        DUT.vramBackground1.BackgroundMap[0][0] = 1;
        DUT.vramBackground1.BackgroundMap[0][1] = 2;
        DUT.vramBackground1.BackgroundMap[0][2] = 3;
        DUT.vramBackground1.BackgroundMap[0][3] = 4;
    endtask 

    task do_tests();
       TestSetup();
        test_background1();
       TestTeardown();
    endtask 

    initial
    begin
        do_tests();
    end



    /*
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
    */

	initial forever #10 clk = ~clk;

endmodule
