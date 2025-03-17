module multiplier #(
    parameter IN_WIDTH = 8  // Input width (default: 8-bit)
)(
    input wire [IN_WIDTH-1:0] in1, 
    input wire [IN_WIDTH-1:0] in2,
    output reg [IN_WIDTH+IN_WIDTH-1:0] out,
    output reg done
);
    initial begin
        done = 1'b0;
    end

    always @(*) begin
        done = 1'b0;
        $display("Time: %0t | MULTIPLIER: Received inputs -> in1 = %d, in2 = %d, done = %b", $time, in1, in2, done);
        out = in1 * in2;
        done = 1'b1;
        $display("Time: %0t | MULTIPLIER: Computation done -> out = %d, done = %b", $time, out, done);
    end
endmodule

module adder_subtractor #(
    parameter WIDTH = 16 // Default input width
)(
    input wire [WIDTH-1:0] in1, 
    input wire [WIDTH-1:0] in2,
    input wire add_sub, // 0 for addition, 1 for subtraction
    output reg [WIDTH:0] out, // Extra bit for carry/borrow
    output reg done
);
    initial begin
        done = 1'b0;
    end

    always @(*) begin
        done = 1'b0;
        $display("Time: %0t | ADDER_SUBTRACTOR: Received inputs -> in1 = %d, in2 = %d, add_sub = %b, done= %b", $time, in1, in2, add_sub,done);
        if (add_sub)begin
            out = {1'b0, in1} - {1'b0, in2}; // Extend to handle borrow
        $display("Time: %0t | ADDER_SUBTRACTOR: Performing SUBTRACTION -> out = %d", $time, out);
        end
        else begin
            out = {1'b0, in1} + {1'b0, in2}; // Extend to handle carry
        $display("Time: %0t | ADDER_SUBTRACTOR: Performing ADDITION -> out = %d", $time, out);
        end
        done = 1'b1;
        $display("Time: %0t | ADDER_SUBTRACTOR: Computation done -> out = %d, done = %b", $time, out, done);
    end
endmodule

module comparator #(parameter WIDTH = 8) // Parameterized bit-width for flexibility
(
    input wire [WIDTH-1:0] in1, 
    input wire [WIDTH-1:0] in2,
    output reg result,  // Output is 1 if in1 < in2, else 0
    output reg done
);
 initial begin
        done = 1'b0;
    end
    always @(*) begin
        done = 1'b0;
        if (in1 < in2)
            result = 1;
        else
            result = 0;
        done = 1'b1;
    end
endmodule




