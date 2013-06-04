module tb_render();
	import video_types::*;

	localparam ACTIVE   = 1'b1;
	localparam INACTIVE = 0'b0;

	bit clk = 0;
   DataBus db(clk);
   logic drawline;
   wire renderComplete;
   bit  reset = 0;
   Lcd lcd;
	whizgraphics #(.DEBUG_OUT(1)) DUT(.*, .db(db.peripheral));

    initial 
    begin
        //write data to tiles
        for(int x = 0; x < 32; x++)
        begin
            SetTilePixelValue(DUT.tiles.Data[0], x, 0, 2'b00);
            SetTilePixelValue(DUT.tiles.Data[0], x, 1, 2'b01);
            SetTilePixelValue(DUT.tiles.Data[0], x, 2, 2'b10);
            SetTilePixelValue(DUT.tiles.Data[0], x, 3, 2'b11);

            SetTilePixelValue(DUT.tiles.Data[0], x, 4, 2'b00);
            SetTilePixelValue(DUT.tiles.Data[0], x, 5, 2'b01);
            SetTilePixelValue(DUT.tiles.Data[0], x, 6, 2'b10);
            SetTilePixelValue(DUT.tiles.Data[0], x, 7, 2'b11);

            SetTilePixelValue(DUT.tiles.Data[0], x, 8, 2'b00);
            SetTilePixelValue(DUT.tiles.Data[0], x, 9, 2'b01);
            SetTilePixelValue(DUT.tiles.Data[0], x, 10, 2'b10);
            SetTilePixelValue(DUT.tiles.Data[0], x, 11, 2'b11);
        end
    end


	initial forever #10 clk = ~clk;

	assign drawline = clk;

	always @* begin
		if(renderComplete)
        begin
            writeLCD(lcd, "out.pgm");
			$finish;
        end
	end

	final begin
		$display("renderComplete: %b", renderComplete);
		$display("tb_render is done");
	end

endmodule
