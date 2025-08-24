module datapath (
    input wire clk,
    input wire reset,
    input wire [7:0] data_in,
    input wire pc_inc,
    input wire ir_load,
    input wire acc_load,
    input wire mar_load,
    input wire mdr_load,
    output reg [7:0] instruction,
    output reg [3:0] opcode,
    output reg [3:0] operand,
    output reg [7:0] alu_result,
    output reg zero_flag,
    output reg carry_flag,
    output reg [7:0] data_out,
    output reg [7:0] address
);

    // Registers
    reg [7:0] pc;        // Program Counter
    reg [7:0] acc;       // Accumulator
    reg [7:0] mar;       // Memory Address Register
    reg [7:0] mdr;       // Memory Data Register
    
    // ALU temporary
    reg [8:0] alu_temp;  // 9-bit for carry
    
    // Jump detection logic
    wire jump_enable = (opcode == 4'b1001) ||                   // JMP
                       (opcode == 4'b1010 && zero_flag) ||     // JZ if zero
                       (opcode == 4'b1011 && carry_flag);      // JC if carry
    
    // Instruction register
    always @(posedge clk or posedge reset) begin
        if (reset)
            instruction <= 8'b0;
        else if (ir_load)
            instruction <= data_in;
    end
    
    // Decode instruction
    always @(*) begin
        opcode = instruction[7:4];
        operand = instruction[3:0];
    end
    
    // Program Counter with jump support
    always @(posedge clk or posedge reset) begin
        if (reset)
            pc <= 8'b0;
        else if (jump_enable)
            pc <= {4'b0, operand};  // Jump to address
        else if (pc_inc)
            pc <= pc + 1;           // Normal increment
    end
    
    // Accumulator
    always @(posedge clk or posedge reset) begin
        if (reset)
            acc <= 8'b0;
        else if (acc_load)
            acc <= alu_result;
    end
    
    // MAR
    always @(posedge clk or posedge reset) begin
        if (reset)
            mar <= 8'b0;
        else if (mar_load)
            mar <= {4'b0, operand}; // Use operand as address
    end
    
    // MDR
    always @(posedge clk or posedge reset) begin
        if (reset)
            mdr <= 8'b0;
        else if (mdr_load)
            mdr <= data_in;
        else
            mdr <= acc; // For store operations
    end
    
    // ALU
    always @(*) begin
        alu_temp = 9'b0;
        case (opcode)
            4'b0001: alu_temp = {1'b0, acc} + {1'b0, mdr}; // ADD
            4'b0010: alu_temp = {1'b0, acc} - {1'b0, mdr}; // SUB
            4'b0011: alu_temp = acc & mdr;                 // AND
            4'b0100: alu_temp = mdr;                       // LOAD
            4'b0110: alu_temp = ~acc;                      // NOT
            4'b0111: alu_temp = {acc, 1'b0};               // SHL
            4'b1000: alu_temp = {1'b0, acc[7:1]};          // SHR
            default: alu_temp = {1'b0, acc};
        endcase
        
        alu_result = alu_temp[7:0];
        carry_flag = alu_temp[8];
        zero_flag = (alu_result == 8'b0);
    end
    
    // Outputs
    always @(*) begin
        data_out = mdr;
        address = (mar_load) ? pc : mar;
    end

endmodule