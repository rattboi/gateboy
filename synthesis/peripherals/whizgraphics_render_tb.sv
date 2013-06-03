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

	initial forever #10 clk = ~clk;

	assign drawline = clk;

	always @* begin
		if(renderComplete)
			$finish;
	end

	final begin
		$display("renderComplete: %b", renderComplete);
		$display("tb_render is done");
	end

endmodule
