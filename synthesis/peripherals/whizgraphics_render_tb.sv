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

    always @(posedge cntrl.renderComplete)
    begin
        //save file every time a render completes
        writeLCD(cntrl.lcd, $psprintf("outputs/render_tb_out_%0d_%0d.pgm", testCount, renderCount));
        renderCount++;
    end

	final begin
        $display("Finished %0d tests in tb_render", testCount);
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
                                           "00112233",
                                           "00112233",
                                           "00112233",
                                           "00112233",
                                           "00112233",
                                           "00112233"};

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
    // Output background test image 
    //=================================
    task output_bgpattern();
        CreateTestTiles();
        DUT.lcdControl.Fields.LCDEnable = 1;
        DUT.lcdControl.Fields.TileDataSelect = 1;

        DUT.vramBackground1.BackgroundMap[0][0] = 1;
        DUT.vramBackground1.BackgroundMap[0][1] = 2;
        DUT.vramBackground1.BackgroundMap[0][2] = 3;
        DUT.vramBackground1.BackgroundMap[0][3] = 4;
        @(posedge cntrl.renderComplete);
    endtask 

    //=================================
    // Output scrolling animation
    //=================================
    task output_bgscroll();
        $display("bgscroll");
        CreateTestTiles();
        DUT.lcdControl.Fields.LCDEnable = 1;
        DUT.lcdControl.Fields.TileDataSelect = 1;

        for(int i = 0; i < BG_WIDTH; i++)
        begin
            for(int j = 0; j < BG_HEIGHT; j++)
            begin
                DUT.vramBackground1.BackgroundMap[i][j] = 2;
            end

        end
        for(int i = 0; i < 8; i++)
        begin
            @(posedge cntrl.renderComplete);
            DUT.lcdPosition.Data.ScrollX++;
            DUT.lcdPosition.Data.ScrollY++;
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

        $finish;

    endtask 

    initial
    begin
        do_tests();
    end


	initial forever #10 clk = ~clk;

endmodule
