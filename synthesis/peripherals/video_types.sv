package video_types;

    typedef union 
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

    typedef union
    {
        bit [7:0] raw;
        struct packed
        {
            bit CoincidenceInterrupt;
            bit Mode2Interrupt;
            bit Mode1Interrupt;
            bit Mode0Interrupt;
            bit Coincidence;
            bit [2:0] Mode;

         } Fields;
     } LcdStatus;

    typedef struct packed
    {
        bit [0:7] ScrollX;
        bit [0:7] ScrollY;
        bit [0:7] LcdY;
        bit [0:7] LcdYCompare;
        bit [0:7] WindowY;
        bit [0:7] WindowX;
    } LcdPosition;

    typedef union packed
    {
        bit [0:7] raw;
        struct packed
        {
            bit [0:1] Color1;
            bit [0:1] Color2;
            bit [0:1] Color3;
            bit [0:1] Color4;
        } Fields;
    } Pallete;

    typedef struct packed
    { 
        Pallete BackgroundPallete;
        Pallete Sprite0Pallete;
        Pallete Sprite1Pallete;
    } LcdPalletes;


    localparam PIXEL_BITS = 2;
    localparam ROW_SIZE = 8;
    localparam NUM_ROWS = 8;
    
    typedef union 
    {
        bit [(ROW_SIZE * NUM_ROWS * PIXEL_BITS) - 1:0] raw;
        bit [(NUM_ROWS - 1):0] [(ROW_SIZE * PIXEL_BITS) - 1:0] rows;
    
    } vram_tiles;

    typedef union packed
    {
        bit [0:7] raw;
        struct packed
        {
            bit BgOamPriority;
            bit VerticalFlip;
            bit HorizontalFlip;
            bit Unused;
            bit TileBankNumber;
            bit [0:2] BackgroundPallete;
        } Fields;
    } BackgroundMapAttrs;

    typedef struct packed
    {
        bit [0:7][0:31][0:31] BackgroundMap;        
        BackgroundMapAttrs Attributes;
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
        byte YPosition;
        byte XPosition;
        byte Tile;
        SpriteAttributeFlags Flags;
      } Fields;
      bit [0:7] [0:SPRITE_SIZE-1] Bits;
    } SpriteAttributes;
    
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


   function void writeLCD(Lcd display, string path);
      automatic int fd = $fopen(path, "w");
      $fwrite(fd, "P2\n");
      $fwrite(fd, "%d %d\n", LCD_LINEWIDTH, LCD_LINES);
      $fwrite(fd, "3\n");
      for(int i = 0; i < LCD_LINES; i++) begin
        for (int j = 0; j < LCD_LINEWIDTH; j++) begin
           $fwrite(fd, "%d ", display[i][j]);
        end
         $fwrite(fd, "\n");
      end
      $fclose(fd);
   endfunction

    function automatic Lcd readLCD(string path);
       int fd = $fopen(path, "r");

       string line;
       string tmpword = "0";
       int    tmploc = 0;
       int    k = 0;
       string space = " ";
       string newline = "\n";
       int    code;
       code = $fgets(line, fd);
       code = $fgets(line, fd); 
       code = $fgets(line, fd);
      for (int i = 0; i < LCD_LINES; i++) begin
         code = $fgets(line, fd);
         k = 0;
         for(int j = 0; j < line.len()-1; j++) begin
            if (line.getc(j) == space.getc(0)|| line.getc(j) == newline.getc(0)) begin
               readLCD[i][k++] = tmpword.atoi();
               tmpword = "0";
               tmploc = 0;
            end else begin
               tmpword.putc(tmploc++, line.getc(j));
            end
         end
      end
    endfunction
endpackage
