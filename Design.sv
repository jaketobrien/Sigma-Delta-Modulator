// ******************************************************************
// EE314 - Mini-Project - Sigma-Delta Modulator
// Description: Hardware description for a Sigma-Delta Modulator
// Authors: Jake O'Brien, Seán Vincent and Rian Allen
// Date: 28/04/2023
//******************************************************************

// Hardware description module for Sigma_Delta_Modulator
module Sigma_Delta_Modulator (CLOCK,
                              RESET,
                              DATAWORD_IN,
                              DATA_OUT,
                              DELAY_OUT);

// Definition of input and output ports and lengths
input CLOCK;
input RESET;
input [15:0] DATAWORD_IN;
output [16:0] DELAY_OUT;
output DATA_OUT;

// Defition of port types and lengths
wire CLOCK;
wire RESET;
wire [15:0] DATAWORD_IN;
reg [16:0] ADDER1;
reg [16:0] ADDER2;
reg [16:0] DELAY_OUT;
reg DATA_OUT;

// Internal variable
reg [15:0] quantized_output;

// Whenever positive edge of clock or negative edge of reset occurs
always @(posedge CLOCK or negedge RESET) begin
  // When reset is set high, set ports and variables to zero
  if (!RESET) begin		              // if-else statment 1
    	ADDER1 <= 17'd0;
    	ADDER2 <= 17'd0;
      DELAY_OUT <= 17'd0;
      quantized_output <= 16'd0;
      DATA_OUT <= 1'b0;
    end 

    // Otherwise execute the sequnetial logic
    else begin			                // if-else statment 1
      
      // ADDER1 BLOCK
      // First summation block as per the given diagram
      // Sum of the dataword and quantizer output
      begin : ADDER1_BLOCK
        ADDER1 <= DATAWORD_IN - quantized_output;
      end
      
      // ADDER2 BLOCK
      // Second summation block as per the given diagram
      // Sum of the first adder summation and the delay output
      begin : ADDER2_BLOCK
        ADDER2 <= ADDER1 + DELAY_OUT;
      end

      // DELAY BLOCK
      // By letting the delay output equal the second adder block, 
      // it delays it by a clock cycle
      begin : DELAY_BLOCK
        DELAY_OUT <= ADDER2;
      end
        
      // QUANTIZER BLOCK
      // Quantizes the ADDER2 value to +1 or -1 depending on its MSB value
      begin : QUANTIZER_BLOCK
        // Check the value of the 17th bit of ADDER2
        if (ADDER2[16] == 1'b1) begin			// if-else statment 2
          // If the 17th bit is 1, assign the maximum 16-bit value (-1)
          quantized_output <= 16'b1111111111111111;
          end 
          else begin                      // if-else statment 2
            // If the 17th bit is 0, assign the minimum 16-bit value (1)
            quantized_output <= 16'b0000000000000001;
            end
      end

      // OUTPUT BLOCK
      // The data output of the sigma-delta modulator 
      // is the 17th bit of ADDER2
      begin : OUTPUT_BLOCK
      DATA_OUT <= ADDER2[16];
    end
    end
end

endmodule