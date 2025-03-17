`timescale 1ns / 1ps

module differentiator_tb;
    reg clk, reset, ready;
    reg s1, s2, s3, s4;
    reg [3:0] in;
    wire [15:0] out;
    wire valid;

    // Instantiate the differentiator module
    differentiator dut (
        .clk(clk),
        .reset(reset),
        .ready(ready),
        .s1(s1),
        .s2(s2),
        .s3(s3),
        .s4(s4),
        .in(in),
        .out(out),
        .valid(valid)
    );

    // Clock generation
    always #5 clk = ~clk;  // Generate a clock with period of 10ns

    initial begin
        // $monitor("Time: %0t | clk: %b | reset: %b | ready: %b | s1: %b | s2: %b | s3: %b | s4: %b | in: %b | out: %d | valid: %b",
        //          $time, clk, reset, ready, s1, s2, s3, s4, in, out, valid);
        // Initialize inputs
        clk = 0;
        reset = 1;
        ready = 0;
        s1 = 0; s2 = 0; s3 = 0; s4 = 0;
        in = 0;

        // Apply reset
        #50reset = 0;
        #50reset = 1;
        #50reset = 0;

        // Start input sequence
        #50in = 4'b0011; s1 = 1;  // Load x->3
        #50s1 = 0;

        #50s2 = 1;
        #50in = 4'b0001;   // Load dx->1
        #50s2 = 0;

        #50 s3 = 1;
        #50in = 4'b0111;  // Load a->7
        #50s3 = 0;

        #50s4 = 1;
        #50in = 4'b1001;   // Load u->9
        #50s4 = 0;

        // Signal ready for computation
        #50ready = 1;
        $display("Computation started");
        // Wait for computation to complete
        wait(valid);
        #10;

        // Print output
        $display("Computation finished. Output: %d", out);

        // End simulation
        #20 $finish;
    end
endmodule
