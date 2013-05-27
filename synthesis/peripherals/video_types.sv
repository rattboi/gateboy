package video_types;


    typedef packed struct
    {
        bit BackgroundDisplay;
        bit SpriteEnable;
        bit SpriteSize;
        bit TileMapSelect;
        bit TileDataSelect;
        bit WindowEnable;
        bit WindowTileMapSelect;
        bit LCDEnable;

    } LcdControl

    typedef packed struct
    {
        bit [0:2] Mode;
        bit Concidence;
        bit Mode0Interrupt;
        bit Mode1Interrupt;
        bit Mode2Interrupt;
        bit CoincidenceInterrupt;

     } LcdStatus;

    typedef packed struct
    {
        bit [0:7] ScrollX;
        bit [0:7] ScrollY;
        bit [0:7] LcdY;
        bit [0:7] LcdYCompare;
        bit [0:7] WindowY;
        bit [0:7] WindowX;
    } LcdPosition;

    typedef packed struct
    {
        bit [0:1] Color1;
        bit [0:1] Color2;
        bit [0:1] Color3;
        bit [0:1] Color4;
    } Pallete;

    typedef packed struct
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
        bit [(NUM_ROWS - 1:0] [(ROW_SIZE * PIXEL_BITS) - 1:0] rows;
    
    } vram_tiles;

    typedef struct 
    {
        bit BgOamPriority;
        bit VerticalFlip;
        bit HorizontalFlip;
        bit Unused;
        bit TileBankNumber;
        bit [0:2] BackgroundPallete;
    } BackgroundMapAttrs;

    typedef struct 
    {
        byte [0:32][0:32] BackgroundMap;        
        BackgroundMapAttrs Attributes;
    } vram_background;

    typedef struct
    {
        bit [0:2] CgbPalleteNumber;
        bit VramBank;
        bit PalleteNumber
        bit XFlip;
        bit YFlip;
        bit BgOamPriority;
    } SpriteAttributeFlags;

    typedef struct
    {
        byte YPosition;
        byte XPosition;
        byte Tile;
        SpriteAttributeFlags Flags;
    } SpriteAttributes;
    
    typedef struct
    {
        SpriteAttributes [0:39] Attributes;
    } SpriteAttributesTable;


endpackage
