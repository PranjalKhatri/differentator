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
    reg signed [15:0] u, y;  // Wider bit-width to handle intermediate results

    // Registers for pipeline stages
    reg [15:0] t1, t2, t3, t4, t5, t6, t7, t8, t9;

    // Intermediate wires for dynamic input selection
    wire signed [15:0] w1;//output of multiplier 1 
    wire signed [15:0] w2; //output of multiplier 2
    wire signed [15:0] w3;//output of adder/subtractor 1 
    wire signed [15:0] w4; 

    reg signed [7:0]  r1;
    reg signed [7:0]  r2;
    reg signed [7:0]  r3;
    reg signed [7:0]  r4;
    reg signed [7:0]  r5;
    reg signed [7:0]  r6;
    reg add_sub_ctrl;  // Control for add/sub
    wire m1done, m2done, a1done;  // Done signals from functional units
    
    // Register to delay compute_done by one cycle
    reg compute_done_next;
    
    // Instantiate Functional Units
    multiplier #(.IN_WIDTH(8)) m1(.in1(r1), .in2(r2), .out(w1), .done(m1done));
    multiplier #(.IN_WIDTH(8)) m2(.in1(r3), .in2(r4), .out(w2), .done(m2done));
    adder_subtractor #(.WIDTH(16)) a1(.in1(r5), .in2(r6), .add_sub(add_sub_ctrl), .out(w3), .done(a1done));

    // Input Handling (Multiplexed Input Based on s1, s2, s3, s4)
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            x <= 0; dx <= 0; u <= 0; a <= 0; y <= 0;
            t1 <= 0; t2 <= 0; t3 <= 0; t4 <= 0; t5 <= 0; t6 <= 0; t7 <= 0; t8 <= 0; t9 <= 0;
            out <= 0;
            compute_done <= 0;
            compute_done_next <= 0;
            continue_while <= 0;
            $display("Time: %0t | RESET ACTIVATED: Registers cleared", $time);
        end else begin
            // Update compute_done from compute_done_next
            compute_done <= compute_done_next;
            compute_done_next <= 0; // Reset compute_done_next by default
            
            if (load_x) begin
                x <= $signed(in);  // Read x
                $display("Time: %0t | INPUT: X loaded with value %d", $time, in);
            end else if (load_dx) begin
                dx <= $signed(in); // Read dx
                $display("Time: %0t | INPUT: DX loaded with value %d", $time, in);
            end else if (load_a) begin
                a <= $signed(in);  // Read a
                $display("Time: %0t | INPUT: A loaded with value %d", $time, in);
            end else if (load_u) begin
                u <= $signed(in);  // Read u
                $display("Time: %0t | INPUT: U loaded with value %d", $time, in);
            end
        end
    end

    // Multiplexers to switch between different registers at each state
    always @(posedge clk) begin
        continue_while <= 0; // Default reset
        out <= y;
        
        case (state)
            S_COMPUTE_1: begin
                $display("Time: %0t | STATE: COMPUTE_1 (Performing computations)", $time);
                begin
                    r1 = dx;
                    r2 = 2'b11; // 3 in binary
                    t1 = w1; // calc for 3dx
                    $display("Time: %0t | COMPUTATION: 3dx = %d", $time, t1);
                end
                // Block 2 (r3, r4, t2)
                begin
                    r3 = u;
                    r4 = x;
                    t2 = w2; // calc for ux
                    $display("Time: %0t | COMPUTATION: ux = %d", $time, t2);
                end
                begin
                    add_sub_ctrl = 0; // Addition
                    r5 = x;
                    r6 = dx;
                    t3 = w3; // calc for x+dx
                    $display("Time: %0t | COMPUTATION: x+dx = %d", $time, t3);
                end 
                if(m1done && m2done && a1done) begin
                    $display("Time: %0t | COMPUTATION: 3dx: %d, ux: %d,x+dx = %d", $time, t1, t2, t3);
                    compute_done_next = 1'b1;
                end
            end
            
            S_COMPUTE_2: begin
                $display("Time: %0t | STATE: COMPUTE_2 (Performing computations)", $time);
                begin
                    r1 = u;
                    r2 = dx;
                    t4 = w1; // calc for udx
                    $display("Time: %0t | COMPUTATION: udx = %d", $time, t4);
                end
                begin
                    add_sub_ctrl = 1; //subtraction
                    r5 = t2;
                    r6 = y;
                    t5 = w3; // calc for ux-y
                    $display("Time: %0t | COMPUTATION: ux - y = %d", $time, t5);
                end
                if(m1done && a1done)
                    compute_done_next = 1'b1;
            end
            
            S_COMPUTE_3: begin
                $display("Time: %0t | STATE: COMPUTE_3 (Performing computations)", $time);
                begin
                    r1 = t1;//3dx
                    r2 = t5;//ux-y
                    t6 = w1; // calc for 3dx(ux-y)
                    $display("Time: %0t | COMPUTATION: 3dx(ux - y) = %d", $time, t6);
                end
                begin
                    add_sub_ctrl = 0; //addition
                    r5 = y;
                    r6 = t4;
                    t7 = w3; // calc for y+udx
                    $display("Time: %0t | COMPUTATION: y + udx = %d", $time, t7);
                end
                if(m1done && a1done)
                    compute_done_next = 1'b1;
            end
            
            S_COMPUTE_4: begin
                $display("Time: %0t | STATE: COMPUTE_4 (Performing computations)", $time);
                begin
                    add_sub_ctrl = 1; //subtraction
                    r5 = u;
                    r6 = t6;
                    t8 = w3; // calc for u-3dx(ux-y)
                    $display("Time: %0t | COMPUTATION: u - 3dx(ux - y) = %d", $time, t8);
                    x = t3;
                    y = t7;
                    u = t8;
                end
                
                if(x < a) begin
                    if(a1done) begin
                        compute_done_next = 1'b1;
                        continue_while = 1'b1;
                        $display("Time: %0t | LOOP CONDITION: x (%d) < a (%d), continuing...", $time, x, a);
                    end
                end
                else begin
                    compute_done_next = 1'b1;
                    continue_while = 1'b0;
                    $display("Time: %0t | LOOP CONDITION: x (%d) >= a (%d), stopping...", $time, x, a);
                end
            end
            
            S_DONE: begin
                compute_done_next = 1'b1;
                $display("Time: %0t | STATE: DONE", $time);
            end
            
            default: begin
                $display("y is : %d ", y);
            end
        endcase
    end
    
    // Continuously update output
    always @(*) begin
        $display("y is : %d ", y);
        out = y;
    end
endmodule