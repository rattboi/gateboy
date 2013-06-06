module tb_render();
	import video_types::*;

	localparam PASSED   = 1'b0;
	localparam FAILED   = 0'b1;
	localparam TILE_NUM = 384;

	bit clk = 0;
   DataBus db(clk);
   Control cntrl(clk);
	whizgraphics #(.DEBUG_OUT(0)) DUT(.db(db.peripheral), .cntrl(cntrl.DUT));

   // simple task to reset the whizgraphics hardware: necessary in
   // order to load the default palette.
   task resetWhizgraphics();
       cntrl.resetDUT();
   endtask


    initial forever #10 clk = ~clk;

   //TODO: delete these?
	//Background corrolates to vramBackground1 data structure
	function void ChangeBGMap(int x, int y, int TileNum);

        assert(x <= 31 && y <= 31 && TileNum <= 384)
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
    int renderDisable = 0;
    
    task TestSetup();
        //reset graphics system
        resetWhizgraphics(); 
        //create set of test tiles
        CreateTestTiles();
    endtask

    function void TestTeardown();
        testCount++;
        renderCount = 0;
        renderDisable = 0;
    endfunction

    always @(posedge cntrl.renderComplete)
    begin
        if(!renderDisable)
        begin
            //save file every time a render completes
            writeLCD(cntrl.lcd, $psprintf("outputs/render_tb_out_%0d_%0d.pgm", testCount, renderCount));
            renderCount++;
        end
    end

	final begin
        $display("Finished %0d tests in tb_render", testCount);
	end


    //=================================
    // Common test helper functions
    //=================================
    function void CreateTestTiles();
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
                                           "00112233",
                                           "00112233",
                                           "00112233",
                                           "00112233",
                                           "00112233",
                                           "00112233"};

        static string outlineTileStr [8]     = { "11111111",
                                                 "10000001",
                                                 "10000001",
                                                 "10000001",
                                                 "10000001",
                                                 "10000001",
                                                 "10000001",
                                                 "11111111"};

        static string circleTileStr [8]      = { "00022000",
                                                 "00211200",
                                                 "02111120",
                                                 "21111112",
                                                 "21111112",
                                                 "02111120",
                                                 "00211200",
                                                 "00022000"};

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
        //Tile 5 = outline
        DUT.tiles.Data[5] = genTile(outlineTileStr);
        //Tile 6 = circle
        DUT.tiles.Data[6] = genTile(circleTileStr);

    endfunction

    //=================================
    // Output background test image 
    //=================================
    task output_bgpattern();
        DUT.lcdControl.Fields.LCDEnable = 1;
        DUT.lcdControl.Fields.TileDataSelect = 1;

        for(int i = 0; i < BG_WIDTH; i++)
        begin
            for(int j = 0; j < BG_HEIGHT; j++)
            begin
                ChangeBGMap(j, i, j % 6);
            end
        end
        @(posedge cntrl.renderComplete);
    endtask 

    //=================================
    // Output scrolling animation
    //=================================
    task output_bgscroll();
        DUT.lcdControl.Fields.LCDEnable = 1;
        DUT.lcdControl.Fields.TileDataSelect = 1;

        for(int i = 0; i < BG_WIDTH; i++)
        begin
            for(int j = 0; j < BG_HEIGHT; j++)
            begin
                ChangeBGMap(j, i, j % 2);
            end

        end
        for(int i = 0; i < 8; i++)
        begin
            @(posedge cntrl.renderComplete);
            DUT.lcdPosition.Data.ScrollX++;
            DUT.lcdPosition.Data.ScrollY++;
        end
    endtask

    task output_spritemove();
        DUT.lcdControl.Fields.LCDEnable = 1;
        DUT.lcdControl.Fields.TileDataSelect = 1;
        DUT.lcdControl.Fields.SpriteEnable = 1;

        //set background (since reset apparently isn't working)
        for(int i = 0; i < BG_WIDTH; i++)
        begin
            for(int j = 0; j < BG_HEIGHT; j++)
            begin
                //DUT.vramBackground1.BackgroundMap[i][j] = 0;
            end

        end


        //create sprite
        DUT.oam_table.Attributes[0].Fields.Tile = 6;
        DUT.oam_table.Attributes[0].Fields.XPosition = 16;
        DUT.oam_table.Attributes[0].Fields.YPosition = 16;

        //move diagonally for 16 frames
        for(int i = 0; i < 16; i++)
        begin
            @(posedge cntrl.renderComplete);
            DUT.oam_table.Attributes[0].Fields.XPosition++;
            DUT.oam_table.Attributes[0].Fields.YPosition += 2;
        end

    endtask
    
    //=================================
	 //Tests vblank functionality
    //=================================
	 task vblank_test();
	     DUT.lcdControl.raw = 8'h80;
		  @(posedge cntrl.renderComplete)
		  begin
		     if(DUT.lcdStatus.Fields.Mode != RENDER_VBLANK)
			     $display("Device does not VBlank at end of render");
			  else
			     $display("Device successfully VBlanks at end of render");
						
		  end
    endtask

    task do_tests();
        $display("do tests");
       TestSetup();
        output_bgpattern();
       TestTeardown();

       TestSetup();
        output_bgscroll();
       TestTeardown();
        
       TestSetup();
        output_spritemove();
       TestTeardown();

		 TestSetup();
		 vblank_test();
		 TestTeardown();
        $finish;

    endtask 

    initial
    begin
        do_tests();
    end

endmodule
