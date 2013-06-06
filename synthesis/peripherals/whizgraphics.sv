module whizgraphics(interface db,
                    Control.DUT cntrl);


    parameter DEBUG_OUT = 0;
    `define DebugPrint(x) if(DEBUG_OUT) $display("%s", x);


    import video_types::*;
    
    LcdControl lcdControl;

	 //Instance of LCD status register
	 // unused in the design
    LcdStatus lcdStatus;

    int lineDivider;

     union packed {
        bit [0:LCD_POS_SIZE-1] [0:7] Bits;
        LcdPosition Data;
     } lcdPosition;

    union packed {
        bit [0:LCD_WIN_SIZE-1] [0:7] Bits;
        LcdWindowPosition Data;
     } lcdWindowPosition;

   
 
    union packed {
      LcdPalletes Data;
      bit [0:LCD_PALLETE_SIZE-1] [0:7] Bits;
      } lcdPalletes;

 
    union packed {
        bit [0:VRAM_TILES_SIZE-1] [0:7] Bits;
       Tile [0:NUM_TILES-1] Data; 
    } tiles;

    vram_background vramBackground1;

    vram_background vramBackground2;

    SpriteAttributesTable oam_table;

    //rendering state
    bit [0:LCD_LINES_BITS - 1] currentLine;

   bit [db.DATA_SIZE-1:0] bus_reg;
   bit                    enable;
   assign db.data = enable ? bus_reg : 'z;


    //helper functions
    function Pixel GetPixel(Tile t, int row, int pixel);
       automatic Pixel p; 
       assert(row < NUM_ROWS && pixel < ROW_SIZE) else $display("R: 0x%h, P: 0x%h", row, pixel);
       p = { t.rows[row][pixel], t.rows[row][pixel + ROW_SIZE] };
       return p;
    endfunction

    function Tile GetBackgroundTileFromIndex(int tileIndex);
       automatic Tile t;
       automatic byte signedIndex = tileIndex;
       automatic int index;
       if (lcdControl.Fields.TileDataSelect) begin
          assert(tileIndex >= 0 && tileIndex <= MAX_UNSIGNED_TILE);
          index = tileIndex;
       end
       else begin
          assert(signedIndex >= MIN_SIGNED_TILE && signedIndex <= MAX_SIGNED_TILE);
          index = SIGNED_TILE_OFFSET + signedIndex;
       end
        return tiles.Data[index];
    endfunction // GetTileFromIndex

   function Tile GetSpriteTileFromIndex(int tileIndex);
        automatic Tile t;
        t = tiles.Data[tileIndex];
        return t;
    endfunction

    function bit[0:7] GetTileIndexFromScreenPoint(int x, int y);

        automatic int bgX = (x + lcdPosition.Data.ScrollX) % (BG_WIDTH*TILE_SIZE);
        automatic int bgY = (y + lcdPosition.Data.ScrollY) % (BG_HEIGHT*TILE_SIZE);
        automatic int tileX = bgX / TILE_SIZE;
        automatic int tileY = bgY / TILE_SIZE;

        if(!lcdControl.Fields.TileMapSelect)
            return vramBackground1.BackgroundMap[tileX][tileY];
        else
            return vramBackground2.BackgroundMap[tileX][tileY];
    endfunction

   function Pixel getPixelColor(PaletteType p, Color c);
      getPixelColor = lcdPalletes.Data.indexedPalettes[p].indexedColors[c];
   endfunction
   
    function Pixel GetBackgroundPixelAtScreenPoint(int x, int y);
        automatic int tileIndex = GetTileIndexFromScreenPoint(x, y);
        automatic Tile t = GetBackgroundTileFromIndex(tileIndex);
        automatic int xPixel, yPixel;

        xPixel = (x + lcdPosition.Data.ScrollX) % TILE_SIZE;
        yPixel = (y + lcdPosition.Data.ScrollY) % TILE_SIZE;
        return getPixelColor(PALETTE_BACKGROUND, GetPixel(t, yPixel, xPixel));
    endfunction

    function automatic void SetTilePixelValue(int tileIndex, int column, int row, bit[0:1] pixelval);
        {tiles.Data[tileIndex].rows[row][column], tiles.Data[tileIndex].rows[row][column+ ROW_SIZE]} = pixelval;
    endfunction

    localparam MAX_SPRITES_PER_LINE = 8;
    //Render current line
	 function automatic void RenderLine(bit [0:LCD_LINES_BITS - 1] currentLine);
        int spritesRendered = 0;
        SpriteAttributes currentSprite;
        int tileIndex = 0;
        Tile t;

        //render  background
        for(int i = 0; i < LCD_LINEWIDTH; i++)
        begin
            cntrl.lcd[currentLine][i] = GetBackgroundPixelAtScreenPoint(i, currentLine); 
        end

        //render sprites
        for(int i = 0; i < NUM_SPRITES; i++)
        begin
            //limit number of sprites drawn per line
            if(spritesRendered >= MAX_SPRITES_PER_LINE)
                break;

           // if sprites are not enabled, we need to turn them off
           if (!lcdControl.Fields.SpriteEnable)
             break;
           
            currentSprite = oam_table.Attributes[i];
            //reject sprites that are not on the current line
            if(currentSprite.Fields.YPosition > currentLine + lcdPosition.Data.ScrollY
                || currentSprite.Fields.YPosition + TILE_SIZE <= currentLine + lcdPosition.Data.ScrollY)
                continue;

            //reject sprites that are left or right of the current lcd drawing region
            if(currentSprite.Fields.XPosition > LCD_LINEWIDTH + lcdPosition.Data.ScrollX
                || currentSprite.Fields.XPosition + TILE_SIZE < lcdPosition.Data.ScrollX)
                continue;

            //get the tile from the sprite attributes
            tileIndex = currentSprite.Fields.Tile;
            t = GetSpriteTileFromIndex(tileIndex);

            `DebugPrint($psprintf("Renderling Sprite %0d (Tile %0d) on line %0d", i, tileIndex, currentLine));
            `DebugPrint($psprintf("Sprite line: %b", t.rows[currentLine + lcdPosition.Data.ScrollY - currentSprite.Fields.YPosition]));

            //for each pixel (of width) in the sprite...
            for(int j = 0; j < TILE_SIZE; j++)
              begin
                 int xpix, ypix;
                 Color tmpcolor;
                 xpix = currentSprite.Fields.Flags.Fields.XFlip ? (TILE_SIZE-j-1) : j;
                 ypix = (currentLine + lcdPosition.Data.ScrollY) - currentSprite.Fields.YPosition;
                 ypix = currentSprite.Fields.Flags.Fields.YFlip ? (TILE_SIZE-ypix-1) : ypix;
                //set the lcd pixel value
               tmpcolor =  GetPixel(t, ypix, xpix);
               if (tmpcolor != 0)
                 cntrl.lcd[currentLine][j + (currentSprite.Fields.XPosition - lcdPosition.Data.ScrollX)] = 
                            getPixelColor(PALETTE_BACKGROUND, tmpcolor);

            end
            spritesRendered++;
        end

	 endfunction
   

   function void resetWhizgraphics();
      lcdControl = 0;
      currentLine = 0;
      cntrl.renderComplete = 0;
      lineDivider = 0;
      lcdStatus = 0;
      lcdStatus.Fields.Mode = RENDER_VBLANK;
      lcdPosition = 0;
      lcdWindowPosition = 0;
      tiles = 0;
      vramBackground1 = 0;
      vramBackground2 = 0;
      oam_table = 0;

      
      //TODO: andy, comment this
      for (int i = 0; i < 3; i++)
        for(int j = 0; j < 4; j++)
        lcdPalletes.Data.indexedPalettes[i].indexedColors[j] = j;
   endfunction
   
   
   // functions as address decoder. 
   always_ff @(posedge db.clk) begin
      if(db.reading()) begin
         enable = 1;
         priority case (1'b1)
           db.selected(OAM_LOC, OAM_SIZE):
             bus_reg = oam_table.Bits[db.addr - OAM_LOC];
           db.selected(VRAM_BACKGROUND1_ADDR, VRAM_BACKGROUND1_SIZE):
             bus_reg = vramBackground1.Bits[db.addr - VRAM_BACKGROUND1_ADDR];
           db.selected(VRAM_BACKGROUND2_ADDR, VRAM_BACKGROUND2_SIZE):
             bus_reg = vramBackground2.Bits[db.addr - VRAM_BACKGROUND2_ADDR];
           db.selected(LCD_PALLETE_ADDR, LCD_PALLETE_SIZE): 
             bus_reg = lcdPalletes.Bits[db.addr - LCD_PALLETE_ADDR];
           db.selected(LCD_POS_ADDR, LCD_POS_SIZE):
             bus_reg = lcdPosition.Bits[db.addr - LCD_POS_ADDR];
           db.selected(LCD_WIN_ADDR, LCD_WIN_SIZE):
             bus_reg = lcdWindowPosition.Bits[db.addr - LCD_WIN_ADDR];
           db.selected(VRAM_TILES_ADDR, VRAM_TILES_SIZE):
             bus_reg = tiles.Bits[db.addr - VRAM_TILES_ADDR];
           db.selected(LCD_STAT_ADDR, LCD_STAT_SIZE):
             bus_reg = lcdStatus;
           db.selected(LCDC_ADDR, LCDC_SIZE):
             bus_reg = lcdControl;
           1:
             enable = 0;
         endcase         
      end else if (db.writing()) begin 
         enable = 0;
         priority case (1'b1)
           db.selected(OAM_LOC, OAM_SIZE): begin
             oam_table.Bits[db.addr - OAM_LOC] = db.data;
              end
           db.selected(VRAM_BACKGROUND1_ADDR, VRAM_BACKGROUND1_SIZE): 
             vramBackground1.Bits[db.addr - VRAM_BACKGROUND1_ADDR] = db.data;
           db.selected(VRAM_BACKGROUND2_ADDR, VRAM_BACKGROUND2_SIZE): 
             vramBackground2.Bits[db.addr - VRAM_BACKGROUND2_ADDR] = db.data;
           db.selected(LCD_PALLETE_ADDR, LCD_PALLETE_SIZE):
             lcdPalletes.Bits[db.addr - LCD_PALLETE_ADDR] = db.data;
           db.selected(LCD_POS_ADDR, LCD_POS_SIZE): 
             lcdPosition.Bits[db.addr - LCD_POS_ADDR] = db.data;
           db.selected(LCD_WIN_ADDR, LCD_WIN_SIZE): 
             lcdWindowPosition.Bits[db.addr - LCD_WIN_ADDR] = db.data;
           db.selected(VRAM_TILES_ADDR, VRAM_TILES_SIZE):
             tiles.Bits[db.addr - VRAM_TILES_ADDR] = db.data;
           db.selected(LCDC_ADDR, LCDC_SIZE):
             lcdControl = db.data;
           1:
             ;
         endcase
      end
   end

   localparam CLOCKS_PER_LINE = 260;
   localparam VBLANK_LINES = 18;
   
   // RENDER THE CODEZ
   always_ff @(posedge cntrl.drawline)
     begin : renderer
         //TODO: you can do breaks
        
      if (cntrl.reset) begin
         resetWhizgraphics();
         disable renderer;
      end

        //render all black if LCD disabled
        if(!lcdControl.Fields.LCDEnable)
        begin
           `DebugPrint("LCD Disabled");
           cntrl.lcd =  '0;
           currentLine = 0;
        end

        
      lineDivider++;
        //TODO: comment this 
      if(lineDivider < CLOCKS_PER_LINE) disable renderer;
      lineDivider = 0;
   
		//Function call to render background and sprites at this line
		RenderLine(currentLine);

       //after rendering last line, render is complete, reset current line
        if (currentLine < LCD_LINES) begin
           lcdStatus.Fields.Mode = RENDER_BOTH;
           cntrl.renderComplete = 0;
           currentLine++;
        end 
        else if(currentLine < LCD_LINES + VBLANK_LINES)
          begin
             cntrl.renderComplete = 1;
             lcdStatus.Fields.Mode = RENDER_VBLANK;
             currentLine++;
          end
       else
       begin
          cntrl.renderComplete = 1;
          lcdStatus.Fields.Mode = RENDER_VBLANK;
          currentLine = 0;
        end
   end
endmodule
