
/*
* This file includes the needed code for the fly to fly up when not hitted
* Start is the signal when the fly is not hit during the designated time
* address is the current location fly resides
* clock is CLOCK_50
* [8:0]x, [7:0]y, [2:0]colour, plot is the wire going to be output to VGA
* over is the signal passing to the top FSM indication the completion of the process
*/
module fly_animation_down(start, address, clock, x, y, colour, plot, over);
	input start;
	input [1:0]address;//Detailed address input will be adjusted due to the change for flyin animation
	input clock;
	output [8:0]x;
	output [7:0]y;
	output [2:0]colour;
	output plot;
	output over;
	
	/*
	* Needed wires for communication between control path and data path
	* plotcounter 1 and 2 are for drawing and erasing counting respectively
	* valid is signal checking whether the fly has reached the top
	* [3:0]currentstate is the state generated from control path
	*/
	wire [3:0]plotcounter;
	wire [3:0]plotcounter2;
	wire valid;
	wire [3:0]currentstate;
	
	flyDownControl flyDownDControl(start, clock, plotcounter, plotcounter2, valid, currentstate);
	flyDownData flyDownDData(currentstate, address, clock, x, y, colour, plot, over, valid, plotcounter, plotcounter2);

endmodule

/*
* module for the control path
* 
*/
module flyDownControl(start, clock, plotcounter, plotcounter2, validness, currentstate);
	input start;
	input clock;
	input [3:0]plotcounter;
	input [3:0]plotcounter2;
	input validness;
	output reg [3:0]currentstate;

