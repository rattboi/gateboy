module whizgraphics(interface db, 
    input logic drawline,
    output bit renderComplete,
    video_types::Lcd lcd);

    parameter DEBUG_OUT = 1;
    `define DebugPrint(x) if(DEBUG_OUT) $display("%p", x);


   import video_types::*;

    localparam LCDC_ADDR = 16'hff40;
    LcdControl lcdControl;

    localparam STAT_ADDR = 16'hff41;
    LcdStatus lcdStatus;

    localparam LCD_POS_BASE_ADDR = 16'hff42;
    LcdPosition lcdPosition;

    localparam LCD_PALLET_BASE_ADDR = 16'hff47;
    LcdPalletes lcdPalletes;

    localparam NUM_TILES = 384;
    localparam VRAM_TILES_ADDR = 16'h8000;
    localparam VRAM_TILES_MASK = 16'h1fff;
    localparam VRAM_TILES_SIZE = ROW_SIZE*NUM_ROWS*PIXEL_BITS*NUM_TILES / 8;
    union packed {
        bit [0:VRAM_TILES_SIZE-1] [0:7] Bits;
       Tile [0:NUM_TILES-1] Data; 
    } tiles;

    localparam VRAM_BACKGROUND1_ADDR = 16'h9800;
    localparam VRAM_BACKGROUND1_MASK = 16'h03ff;
    localparam VRAM_BACKGROUND1_SIZE = 32*32;
    vram_background vramBackground1;

    localparam VRAM_BACKGROUND2_ADDR = 16'h9c00;
    localparam VRAM_BACKGROUND2_MASK = 16'h0fff;
    localparam VRAM_BACKGROUND2_SIZE = 32*32;
    vram_background vramBackground2;

    localparam OAM_LOC = 16'hfe00;
    localparam OAM_MASK = 16'h00ff;
    localparam OAM_SIZE = SPRITE_SIZE*NUM_SPRITES;
    SpriteAttributesTable oam_table;


    //internal structures

    

    //helper functions
    function Pixel GetPixel(Tile t, int row, int pixel);
       automatic Pixel p; 
       p = { t.rows[row][pixel], t.rows[row][pixel + (NUM_ROWS * ROW_SIZE)] };
       return p;
    endfunction

    function Tile GetTileFromIndex(int tileIndex);
        automatic Tile t;
        t = tiles.Data[tileIndex];
        return t;
    endfunction

    function bit[0:7] GetTileIndexFromScreenPoint(int x, int y);

        automatic int bgX = x + lcdPosition.ScrollX;
        automatic int bgY = y + lcdPosition.ScrollY;
        automatic int tileX = bgX / TILE_SIZE;
        automatic int tileY = bgY / TILE_SIZE;

        //TODO: determine bmap from contrpl register
        return vramBackground1.BackgroundMap[tileX][tileY];
    endfunction

    function Pixel GetPixelAtScreenPoint(int x, int y);
        automatic int tileIndex = GetTileIndexFromScreenPoint(x, y);
        automatic Tile t = GetTileFromIndex(tileIndex);
        return GetPixel(t, y, x % TILE_SIZE);
    endfunction

    //rendering state
    bit [0:LCD_LINES_BITS - 1] currentLine;

   bit [db.DATA_SIZE-1:0] bus_reg;
   bit                    enable;
   assign db.data = enable ? bus_reg : 'z;

    initial
    begin
        renderComplete = '0;
    end

   always_ff @(posedge db.clk) begin
      if(db.reading()) begin
         enable = 1;
         priority case (1'b1)
           db.selected(OAM_LOC, OAM_SIZE):
             bus_reg = oam_table.Bits[db.addr & OAM_MASK];
           db.selected(VRAM_BACKGROUND1_ADDR, VRAM_BACKGROUND1_SIZE):
             bus_reg = vramBackground1.Bits[db.addr & VRAM_BACKGROUND1_MASK];
           db.selected(VRAM_TILES_ADDR, VRAM_TILES_SIZE):
             bus_reg = tiles.Bits[db.addr & VRAM_TILES_MASK];
           1:
             enable = 0;
         endcase         
      end else if (db.writing()) begin 
         enable = 0;
         priority case (1'b1)
           db.selected(OAM_LOC, OAM_SIZE): begin
             oam_table.Bits[db.addr & OAM_MASK] = db.data;
              end
           db.selected(VRAM_BACKGROUND1_ADDR, VRAM_BACKGROUND1_SIZE): 
             vramBackground1.Bits[db.addr & VRAM_BACKGROUND1_MASK] = db.data;
           db.selected(VRAM_TILES_ADDR, VRAM_TILES_SIZE):
             tiles.Bits[db.addr & VRAM_TILES_MASK] = db.data;
           1:
             ;
         endcase
      end
   end

   always_ff @(posedge drawline)
   begin
      automatic int startTileX = lcdPosition.ScrollX / TILE_SIZE;
      automatic int tileY = (lcdPosition.ScrollY + currentLine) / TILE_SIZE;
      automatic int tileOffsetX = lcdPosition.ScrollX % TILE_SIZE;
      automatic int tileOffsetY = (lcdPosition.ScrollY + currentLine) % TILE_SIZE;

      if(DEBUG_OUT) $display("Rendering Line: %d", currentLine);

      for(int i = 0; i < LCD_LINEWIDTH; i++)
      begin
        lcd[currentLine][i] = GetPixelAtScreenPoint(i, currentLine); 
      end

       //after rendering last line, render is complete, reset current line
       if(currentLine > LCD_LINES)
       begin
           renderComplete = 1;
           currentLine = 0;
       end
       else
       begin
           renderComplete = 0;
           currentLine++;
        end
   end
endmodule
