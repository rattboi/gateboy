module whizgraphics(interface db,
                    Control.DUT cntrl);


    parameter DEBUG_OUT = 0;
    `define DebugPrint(x) if(DEBUG_OUT) $display("%p", x);


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


    //internal structures

    

    //helper functions
    function Pixel GetPixel(Tile t, int row, int pixel);
       automatic Pixel p; 
       p = { t.rows[row][pixel], t.rows[row][pixel + ROW_SIZE] };
       return p;
    endfunction

    function Tile GetTileFromIndex(int tileIndex);
        automatic Tile t;
        t = tiles.Data[tileIndex];
        return t;
    endfunction

    function bit[0:7] GetTileIndexFromScreenPoint(int x, int y);

        automatic int bgX = x + lcdPosition.Data.ScrollX;
        automatic int bgY = y + lcdPosition.Data.ScrollY;
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
        automatic Tile t = GetTileFromIndex(tileIndex);
        return getPixelColor(PALETTE_BACKGROUND, GetPixel(t, (y + lcdPosition.Data.ScrollY) % TILE_SIZE, (x + lcdPosition.Data.ScrollX) % TILE_SIZE));
    endfunction

    function automatic void SetTilePixelValue(int tileIndex, int column, int row, bit[0:1] pixelval);
        {tiles.Data[tileIndex].rows[row][column], tiles.Data[tileIndex].rows[row][column+ ROW_SIZE]} = pixelval;
    endfunction

   
    //rendering state
    bit [0:LCD_LINES_BITS - 1] currentLine;

   bit [db.DATA_SIZE-1:0] bus_reg;
   bit                    enable;
   assign db.data = enable ? bus_reg : 'z;

   function void resetWhizgraphics();
      currentLine = 0;
      cntrl.renderComplete = 0;
      lineDivider = 0;
      lcdStatus.Fields.Mode = RENDER_VBLANK;
      for (int i = 0; i < 3; i++)
        for(int j = 0; j < 4; j++)
        lcdPalletes.Data.indexedPalettes[i].indexedColors[j] = j;
   endfunction
   
   
    initial
    begin
        cntrl.renderComplete = '0;
    end

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

   parameter CLOCKS_PER_LINE = 260;
   parameter VBLANK_LINES = 18;
   
   // RENDER THE CODEZ
   always_ff @(posedge cntrl.drawline)
     begin : renderer
        
      automatic int startTileX = lcdPosition.Data.ScrollX / TILE_SIZE;
      automatic int tileY = (lcdPosition.Data.ScrollY + currentLine) / TILE_SIZE;
      automatic int tileOffsetX = lcdPosition.Data.ScrollX % TILE_SIZE;
      automatic int tileOffsetY = (lcdPosition.Data.ScrollY + currentLine) % TILE_SIZE;
     
   
      if (cntrl.reset) begin
         resetWhizgraphics();
         disable renderer;
      end

      lineDivider++;
      if(lineDivider < CLOCKS_PER_LINE) disable renderer;
      lineDivider = 0;
   
      if(DEBUG_OUT) $display("Rendering Line: %d", currentLine);
        if (currentLine < LCD_LINES) begin
           for(int i = 0; i < LCD_LINEWIDTH; i++)
             begin
                cntrl.lcd[currentLine][i] = GetBackgroundPixelAtScreenPoint(i, currentLine); 
             end
        end
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
