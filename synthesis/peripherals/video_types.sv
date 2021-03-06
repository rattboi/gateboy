package video_types;


    localparam LCDC_ADDR = 16'hff40;
    localparam LCDC_SIZE = 1;
   
    typedef union packed
    {
        bit [7:0] raw;
        struct packed
        {
            bit LCDEnable;
            bit WindowTileMapSelect;
            bit WindowEnable;
            bit TileDataSelect;
            bit TileMapSelect;
            bit SpriteSize;
            bit SpriteEnable;
            bit BackgroundDisplay;

        } Fields;
    } LcdControl;


    localparam LCD_STAT_ADDR = 16'hff41;
    localparam LCD_STAT_SIZE = 1;

    typedef enum bit [0:1] {RENDER_HBLANK, RENDER_VBLANK, RENDER_OAM, RENDER_BOTH} RenderMode;
    typedef union packed
    {
        bit [7:0] raw;
        struct packed
        {
            bit     Unused1;
            bit CoincidenceInterrupt;
            bit Mode2Interrupt;
            bit Mode1Interrupt;
            bit Mode0Interrupt;
            bit Coincidence;
            RenderMode Mode;

         } Fields;
     } LcdStatus;


    localparam LCD_POS_ADDR = 16'hff42; 
    localparam LCD_POS_SIZE = 4;

    typedef union packed
	 {
      bit [0:LCD_POS_SIZE-1] [0:7] Bits;
	 	struct packed
    	{
        bit [0:7] ScrollY;
        bit [0:7] ScrollX;
        bit [0:7] LcdY;
        bit [0:7] LcdYCompare;
    	} Data;
	} LcdPosition;

   localparam LCD_WIN_ADDR = 16'hff4a; 
   localparam LCD_WIN_SIZE = 2;
   
   typedef union packed
	{
        bit [0:LCD_WIN_SIZE-1] [0:7] Bits;
		struct packed {
      	bit [0:7]   WindowY;
      	bit [0:7]   WindowX;
   	} Data;
	} LcdWindowPosition;


    localparam LCD_PALLETE_ADDR = 16'hff47;
    localparam LCD_PALLETE_SIZE = 3;
   
    typedef bit [0:1] Color;
    typedef union packed
    {
       bit [0:7] raw;
       Color [0:3] indexedColors;
        struct packed
        {
            Color Color1;
            Color Color2;
            Color Color3;
            Color Color4;
        } Fields;
    } Pallete;

   typedef enum {PALETTE_BACKGROUND, PALETTE_SPRITE0, PALETTE_SPRITE1} PaletteType;

   
    typedef union packed
    {
       Pallete [0:2] indexedPalettes;
       struct packed {
       Pallete BackgroundPallete;
       Pallete Sprite0Pallete;
       Pallete Sprite1Pallete; } namedPalettes;
    } LcdPalletes;

   function Color LookupColor(PaletteType palette_num, Color srcColor, LcdPalletes palettes);
      LookupColor = palettes.indexedPalettes[palette_num][srcColor];
   endfunction 

    localparam PIXEL_BITS = 2;
    localparam TILE_SIZE = 8;
    localparam ROW_SIZE = 8;
    localparam NUM_ROWS = 8;
    localparam NUM_TILES = 384;
    localparam MAX_UNSIGNED_TILE = 255;
    localparam MAX_SIGNED_TILE = 127;
    localparam MIN_SIGNED_TILE = -128;
    localparam SIGNED_TILE_OFFSET = 256;
    localparam VRAM_TILES_ADDR = 16'h8000;
    localparam VRAM_TILES_SIZE = ROW_SIZE*NUM_ROWS*PIXEL_BITS*NUM_TILES / 8;

    typedef union packed
    {
        bit [0:(ROW_SIZE * NUM_ROWS * PIXEL_BITS) - 1] raw;
        bit [0:(NUM_ROWS - 1)] [0:(ROW_SIZE * PIXEL_BITS) - 1] rows;
    } Tile;

	 localparam BG_WIDTH  = 32;
	 localparam BG_HEIGHT = 32;
   localparam VRAM_BACKGROUND1_ADDR = 16'h9800;
   localparam VRAM_BACKGROUND1_SIZE = 32*32;
   localparam VRAM_BACKGROUND2_ADDR = 16'h9c00;
   localparam VRAM_BACKGROUND2_SIZE = 32*32;

    typedef union packed
    {
        bit [0:(BG_WIDTH * BG_HEIGHT)-1][0:(TILE_SIZE-1)] Bits;
        bit [0:(BG_WIDTH-1)][0:(BG_HEIGHT-1)][0:(TILE_SIZE-1)] BackgroundMap;
    } vram_background;

    typedef union packed
    {
        bit [0:7] raw;
        struct packed
        {
            bit [0:2] CgbPalleteNumber;
            bit VramBank;
            bit PalleteNumber;
            bit XFlip;
            bit YFlip;
            bit BgOamPriority;
        } Fields;
    } SpriteAttributeFlags;


   localparam SPRITE_SIZE = 4;
   localparam NUM_SPRITES = 40;
   typedef union packed {
      struct packed {
        byte unsigned YPosition;
        byte unsigned XPosition;
        byte unsigned Tile;
        SpriteAttributeFlags Flags;
      } Fields;
      bit [0:7] [0:SPRITE_SIZE-1] Bits;
    } SpriteAttributes;

    localparam OAM_LOC = 16'hfe00;
    localparam OAM_SIZE = SPRITE_SIZE*NUM_SPRITES;
   
    typedef union packed
    {
       SpriteAttributes [0:NUM_SPRITES-1] Attributes;
       bit  [0:SPRITE_SIZE*NUM_SPRITES-1] [0:7] Bits;
    } SpriteAttributesTable;

    //LCD Output Types
    localparam LCD_LINEWIDTH = 160;
    localparam LCD_LINES = 144;
    localparam LCD_LINES_BITS = 8; //ceil(log_2(LCD_LINES)

    typedef bit[0:1] Pixel;
    typedef Pixel[0:LCD_LINEWIDTH - 1] Line;
    typedef Line[0:LCD_LINES - 1] Lcd;

   // builds a pgm imaage
   function void writeLCD(Lcd display, string path);
      // open the file
      automatic int fd = $fopen(path, "w");
      // write the magic word
      $fwrite(fd, "P2\n");
      // write the width and height of the image on a line
      $fwrite(fd, "%d %d\n", LCD_LINEWIDTH, LCD_LINES);
      // specify n-1 gray intensities
      $fwrite(fd, "3\n");

      // For every line of the LCD
      for(int i = 0; i < LCD_LINES; i++) begin
         // For every pixel on the line
        for (int j = 0; j < LCD_LINEWIDTH; j++) begin
           // write out the color that is being displayed
           $fwrite(fd, "%d ", display[i][j]);
        end
         // at the end of the line, write a newline
         $fwrite(fd, "\n");
      end
      // close the stream
      $fclose(fd);
   endfunction

      function Tile genTile(string pixmap [NUM_ROWS]);
         string zero;
         int    code0, tmpchar;
         bit [0:ROW_SIZE-1] lowbit,hibit;
         zero = "0";
         code0 = zero.getc(0);
         for (int r = 0; r < NUM_ROWS; r++) begin
            lowbit = 0;
            hibit = 0;
            for (int p = 0; p < ROW_SIZE; p++) begin
               tmpchar = pixmap[r].getc(p);
               tmpchar -= code0;
               assert(tmpchar >= 0 && tmpchar < 4);
               {genTile.rows[r][p], genTile.rows[r][p + ROW_SIZE]} = tmpchar;
            end
         end
      endfunction
endpackage
