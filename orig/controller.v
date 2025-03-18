module controller (
    input wire clk, reset, ready,
    input wire s1, s2, s3, s4,  // Control signals to read inputs
    input wire compute_done,
    input wire continue_while,
    output reg load_x, load_dx, load_u, load_a,
    output reg  valid,
    output reg[3:0] state
);

    // typedef enum reg [2:0] {S_IDLE, S_READ, S_COMPUTE_1, S_COMPUTE_2, S_COMPUTE_3, S_COMPUTE_4, S_DONE} state_t;
    // state_t current_state, next_state;
    reg[3:0] current_state, next_state;
    localparam S_IDLE = 3'b000;
    localparam S_READ = 3'b001;
    localparam S_COMPUTE_1 = 3'b010;
    localparam S_COMPUTE_2 = 3'b011;
    localparam S_COMPUTE_3 = 3'b100;
    localparam S_COMPUTE_4 = 3'b101;
    localparam S_DONE = 3'b110;

    // wire compute_done;  

    always @(posedge clk or posedge reset) begin
        if (reset)begin
        $display("Time: %0t | STATE: IDLE (Reset Activated)", $time);
            current_state <= S_IDLE;
        end
        else
            current_state <= next_state;
    end

    always@(*) begin
        state = current_state;
    end

        // Next state logic
    always @(posedge clk) begin
        next_state = current_state;  // Default: stay in current state
        
        case (current_state)
            S_IDLE: begin
                $display("Time: %0t | STATE: READ (Waiting for inputs...)", $time);
                next_state = S_READ;
            end
            
            S_READ: begin
                //just send the input as it will be always there
                     $display("Time: %0t | STATE: READ (reading started)", $time);
                if (ready)begin
                    next_state = S_COMPUTE_1;
                     $display("Time: %0t | STATE: LOAD (Ready signal received)", $time);
                end
                //next state is set in the input handling block
            end
            
            S_COMPUTE_1: begin
                     $display("Time: %0t | STATE: COMPUTE_1 (Processing..)", $time);
                if (compute_done)begin
                    next_state = S_COMPUTE_2;
                     $display("Time: %0t | STATE: COMPUTE_1 (completed)", $time);
                end
            end
            
            S_COMPUTE_2: begin
                     $display("Time: %0t | STATE: COMPUTE_2 (Processing...)", $time);
                if (compute_done)begin
                    next_state = S_COMPUTE_3;
                     $display("Time: %0t | STATE: COMPUTE_2 finished (completed)", $time);
                end
            end
            
            S_COMPUTE_3: begin
                 $display("Time: %0t | STATE: COMPUTE_3 (Processing...)", $time);
                if (compute_done)begin
                    next_state = S_COMPUTE_4;
                 $display("Time: %0t | STATE: COMPUTE_3 (completed)", $time);
                end
            end
            
            S_COMPUTE_4: begin
                 $display("Time: %0t | STATE: COMPUTE_4 (Processing...)", $time);
                if (continue_while==0)begin
                    next_state = S_DONE;
                 $display("Time: %0t | STATE: COMPUTE_4 (completed)", $time);
                end
                else begin
                    if(continue_while==1 && compute_done==1'b1)
                    next_state = S_COMPUTE_1;
                    else next_state=S_DONE;
                end
            end
            
            S_DONE: begin
                
                    next_state=S_DONE;
         $display("Time: %0t | STATE: DONE (Computation finished)", $time);
                
            end
        endcase
    end

    always @(posedge clk or posedge reset) begin
        if (current_state==S_READ) begin 
            if (reset) begin
                load_x <= 0; load_dx <= 0; load_u <= 0; load_a <= 0;
                valid<=0;
            end else if (s1) begin
                load_x <= 1;  // Read x
                load_dx <= 0; load_u <= 0; load_a <= 0;
            end else if (s2) begin
                load_dx <= 1; // Read dx
                load_x <= 0; load_u <= 0; load_a <= 0;
            end else if (s3) begin
                load_a <= 1;  // Read a
                load_dx <= 0; load_x <= 0; load_u <= 0;
            end else if (s4) begin
                load_u <= 1;  // Read u
                load_dx <= 0; load_x <= 0; load_a <= 0;
            end
                else begin
                  load_x = 0;
                    load_dx = 0;
                    load_u = 0;
                    load_a = 0;
                end
        end

        if (current_state==S_DONE) begin 
            valid = 1;
        end
        else begin
            valid = 0;
        end
    end


endmodule
