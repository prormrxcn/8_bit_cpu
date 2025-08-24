module control_unit (
    input wire clk,
    input wire reset,
    input wire [3:0] opcode,
    input wire zero_flag,
    input wire carry_flag,
    output reg pc_inc,
    output reg ir_load,
    output reg acc_load,
    output reg mar_load,
    output reg mdr_load,
    output reg mem_write
);

    // State definitions - using parameters instead of enum
    localparam [2:0] 
        FETCH     = 3'b000,
        DECODE    = 3'b001,
        EXECUTE   = 3'b010,
        MEM_READ  = 3'b011,
        MEM_WRITE = 3'b100;
    
    reg [2:0] current_state, next_state;
    
    // State register
    always @(posedge clk or posedge reset) begin
        if (reset)
            current_state <= FETCH;
        else
            current_state <= next_state;
    end
    
    // Next state logic
    always @(*) begin
        next_state = current_state; // Default: stay in current state
        
        case (current_state)
            FETCH: next_state = DECODE;
            
            DECODE: next_state = EXECUTE;
            
            EXECUTE: begin
                case (opcode)
                    4'b0001, 4'b0010, 4'b0011: next_state = FETCH; // ALU ops
                    4'b0100: next_state = MEM_READ;  // LOAD
                    4'b0101: next_state = MEM_WRITE; // STORE
                    4'b1001: next_state = FETCH;     // JMP
                    4'b1010: next_state = FETCH;     // JZ
                    4'b1011: next_state = FETCH;     // JC
                    default: next_state = FETCH;
                endcase
            end
            
            MEM_READ: next_state = FETCH;
            MEM_WRITE: next_state = FETCH;
            
            default: next_state = FETCH;
        endcase
    end
    
    // Output logic
    // Output logic
always @(*) begin
    // Default values for ALL outputs
    pc_inc = 1'b0;
    ir_load = 1'b0;
    acc_load = 1'b0;
    mar_load = 1'b0;
    mdr_load = 1'b0;
    mem_write = 1'b0;
    
    case (current_state)
        FETCH: begin
            pc_inc = 1'b1;
            ir_load = 1'b1;
        end
        
        DECODE: begin
            mar_load = 1'b1;
        end
        
        EXECUTE: begin
            case (opcode)
                4'b0001: begin  // ADD
                    acc_load = 1'b1;
                    pc_inc = 1'b1;
                end
                4'b0010: begin  // SUB
                    acc_load = 1'b1;
                    pc_inc = 1'b1;
                end
                4'b0011: begin  // AND
                    acc_load = 1'b1;
                    pc_inc = 1'b1;
                end
                4'b0110: begin  // NOT
                    acc_load = 1'b1;
                    pc_inc = 1'b1;
                end
                4'b0111: begin  // SHL
                    acc_load = 1'b1;
                    pc_inc = 1'b1;
                end
                4'b1000: begin  // SHR
                    acc_load = 1'b1;
                    pc_inc = 1'b1;
                end
                4'b1001: begin  // JMP
                    // pc_inc remains 0 - PC will be loaded from operand
                end
                4'b1010: begin  // JZ
                    pc_inc = ~zero_flag;  // Jump if zero, else increment
                end
                4'b1011: begin  // JC
                    pc_inc = ~carry_flag; // Jump if carry, else increment
                end
                default: begin  // NOP or invalid
                    pc_inc = 1'b1;  // Still move to next instruction
                end
            endcase
        end
        
        MEM_READ: begin
            mdr_load = 1'b1;
            if (opcode == 4'b0100) // LOAD
                acc_load = 1'b1;
        end
        
        MEM_WRITE: begin
            mem_write = 1'b1;
        end
    endcase
end

endmodule