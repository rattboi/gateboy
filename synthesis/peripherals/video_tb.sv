module tb;

import video_types::*;

`define DebugPrint(x) if(DebugPrintEnable) $display("%p", x)
int DebugPrintEnable = 1;

//This test verifies that the bit ordering in data structures is correct
initial begin

    LcdControl  lcdc;
    LcdStatus   lcds;
    LcdPosition lcdp;


    `DebugPrint("LCD Control Register Tests");
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


    `DebugPrint("LCD Status Register Tests");
    lcds.raw = 8'b00000001;
    `DebugPrint(lcds);
    assert(lcds.Fields.Mode[0]);

    lcds.raw = 8'b00000010;
    `DebugPrint(lcds);
    assert(lcds.Fields.Mode[1]);

    lcds.raw = 8'b00000100;
    `DebugPrint(lcds);
    assert(lcds.Fields.Mode[2]);

    lcds.raw = 8'b00001000;
    `DebugPrint(lcds);
    assert(lcds.Fields.Coincidence);

    lcds.raw = 8'b00010000;
    `DebugPrint(lcds);
    assert(lcds.Fields.Mode0Interrupt);

    lcds.raw = 8'b00100000;
    `DebugPrint(lcds);
    assert(lcds.Fields.Mode1Interrupt);

    lcds.raw = 8'b01000000;
    `DebugPrint(lcds);
    assert(lcds.Fields.Mode2Interrupt);

    lcds.raw = 8'b10000000;
    `DebugPrint(lcds);
    assert(lcds.Fields.CoincidenceInterrupt);



    $finish;
end

endmodule
