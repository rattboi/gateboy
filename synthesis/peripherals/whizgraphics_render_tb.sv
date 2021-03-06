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
       @(posedge clk);
   endtask

    //Set free-running clock
    initial forever #10 clk = ~clk;

    //=================================
    //Testbench infrastructure
    //=================================
    int testCount = 0;
    int renderCount = 0;
    int renderDisable = 0;
    
    //Test setup, call before every test
    task TestSetup();
        //reset graphics system
        resetWhizgraphics(); 
        //create set of test tiles
        CreateTestTiles();
    endtask

    //Test teardown, call after every test
    function void TestTeardown();
        testCount++;
        renderCount = 0;
        renderDisable = 0;
    endfunction

    //Write output and update frame count every time the screen is finished rendering
    always @(posedge cntrl.renderComplete)
    begin
        if(!renderDisable)
        begin
            //save file every time a render completes
            writeLCD(cntrl.lcd, $psprintf("outputs/render_tb_out_%1d_%03d.pgm", testCount, renderCount));
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

        static string glider0 [8]            = { "00000000",
                                                 "00000000",
                                                 "00003000",
                                                 "00303000",
                                                 "00033000",
                                                 "00000000",
                                                 "00000000",
                                                 "00000000"};
       
       static string glider1 [8]             = { "00000000",
                                                 "00000000",
                                                 "00300000",
                                                 "00033000",
                                                 "00330000",
                                                 "00000000",
                                                 "00000000",
                                                 "00000000"};
       
        static string glider2 [8]            = { "00000000",
                                                 "00000000",
                                                 "00003000",
                                                 "00000300",
                                                 "00033300",
                                                 "00000000",
                                                 "00000000",
                                                 "00000000"};

       static string  glider3 [8]            = { "00000000",
                                                 "00000000",
                                                 "00000000",
                                                 "00030300",
                                                 "00003300",
                                                 "00003000",
                                                 "00000000",
                                                 "00000000"};

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
        //Tile 7 = glider0
        DUT.tiles.Data[7] = genTile(glider0);
       //Tile 8 = glider1
        DUT.tiles.Data[8] = genTile(glider1);
       //Tile 9 = glider2
        DUT.tiles.Data[9] = genTile(glider2);
       //Tile 10 = glider3
        DUT.tiles.Data[10] = genTile(glider3);

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
			    DUT.vramBackground1.BackgroundMap[j][i] = j % 6;
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
			    DUT.vramBackground1.BackgroundMap[j][i] = 2;
            end

        end
        for(int i = 0; i < 8; i++)
        begin
            @(posedge cntrl.renderComplete);
            DUT.lcdPosition.Data.ScrollX++;
            DUT.lcdPosition.Data.ScrollY++;
        end
    endtask

   task output_glider();
        DUT.lcdControl.Fields.LCDEnable = 1;
        DUT.lcdControl.Fields.TileDataSelect = 1;
        DUT.lcdControl.Fields.SpriteEnable = 1;
      
      //create sprite
        DUT.oam_table.Attributes[0].Fields.Tile = 7;
        DUT.oam_table.Attributes[0].Fields.XPosition = 16;
        DUT.oam_table.Attributes[0].Fields.YPosition = 16;

      //move diagonally for 16 frames
      for(int i = 0; i < 16; i++)
        begin
           @(posedge cntrl.renderComplete);
           DUT.oam_table.Attributes[0].Fields.Tile++;
           if (DUT.oam_table.Attributes[0].Fields.Tile > 10)
             DUT.oam_table.Attributes[0].Fields.Tile = 7;
           if ((i % 4) == 3) begin
           DUT.oam_table.Attributes[0].Fields.XPosition++;
           DUT.oam_table.Attributes[0].Fields.YPosition++;
           end
        end

      
   endtask

    task output_spritemove();
        DUT.lcdControl.Fields.LCDEnable = 1;
        DUT.lcdControl.Fields.TileDataSelect = 1;
        DUT.lcdControl.Fields.SpriteEnable = 1;

        //create sprite
        DUT.oam_table.Attributes[0].Fields.Tile = 6;
        DUT.oam_table.Attributes[0].Fields.XPosition = 16;
        DUT.oam_table.Attributes[0].Fields.YPosition = 16;

        //move diagonally for 16 frames
        for(int i = 0; i < 16; i++)
        begin
            @(posedge cntrl.renderComplete);
            DUT.oam_table.Attributes[0].Fields.XPosition++;
            DUT.oam_table.Attributes[0].Fields.YPosition++;
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
        output_glider();
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
