// *********************************************************
// EE314 - Mini Project
// Description: Testbench for a Sigma-Delta Modulator
// Authors: Jake O'Brien, Seán Vincent and Rian Allen
// Date: 28/04/2023
// **********************************************************

// Testbench module for a Sigma-Delta Modulator
module SigmaDelta_Modulator_TB();

    // Declaring variables as reg and wire with length and types
    reg clock;
    reg reset_n;
    reg signed [15:0] dataword;
    reg signed [15:0] data_in [1999:0];
    reg signed data_outarray [1999:0];
    integer i;
    integer file;
    wire [16:0] delay_out;
    wire data_out;

    // Instantiating the Sigma_Delta_Modulator module
    Sigma_Delta_Modulator DUT (
        .CLOCK(clock),
        .RESET(reset_n),
        .DATAWORD_IN(dataword),
        .DATA_OUT(data_out),
        .DELAY_OUT (delay_out));

initial
begin

// Allows the view of the waveform
$dumpfile("dump.vcd");
$dumpvars;

  // Start sim with i and clock set to zero
  i = 0;
  clock = 0;

  // Function to read in data file
  $readmemb("data_task_a.dat", data_in);

  // Set reset_n low for 5 ticks, high for 1000 ticks
  // Low for 100 ticks and then high for 18885 ticks to include all 2000 datawords
  reset_n = 0;
  #5;
  reset_n = 1;
  #1000;
  reset_n = 0; 
  #100;
  reset_n = 1;
  #18885;

    // variable initialised as a function to open a new file and
    // opens it for writing
    file = $fopen("data_output.dat", "w");

    // For 2000 loops
    for (i = 0; i<2000; i=i+1) begin
      // Wait for the next rising edge of clock signal
      @(posedge clock);
      
      // Sample the data_out signal and store it in an array
      data_outarray[i] <= data_out;
      
      // Write the sampled value to a file using binary format
      $fwrite(file,"%b\n", data_out);
    end

    // Function to close the file 'file'
    $fclose(file); 

  // Finish simulation
  $finish;
end

// Every 5 ticks, toggle the clock
always #5
begin
  clock <= ~clock;
end

// Always block triggered by the signal 'i'
always @(i)
begin
  // if 'i' equals 2000, terminate the simulation
  if (i==2000) $finish;
end

// Always block triggered at posedge clock
always @(posedge clock)
begin
    // Updates the value of dataword with the next value from data_in array
    dataword = data_in[i];
    // Increment 'i'
    i = i + 1;
end

// Always block executes whenever data_in or data_out changes
always @(posedge clock or negedge reset_n)
// Display function used to print immediate values
$display("Clock = %d Reset = %d Data Word = %b Previous DW = %b Data Out = %b", 
clock, reset_n, dataword, delay_out, data_out);

endmodule