module differentiator (
    input wire clk, reset, ready,
    input wire s1, s2, s3, s4,  // Control signals for input selection
    input wire [3:0] in,        // 4-bit input
    output wire [15:0] out,     // Computed result
    output wire valid           // Result valid indicator
);
    wire [2:0] state;
    wire load_x, load_dx, load_u, load_a;
    wire compute_done;
    
    // Instantiate controller
    controller ctrl(
        .clk(clk),
        .reset(reset),
        .ready(ready),
        .s1(s1),
        .s2(s2),
        .s3(s3),
        .s4(s4),
        .compute_done(compute_done),
        .continue_while(continue_while),
        .load_x(load_x),
        .load_dx(load_dx),
        .load_u(load_u),
        .load_a(load_a),
        .valid(valid),
        .state(state)
    );
    
    // Instantiate datapath
    datapath dp (
        .clk(clk),
        .in(in),
        .load_x(load_x),
        .load_dx(load_dx),
        .load_u(load_u),
        .load_a(load_a),
        .reset(reset),
        .state(state),
        .out(out),
        .compute_done(compute_done),
        .continue_while(continue_while)
    );
endmodule