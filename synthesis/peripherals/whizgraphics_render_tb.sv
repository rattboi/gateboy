module tb_render();
	localparam ACTIVE   = 1'b1;
	localparam INACTIVE = 0'b0;
	import video_types::*;
	bit clk = 0;
   DataBus db(clk);
   logic drawline;
   wire renderComplete;
   Lcd lcd;
	whizgraphics DUT(.*, .db(db.peripheral));

	initial forever #10 clk = ~clk;
	initial begin
		#10;
		while (~renderComplete)begin
			$display("renderComplete: %b", renderComplete);
			drawline = ACTIVE;
			#10;
			drawline = INACTIVE;
		end

		$finish;
	end

	final begin
		$display("tb_render is done");
	end

endmodule
