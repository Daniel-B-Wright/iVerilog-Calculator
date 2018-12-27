// ----------------------------------------------------------------------------------
// constants. don't change these
// file io constants
`define EOF 32'hFFFF_FFFF
`define NULL 1'b0

// keypad values
`define ADD 4'd10
`define SUB 4'd11
`define MUL 4'd12
`define DIV 4'd13
`define EQU 4'd14
`define CLR 4'd15

// http://www.asciitable.com/
`define INT_ASCII_START 8'd48
`define INT_ASCII_END   8'd57
`define ASCII_ENTER     8'd13
`define ASCII_PLUS      8'd43
`define ASCII_MINUS     8'd45
`define ASCII_MULT      8'd42
`define ASCII_DIV       8'd47

// Keyboards don't have a "clear" button.
// For usability, use the value to lowercase 'x' instead
`define ASCII_CLEAR     8'd78


// ----------------------------------------------------------------------------------
// these configuration values are changeable

// When set to 0, take input from the keyboard.
// When set to 1, take input from a file passed to the command line arguments.
`define USE_FILE 1'b0

// file name to read input from. This value is ignored if USE_FILE is unset.
`define FILE_NAME "input.txt"

// ----------------------------------------------------------------------------------
// modules 

/*
Takes a value from the keyboard and enters it into the simulation.
 
    code - the keycode entered.
        o value in range [0..9] -> integer
        o value = 10 -> add
        o value = 11 -> sub
        o value = 12 -> mult
        o value = 13 -> div
        o value = 14 -> eq
        o value = 15 -> clr/rst
    press - a signal that a keypad event occurred
*/
module keypad(code, press) ;
    output [3:0]   code;
    output         press;
    reg    [3:0]   code;
    reg           press;
    reg    [7:0]   inValue;
    reg    [7:0]   fd;

    always @(*) begin
	$display("Hello World");
        // set file descriptor to load from. 
        // if USE_FILE is not set, default to fd = stdin.
        fd = 0;
        if (`USE_FILE) begin
            fd = $fopen(`FILE_NAME);
            if (!fd) 
                $display("Error: could not open file %s", `FILE_NAME);
        end

        // read from file
        inValue = $fgetc(fd);
        while (inValue != `EOF) begin
            inValue = $fgetc(fd);

            if (inValue > `INT_ASCII_START && inValue < `INT_ASCII_END) begin
                // in range 0-9
                inValue = inValue - `INT_ASCII_START;

                code = inValue;
				#10
                press = 1;
				#10
                press = 0;
            end else if (inValue == `ASCII_PLUS) begin
                code = `ADD;
				#10
                press = 1;
				#10
                press = 0;
            end else if (inValue == `ASCII_MINUS) begin
                code = `SUB;
				#10
                press = 1;
				#10
                press = 0;
            end else if (inValue == `ASCII_MULT) begin
                code = `MUL;
				#10
                press = 1;
				#10
                press = 0;
            end else if (inValue == `ASCII_DIV) begin
                code = `DIV;
				#10
                press = 1;
				#10
                press = 0;
            end else if (inValue == `ASCII_ENTER) begin
                code = `EQU;
				#10
                press = 1;
				#10
                press = 0;
            end else if (inValue == `ASCII_CLEAR) begin
                code = `CLR;
				#10
                press = 1;
				#10
                press = 0;
            end else begin
                $display("Illegal character %d. Ignoring input.", inValue);
            end
        end


        if (`USE_FILE) begin
            $fclose(fd);
        end
        $display("reached EOF");
    end

    
    
endmodule


module testbench ;
    wire [3:0] code;
    wire press; 
	reg test ;
    keypad kpd(code, press);

    initial begin
	repeat (31)
	#100
		begin
			$display("%b %b", kpd.code, kpd.press);
		end
    end

endmodule

//fork : wait_or_timeout
//			begin
//				#10ms ;
//				disable wait_or_timeout ;
//			end
//			begin
//				$fgets(test, 'h8000_0000) ;
//				disable wait_or_timeout ;
//			end
//		join