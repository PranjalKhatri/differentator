module multiplier #(
    parameter IN_WIDTH = 8  // Input width (default: 8-bit)
)(
    input signed [IN_WIDTH-1:0] in1, 
    input signed [IN_WIDTH-1:0] in2,
    output signed [IN_WIDTH+IN_WIDTH-1:0] out,
    output reg done
);
    assign out = in1 * in2;
endmodule

module adder_subtractor #(
    parameter WIDTH = 16  // Input width (default: 16-bit)
)(
    input signed [WIDTH-1:0] in1, 
    input signed [WIDTH-1:0] in2,
    input mode, // 0 for addition, 1 for subtraction
    output signed [WIDTH:0] out, // One extra bit for overflow
    output reg done
);

    // Combinational logic for addition/subtraction
    assign out = mode ? (in1 - in2) : (in1 + in2);

    always @(*) begin
        done = 1'b1; // Done signal asserts immediately
    end

endmodule
