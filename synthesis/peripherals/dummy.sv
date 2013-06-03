// Represents a dummy endpoint to the data bus. Represents a single
// byte of memory aliased across every memory address

module Dummy(interface db);
   bit [db.DATA_SIZE-1:0] tmpdata;
   parameter ADDR = 0;
   assign db.data = (db.reading() && db.selected('0,1)) ? tmpdata : 'z;
   always_latch  if(db.writing() && db.selected('0, 1)) tmpdata = db.data;
endmodule
