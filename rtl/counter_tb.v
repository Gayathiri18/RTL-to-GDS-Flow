`timescale 1ns/1ps

module counter_tb;
    // Inputs
    reg clk;
    reg rst;

    // Output
    wire [3:0] q;

    // Instantiate DUT (Device Under Test)
    counter uut (
        .clk(clk),
        .rst(rst),
        .q(q)
    );
    // Clock generation (10ns period → 100 MHz)
    always #5 clk = ~clk;

    // Stimulus
    initial begin
        // Initialize
        clk = 0;
        rst = 1;
        // Apply reset
        #10;
        rst = 0;

        // Let counter run
        #100;

        // Apply reset again (check reset behavior)
        rst = 1;
        #10;
        rst = 0;

        // Run again
        #50;

        // Finish simulation
        $finish;
    end

    // Monitor values
    initial begin
        $monitor("Time = %0t | rst = %b | q = %b", $time, rst, q);
    end

endmodule

