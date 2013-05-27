/*
 * Author:      Tyler Tricker
 * Description: Z80 instruction decoder
 */

`include tv80.pkg

module cpu(input clk, irq, interface bus)
Registers registerfile;

// These are the internal processor states
typdef enum bit[2:0] {
    FETCH,
    EXECUTE,
    INTERRUPT, for going into interrupt mode
    HALT
} pstate;

// instruction stage information
bit[2:0] stage

// stage specific data
byte unsigned [4:0] instruction_data;

// processor state
bit ei = 1; // interrupt enable

// main processor loop
always @(posedge clk) begin    
    if(reset) reset_cpu_state() else // syncronous reset
    case(pstate)
    FETCH: begin
        bus.read(registerfile.PC, instuction_data[stage]);
        registerfile.PC++;
        if (instruction_complete(instruction_data))
            pstate = EXECUTE;
            stage = 0;
        else
            stage++;
            pstate = FETCH;
    end
    EXECUTE:
        instruction_execute();
    INTERRUPT: begin
        ei = 0;
        bus.write(registerfile.PC, registerfile.SP++);
        bus.read(); // get interrupt information
        // jump to ISR
        pstate = FETCH;
    end

    HALT:
        if(irq && ei)
            pstate = FETCH;
            stage  = 0;
        else
            pstate = HALT;
    endcase
end

endmodule
