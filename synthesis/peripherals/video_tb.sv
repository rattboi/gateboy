module tb;

import video_types::*;

`define DebugPrint(x) if(DebugPrintEnable) $display("%p", x)
int DebugPrintEnable = 1;


initial begin

    LcdControl lcdc;

    `DebugPrint("LCD Control Register Tests");
    //LcdControl register structure test
    lcdc.raw = 8'b00000001;
    `DebugPrint(lcdc);
    assert(lcdc.Fields.BackgroundDisplay);

    lcdc.raw = 8'b00000010;
    `DebugPrint(lcdc);
    assert(lcdc.Fields.SpriteEnable);

    lcdc.raw = 8'b00000100;
    `DebugPrint(lcdc);
    assert(lcdc.Fields.SpriteSize);

    lcdc.raw = 8'b00001000;
    `DebugPrint(lcdc);
    assert(lcdc.Fields.TileMapSelect);

    lcdc.raw = 8'b00010000;
    `DebugPrint(lcdc);
    assert(lcdc.Fields.TileDataSelect);

    lcdc.raw = 8'b00100000;
    `DebugPrint(lcdc);
    assert(lcdc.Fields.WindowEnable);

    lcdc.raw = 8'b01000000;
    `DebugPrint(lcdc);
    assert(lcdc.Fields.WindowTileMapSelect);

    lcdc.raw = 8'b10000000;
    `DebugPrint(lcdc);
    assert(lcdc.Fields.LCDEnable);



    $finish;
end

endmodule
