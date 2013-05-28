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

    struct packed
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

    typedef struct packed
    {
        byte YPosition;
        byte XPosition;
        byte Tile;
        SpriteAttributeFlags Flags;
    } SpriteAttributes;
    
    typedef struct packed
    {
        SpriteAttributes [0:39] Attributes;
    } SpriteAttributesTable;

endpackage
