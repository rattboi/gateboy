module whizgraphics(interface db, 
    input logic drawline,
    output bit renderComplete,
    Lcd lcd);

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

    localparam VRAM_TILES_ADDR = 16'h8000;
    localparam VRAM_TILES_MASK = 16'h1fff;
    Tile[0:255] tiles;

    localparam VRAM_BACKGROUND1_ADDR = 16'h9800;
    localparam VRAM_BACKGROUND1_MASK = 16'h03ff;
    vram_background vramBackground1;

    localparam VRAM_BACKGROUND2_ADDR = 16'h9c00;
    localparam VRAM_BACKGROUND2_MASK = 16'h0fff;
    vram_background vramBackground2;

    localparam OAM_LOC = 16'hfe00;
    localparam OAM_MASK = 16'h00ff;
    SpriteAttributesTable oam_table;


    //internal structures

    

    //helper functions
    function Pixel GetPixel(Tile t, int row, int pixel);
       Pixel p; 
       p = { t.rows[row][pixel], t.rows[row][pixel + (NUM_ROWS * ROW_SIZE) };
       return p;
    endfunction

    function Tile GetTileFromIndex(int tileIndex);
        Tile t;
        t = tiles[tileIndex];
        return t;
    endfunction

    function bit[0:7] GetTileIndexFromScreenPoint(int x, int y);

        int bgX = x + lcdPosition.ScrollX;
        int bgY = y + lcdPosition.ScrollY;
        int tileX = bgX / TILE_SIZE;
        int tileY = bgY / TILE_SIZE;

        //TODO: determine bmap from contrpl register
        return vramBackground1[tileX][tileY];
    endfunction

    function Pixel GetPixelAtScreenPoint(int x, int y);
        int tileIndex = GetTileIndexFromScreenPoint(x, y);
        Tile t = GetTileFromIndex(tileIndex);
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
      if (db.writing() && db.selected(OAM_LOC, OAM_MASK)) begin
         oam_table.Bits[db.addr & OAM_MASK] = db.data;
      end
      else if (db.reading() && db.selected(OAM_LOC, OAM_MASK)) begin
         enable = 1;
         bus_reg = oam_table.Bits[db.addr & OAM_MASK];
//         $display("reading %x from %x", oam_table.Bits[db.addr & OAM_MASK], db.addr);
      end
      else
        enable = 0;
   end

   always_ff @(posedge drawline)
   begin
      int startTileX = lcdPosition.ScrollX / TILE_SIZE;
      int tileY = (lcdPosition.ScrollY + currentLine) / TILE_SIZE;
      int tileOffsetX = lcdPosition.ScrollX % TILE_SIZE;
      int tileOffsetY = (lcdPosition.ScrollY + currentLine) % TILE_SIZE;

      if(DEBUG_OUT) $display("Rendering Line: %d", currentLine);

      for(int i = 0; i < LCD_LINEWIDTH; i++)
      begin
        Lcd[currentLine][i] = GetPixelAtScreenPoint(i, currentLine); 
      end

       //after rendering last line, render is complete, reset current line
       if(currentLine > LCD_LINES)
       begin
           renderComplete = 1;
           currentLine = 0;
       end
       else
           renderComplete = 0;
           currentLine++;
        end

   end
endmodule
