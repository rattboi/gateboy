package video_types;

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

    typedef union packed
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
    } LcdPosition;

   typedef struct packed {
      bit [0:7]   WindowY;
      bit [0:7]   WindowX;
   } LcdWindowPosition;
   
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
    localparam TILE_SIZE = 8;
    localparam ROW_SIZE = 8;
    localparam NUM_ROWS = 8;
    
    typedef union packed
    {
        bit [0:(ROW_SIZE * NUM_ROWS * PIXEL_BITS) - 1] raw;
        bit [0:(ROW_SIZE * PIXEL_BITS) - 1] [0:(NUM_ROWS - 1)] rows;
    } Tile;

    function void SetTilePixelValue(Tile t, int x, int y, bit[0:1] pixvalue);
        t.rows[y][x] = pixvalue; 
        t.rows[y][x + ROW_SIZE] = pixvalue; 
    endfunction

    typedef union packed
    {
        bit [0:(32*32)-1][0:7] Bits;
        bit [0:31][0:31][0:7] BackgroundMap;        
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

   // read an LCD: much more complicated
    function automatic Lcd readLCD(string path);
       // open the file
       int fd = $fopen(path, "r");

       // string that stores the current line  of the pixmap
       string line;
       // tmpword represents the ascii characters of the current pixel
       string tmpword = "0";
       // the count of the number of bytes in the current tmpword
       int    tmploc = 0;
       // counter
       int    k = 0;
       // ascii string of a space
       string space = " ";
       // ascii string of a newline
       string newline = "\n";
       // return code (bad programmers don't use it)
       int    code;
       // throw away image header: we assume it is a dgm sized picture
       code = $fgets(line, fd);
       code = $fgets(line, fd); 
       code = $fgets(line, fd);
       // for every line of the pgm
      for (int i = 0; i < LCD_LINES; i++) begin
         // get the line
         code = $fgets(line, fd);
         k = 0;
         // for every character on the line:
         for(int j = 0; j < line.len(); j++) begin
            // if it is a space or a newline
            if (line.getc(j) == space.getc(0)|| line.getc(j) == newline.getc(0)) begin
               // check and see if we have a color code in tmpword. If
               // we do, write it to the LCD
               if (tmploc > 0) 
                 readLCD[i][k++] = tmpword.atoi();
               // reset the temporary word fields
               tmpword = "0";
               tmploc = 0;
               // else, assume the character is a pixel code, and add it to the tmp word register
            end else begin
               tmpword.putc(tmploc++, line.getc(j));
            end
         end
      end
    endfunction
endpackage
