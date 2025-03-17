module multiplier #(
    parameter IN_WIDTH = 8  // Input width (default: 8-bit)
)(
    input signed [IN_WIDTH-1:0] in1, 
    input signed [IN_WIDTH-1:0] in2,
    output reg signed [2*IN_WIDTH-1:0] out,
    output reg done
);
    always @(*) begin
        done = 1'b0;
        // $display("Time: %0t | MULTIPLIER: Received inputs -> in1 = %d, in2 = %d, done = %b", $time, in1, in2, done);
        out = in1 * in2;
        done = 1'b1;
        // $display("Time: %0t | MULTIPLIER: Computation done -> out = %d, done = %b", $time, out, done);
    end
endmodule

module adder_subtractor #(
    parameter WIDTH = 16 // Default input width
)(
    input  signed [WIDTH-1:0] in1, 
    input  signed [WIDTH-1:0] in2,
    input  wire add_sub, // 0 for addition, 1 for subtraction
    output reg signed [WIDTH:0] out, // Extra bit for carry/borrow
    output reg done
);
    always @(*) begin
        done = 1'b0;
        // $display("Time: %0t | ADDER_SUBTRACTOR: Received inputs -> in1 = %d, in2 = %d, add_sub = %b, done= %b", $time, in1, in2, add_sub,done);
        if (add_sub) begin
            out = in1 - in2; // Corrected subtraction
            // $display("Time: %0t | ADDER_SUBTRACTOR: Performing SUBTRACTION -> out = %d", $time, out);
        end else begin
            out = in1 + in2; // Corrected addition
            // $display("Time: %0t | ADDER_SUBTRACTOR: Performing ADDITION -> out = %d", $time, out);
        end
        done = 1'b1;
        $display("Time: %0t | ADDER_SUBTRACTOR: Computation done -> out = %d, in1 -> %d, in2 -> %d done = %b", $time, out,in1,in2, done);
    end
endmodule
