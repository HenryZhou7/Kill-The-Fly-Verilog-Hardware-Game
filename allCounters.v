/*
* The basic counter for counting plotting and un-plotting
* clock is the CLOCK_50
* reset is the signal that triggered the counter to start
* counter counts all the way until 15
*/
module basiccounter(clock, start, counter);
	input clock;
	input start;
	output reg [3:0]counter;
	
	always @ (posedge clock)
	begin
		if (start == 1)
			counter <= counter + 1'b1;
		else
			counter <= 4'b0000;
	end
endmodule

/*
* The basic counter for counting plotting and un-plotting
* clock is the CLOCK_50
* reset is the signal that triggered the counter to start
* counter counts all the way till 2500 in decimal
*/
module delayCNT(clock, start, delaycount);
	input clock;
	input start;
	output reg [25:0]delaycount;
	
	always @ (posedge clock)
	begin
		if (start == 1)
			delaycount <= delaycount + 1'b1;
		else
			delaycount <= 26'b0;
	end
endmodule