parameter [3:0] reset = 4'b0000, draw = 4'b0001, hold = 4'b0010, checkvalid = 4'b0011, erase = 4'b0100, update = 4'b0101, terminate = 4'b0110;

	//Dummy Counter
	wire [25:0]dummyCount;
	delayCNT dummydummy(clock, currentstate == hold, dummyCount);

	reg [3:0]nextstate;
	always @ (*)
	begin
		case(currentstate)
			
			reset:
				nextstate = draw;
			
			draw:
				if (plotcounter == 4'd15)
					nextstate = hold;
				else 
					nextstate = draw;
			
			hold:
				if (dummyCount == 26'd190000)
					nextstate = checkvalid;
				else 
					nextstate = hold;
			
			checkvalid:
					//If the fly reaches destination, go to terminate state. Else erase and draw a new one.
					//This state is not necessarily needed
					nextstate = erase;
					
			erase:
				if (plotcounter2 == 4'd15 && validness)
					nextstate = terminate;
				else if (plotcounter2 == 4'd15)
					nextstate = update;
				else
					nextstate = erase;
			
			update://Upon updating, increment y coordinate by one and go back to draw state
				nextstate = draw;
				
			terminate:
				nextstate = terminate;
		
		endcase
	end

	//State Flip-flop
	always @ (posedge clock)
	begin
		if (start == 1)
			currentstate = nextstate;
		else
			currentstate = reset;
	
	end
	
endmodule

/*
* Data path for the fly to fly to the top of the screen
* currentstate is passed in from the control path
* address is passed in through the top FSM
* clock is CLOCK_50
* x, y, colour, plot is the information to the VGA
* over is to signal the completion of the animation
* valid is to signal the control path to terminate
* counter1 and counter2 are for plotting the fly(which is a square)
*/
module flyDownData(currentstate, address, clock, x, y, colour, plot, over, valid, counter, counter2);
	input [3:0]currentstate;
	input [1:0]address;
	input clock;
	output reg [8:0]x;
	output reg [7:0]y;
	output reg plot;
	output reg over;
	output reg valid;
	output reg [2:0]colour;
	
parameter [3:0] reset = 4'b0000, draw = 4'b0001, hold = 4'b0010, checkvalid = 4'b0011, erase = 4'b0100, update = 4'b0101, terminate = 4'b0110;
	
	//Under which may have human error
	reg a, b, c, d, e, f, g;
	always @ (*)
	begin
		case(currentstate)
			
			reset:
			begin
				a = 1;
				b = 0;
				c = 0;
				d = 0;
				e = 0;
				f = 0;
				g = 0;
			end
			
			draw:
			begin
				a = 0;
				b = 1;
				c = 0;
				d = 0;
				e = 0;
				f = 0;
				g = 0;
			end
			
			hold:
			begin
				a = 0;
				b = 0;
				c = 1;
				d = 0;
				e = 0;
				f = 0;
				g = 0;
			end
			
			checkvalid:
			begin
				a = 0;
				b = 0;
				c = 0;
				d = 1;
				e = 0;
				f = 0;
				g = 0;
			end
			
			erase:
			begin
				a = 0;
				b = 0;
				c = 0;
				d = 0;
				e = 1;
				f = 0;
				g = 0;
			end
			
			update:
			begin
				a = 0;
				b = 0;
				c = 0;
				d = 0;
				e = 0;
				f = 1;
				g = 0;
			end
			
			terminate:
			begin
				a = 0;
				b = 0;
				c = 0;
				d = 0;
				e = 0;
				f = 0;
				g = 1;
			end
		endcase
	end//End of the always block
	
	output [3:0]counter;
	output [3:0]counter2;
	basiccounter myBasicCounter1(clock, b, counter);
	basiccounter myBasicCounter2(clock, e, counter2);
	
	wire [8:0]xInput;
	wire [7:0]yInput;
	flyDown flyFlyUp(clock, a, f, address, xInput, yInput);
	
	wire [2:0]colour1;
	wire [2:0]colour2;
	wire [2:0]colour3;
	wire [2:0]colour4;
	backgroundFlyUp1 ((y  * 10'd4 + counter2[1:0] + 10'd1), clock, 3'b000, 1'b0, colour1[2:0]);
	backgroundFlyUp2 ((y  * 10'd4 + counter2[1:0] + 10'd1), clock, 3'b000, 1'b0, colour2[2:0]);
	backgroundFlyUp3 ((y  * 10'd4 + counter2[1:0] + 10'd1), clock, 3'b000, 1'b0, colour3[2:0]);
	backgroundFlyUp4 ((y  * 10'd4 + counter2[1:0] + 10'd1), clock, 3'b000, 1'b0, colour4[2:0]);
	//The terminate state is for the x coordinate is when x-coordinate reaches 0
	always @ (*)
	begin
		//Draw
		if (b == 1)
		begin
			x = xInput + counter[1:0];
			y = yInput + counter[3:2];
			colour[2:0] = 3'b000;
		end
		
		//Check validness
		if (d == 1)
		begin
			if (yInput == 8'd236)
				valid = 1;
			else
				valid = 0;
		end
		
		//Erase
		if (e == 1)
		begin
			x = xInput + counter2[1:0];
			y = yInput + counter2[3:2];
			case(address)
			//Fill in the designated addresses
			//Use non-blocking assignment
				2'b00:
				begin
					colour = colour1;
				end
				2'b01:
				begin
					colour = colour2;
				end
				2'b10:
				begin
					colour = colour3;
				end
				2'b11:
				begin
					colour = colour4;
				end
			endcase//Whatever needs to be filled
		end
		
		if(g==1)
			over = 1;
		else
			over = 0;
			
		if(b | e == 1)
			plot = 1;
		else
			plot = 0;
		
	end
	
	
endmodule

/*
* Module for resetting the initial value of the flying out process
* Firstly, the initialization process. Need to set the coordinate to designated address
* Secondly update the y by +1, keep x the same.
* clock is the CLOCK_50
* a: the state you need to initialize
* f: the state you need to update the value
* address: the coordinate you start depends on the address you choose.
*/
module flyDown(clock, a, f, address, xOutput, yOutput);
	input clock;
	input a;
	input f;
	input [1:0]address;
	output reg [8:0]xOutput;
	output reg [7:0]yOutput;
	parameter [8:0] a_address = 9'b000110010, b_address = 9'b001111101, c_address = 9'd200, d_address = 9'd275;
	always @ (posedge clock)
	begin
		if (a)//Reset state
		begin
			case(address)
			//Fill in the designated addresses
			//Use non-blocking assignment
				2'b00:
				begin
					xOutput <= a_address;
					yOutput <= 8'd165;
				end
				2'b01:
				begin
					xOutput <= b_address;
					yOutput <= 8'd165;
				end
				2'b10:
				begin
					xOutput <= c_address;
					yOutput <= 8'd165;
				end
				2'b11:
				begin
					xOutput <= d_address;
					yOutput <= 8'd165;
				end
			endcase
		end
		
		if (f)//Update state
		begin
			xOutput <= xOutput;
			yOutput <= yOutput + 1'b1;
		end
	end
	
endmodule


/*
* This module will still be needing counters
* I will not be creating the same thing over again
* The module will be inherited from other module
* I am not sure if I can do that
*/













