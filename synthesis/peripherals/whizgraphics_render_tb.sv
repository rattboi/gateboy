module tb_render();
	import video_types::*;

	localparam ACTIVE   = 1'b1;
	localparam INACTIVE = 0'b0;

	bit clk = 0;
   DataBus db(clk);
   logic drawline;
   wire renderComplete;
   Lcd lcd;
	whizgraphics DUT(.*, .db(db.peripheral));

    initial 
    begin
        //write data to tiles
        DUT.tiles[0].rows[0][0] = '1;
        DUT.tiles[0].rows[0][2] = '1;
        DUT.tiles[0].rows[0][4] = '1;
        DUT.tiles[0].rows[0][6] = '1;
        DUT.tiles[0].rows[2][0] = '1;
        DUT.tiles[0].rows[2][2] = '1;
        DUT.tiles[0].rows[2][4] = '1;
        DUT.tiles[0].rows[2][6] = '1;
        DUT.tiles[0].rows[4][0] = '1;
        DUT.tiles[0].rows[4][2] = '1;
        DUT.tiles[0].rows[4][4] = '1;
        DUT.tiles[0].rows[4][6] = '1;
        DUT.tiles[0].rows[6][0] = '1;
        DUT.tiles[0].rows[6][2] = '1;
        DUT.tiles[0].rows[6][4] = '1;
        DUT.tiles[0].rows[6][6] = '1;

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
