// this is the main driving program

package gameboy_sim;

    import "DPI-C" function string getenv(input string env_name);


    localparam cartsize = (1<<15);

    /**
    * This task will load a rom into a memory location
    * NOTE: this task will kill the simulation if the
    * file fails to open
    */
    task automatic load_rom(string filename, ref reg [7:0] data [0:cartsize-1]);
        integer file;
        int dontcare;

        file = $fopen(filename, "rb");
        if(!file)
            $fatal("**** couldn't load %s", filename);
            else begin
                dontcare = $fread(data, file, 0, cartsize-1);
                $display("loaded %s", filename);
                $fclose(file);
            end
    endtask

endpackage

program top_program(clock, reset, romdata);
    import gameboy_sim::*;

    string filename;
    event fin;

    input clock;
    output reg reset;
    output reg[7:0] romdata [0:cartsize-1];

    task reset_system;
        @(posedge clock) reset = 1;
        @(posedge clock) reset = 0;
        @(posedge clock);
    endtask

    initial begin
        $display("Loading Testroms");
        filename = getenv("ROMFILE");
        if(filename == "") begin
            $warning("No ROM file defined returning");
            filename = "../tests/01-special.gb";
        end

        load_rom("../tests/01-special.gb", romdata);

        reset_system();
        @(fin) $display("finished");
    end

endprogram
