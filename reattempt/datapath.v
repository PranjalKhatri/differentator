module datapath (
    input wire clk,
    input wire [3:0] in,   // 4-bit input read one by one
    input wire load_x, load_dx, load_u, load_a, reset,
    // input wire ready,//idk what this is
    input wire [2:0] state,
    output reg signed [15:0] out,      // Computed output
    output reg compute_done,
    output reg continue_while
);
    localparam S_IDLE = 3'b000;
    localparam S_READ = 3'b001;
    localparam S_COMPUTE_1 = 3'b010;
    localparam S_COMPUTE_2 = 3'b011;
    localparam S_COMPUTE_3 = 3'b100;
    localparam S_COMPUTE_4 = 3'b101;
    localparam S_DONE = 3'b110;

    // Registers to store inputs
    reg signed [3:0] dx, a;  
    reg signed [4:0] x;  
    reg signed [15:0] u, y;

    // Registers for pipeline stages
    reg [15:0] t1, t2, t3, t4, t5, t6, t7, t8, t9;

    // Intermediate wires for dynamic input selection
    wire signed [15:0] w1,w2,w3; //output of m1,m2,a1

    reg signed [15:0] v1; //input1 of multiplier 1
    reg signed [15:0] v2; //input2 of multiplier 1
    reg signed [15:0] v3; //input1 of multiplier 2
    reg signed [15:0] v4; //input2 of multiplier 2
    reg signed [15:0] v5; //input1 of adder/subtractor 1
    reg signed [15:0] v6; //input2 of adder/subtractor 1

    reg add_sub_ctrl;  // Control for add/sub

    // Instantiate Functional Units
    multiplier #(.IN_WIDTH(16)) m1(.in1(v1), .in2(v2), .out(w1));
    multiplier #(.IN_WIDTH(16)) m2(.in1(v3), .in2(v4), .out(w2));
    adder_subtractor #(.WIDTH(16)) a1(.in1(v5), .in2(v6), .mode(add_sub_ctrl), .out(w3));

    // Input Handling (Multiplexed Input Based on s1, s2, s3, s4)
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            x <= 0; dx <= 0; u <= 0; a <= 0; y <= 0;
            t1<=0;t2<=0;t3<=0;t4<=0;t5<=0;t6<=0;t7<=0;t8<=0;t9<=0;
            out<=0;
            compute_done <= 0;
            continue_while <= 0;
            // $display("Time: %0t | RESET ACTIVATED: Registers cleared", $time);
        end else if (load_x && state==S_READ) begin
            x <= $signed(in);  // Read x
            // $display("Time: %0t | INPUT: X loaded with value %d", $time, in);
        end else if (load_dx && state==S_READ) begin
            dx <= $signed(in); // Read dx
             // $display("Time: %0t | INPUT: DX loaded with value %d", $time, in);
        end else if (load_a && state==S_READ) begin
            a <= $signed(in);  // Read a
             // $display("Time: %0t | INPUT: A loaded with value %d", $time, in);
        end else if (load_u && state==S_READ) begin
            u <= $signed(in);  // Read u
             // $display("Time: %0t | INPUT: U loaded with value %d", $time, in);
        end
    end

    // Multiplexers to switch between different registers at each state
    always @(posedge clk) begin
        // $display("Time: %0t | STATE: %b | x = %d | u= %d | y = %d | dx = %d ", $time, state, x, u, y, dx);
        compute_done <= 0; // Default reset
        continue_while <= 0; // Default reset
        out <= y;
        case (state)
            S_COMPUTE_1: begin
                //  // $display("Time: %0t | STATE: COMPUTE_1 (Performing computations)", $time);
                v1 <= dx;
                v2 <= 16'sd3; // 3dx
                v3 <= u;
                v4 <= x; // ux
                v5 <= x;
                v6 <= dx; // x + dx
                add_sub_ctrl <= 1'b0; // Addition

                // Capture results
                t1 <= w1; // 3dx
                t2 <= w2; // ux
                t3 <= w3; // x + dx
                compute_done <= 1'b1;
            end
            S_COMPUTE_2: begin
                 // $display("Time: %0t | STATE: COMPUTE_2 (Performing computations)", $time);
                v1 <= u;
                v2 <= dx; 
                v5 <= t2; // ux
                v6 <= y;
                add_sub_ctrl <= 1'b1; // Subtraction

                t4 <= w1; // udx
                t5 <= w3; // ux - y
                compute_done <= 1'b1;
            end
            S_COMPUTE_3: begin
                v1 <= t1; // 3dx
                v2 <= t5; // ux - y
                v5 <= y;
                v6 <= t4; // udx
                add_sub_ctrl <= 1'b0; // Addition

                t6 <= w1; // 3dx(ux - y)
                t7 <= w3; // y + udx
                compute_done <= 1'b1;
            end
            S_COMPUTE_4: begin
                // $display("Time: %0t | STATE: COMPUTE_4 (Performing computations)", $time);
                v5 <= u;
                v6 <= t6; // 3dx(ux - y)
                add_sub_ctrl <= 1'b1; // Subtraction

                // t8 <= w3; // u - 3dx(ux - y)
                x <= t3;  // x+dx
                y <= t7;  // y+udx
                u <= w3;  // u - 3dx(ux - y)
                
                if (x < a) begin
                    continue_while <= 1'b1;
                end else begin
                    compute_done <= 1'b1;
                    continue_while <= 1'b0;
                end
            end
            S_DONE: begin
                // out <= y;
                compute_done <= 1'b1;
            end
        endcase

        // Print debug information
        $display("Time: %0t | STATE: %b | x = %d | u = %d | y = %d ", $time, state, x, u, y);
    end
endmodule
