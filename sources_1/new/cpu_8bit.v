`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 08/24/2025 11:41:20 AM
// Design Name: 
// Module Name: cpu_8bit
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module top_basys3 (
    input wire clk,
    input wire btnC,
    input wire btnU, 
    output wire [15:0] led,
    output wire [6:0] seg,
    output wire [3:0] an
);

    wire cpu_clk;
    wire reset;
    wire [7:0] cpu_data_out;
    wire [7:0] cpu_address;
    wire mem_write;
    
    // Internal signals
    wire [7:0] acc_value;
    wire [7:0] pc_value;
    wire [7:0] data_in_to_cpu;
    
    // Memory signals
    reg [7:0] rom_data;
    reg [7:0] ram_data_out;
    
    // Clock divider
    clock_divider #(.DIVISOR(100000000)) clk_div (
        .clk_in(clk),
        .clk_out(cpu_clk)
    );
    
    // Reset logic
    assign reset = btnC;
    
    // Instantiate CPU
    cpu_8bit cpu (
        .clk(cpu_clk),
        .reset(reset),
        .data_in(data_in_to_cpu),
        .data_out(cpu_data_out),
        .address(cpu_address),
        .mem_write(mem_write)
    );
    
    // Assign internal values
    assign acc_value = cpu.dp.acc;
    assign pc_value = cpu.dp.pc;
    
    // Memory parameters
    localparam RAM_BASE = 8'h00;
    localparam RAM_SIZE = 64;    // 64 bytes
    localparam ROM_BASE = 8'h40;
    
    // RAM implementation
    reg [7:0] ram [0:RAM_SIZE-1];
    
    always @(posedge cpu_clk or posedge reset) begin
        if (reset) begin
            ram_data_out <= 8'h00;
            // Optional: Initialize RAM contents here if needed
        end else begin
            if (mem_write && (cpu_address >= RAM_BASE) && (cpu_address < RAM_BASE + RAM_SIZE)) begin
                ram[cpu_address - RAM_BASE] <= cpu_data_out;
            end
            
            if ((cpu_address >= RAM_BASE) && (cpu_address < RAM_BASE + RAM_SIZE)) begin
                ram_data_out <= ram[cpu_address - RAM_BASE];
            end else begin
                ram_data_out <= 8'h00;
            end
        end
    end
    
    // ROM implementation
    always @(*) begin
        if (cpu_address >= ROM_BASE) begin
            case (cpu_address)
                // Program: LOAD 10, ADD 5, STORE result
                8'h40: rom_data = 8'b01000001; // LOAD from address 1
                8'h41: rom_data = 8'h0A;       // Data: 10 (will go to RAM[1])
                8'h42: rom_data = 8'b00010010; // ADD from address 2  
                8'h43: rom_data = 8'h05;       // Data: 5 (will go to RAM[2])
                8'h44: rom_data = 8'b01010011; // STORE to address 3
                8'h45: rom_data = 8'h00;       // Result location (RAM[3])
                
                // Fill rest of ROM with NOPs
                default: rom_data = 8'b00000000; // NOP
            endcase
        end else begin
            rom_data = 8'h00;
        end
    end
    
    // Memory mux - select between RAM and ROM
    assign data_in_to_cpu = (cpu_address < ROM_BASE) ? ram_data_out : rom_data;
    
    // Display configuration:
    // LEDs 0-7: Accumulator value
    // LEDs 8-15: Current address
    assign led[7:0] = acc_value;
    assign led[15:8] = cpu_address;
    
    // 7-segment display shows program counter
    display_7seg display (
        .clk(clk),
        .data(pc_value),
        .seg(seg),
        .an(an)
    );

endmodule

module cpu_8bit (
    input wire clk,
    input wire reset,
    input wire [7:0] data_in,
    output wire [7:0] data_out,
    output wire [7:0] address,
    output wire mem_write
);

    // Internal wires
    wire [7:0] instruction;
    wire [3:0] opcode;
    wire [3:0] operand;
    wire [7:0] alu_result;
    wire zero_flag;
    wire carry_flag;
    
    // Control signals
    wire pc_inc;
    wire ir_load;
    wire acc_load;
    wire mar_load;
    wire mdr_load;
    
    // Instantiate control unit
    control_unit ctrl (
        .clk(clk),
        .reset(reset),
        .opcode(opcode),
        .zero_flag(zero_flag),
        .carry_flag(carry_flag),
        .pc_inc(pc_inc),
        .ir_load(ir_load),
        .acc_load(acc_load),
        .mar_load(mar_load),
        .mdr_load(mdr_load),
        .mem_write(mem_write)
    );
    
    // Instantiate datapath
    datapath dp (
        .clk(clk),
        .reset(reset),
        .data_in(data_in),
        .pc_inc(pc_inc),
        .ir_load(ir_load),
        .acc_load(acc_load),
        .mar_load(mar_load),
        .mdr_load(mdr_load),
        .instruction(instruction),
        .opcode(opcode),
        .operand(operand),
        .alu_result(alu_result),
        .zero_flag(zero_flag),
        .carry_flag(carry_flag),
        .data_out(data_out),
        .address(address)
    );

endmodule

module display_7seg (
    input wire clk,
    input wire [7:0] data,
    output reg [6:0] seg,
    output reg [3:0] an
);

    reg [3:0] digit;
    reg [19:0] refresh_counter;
    wire [1:0] digit_sel;
    
    // Refresh counter for multiplexing
    always @(posedge clk) begin
        refresh_counter <= refresh_counter + 1;
    end
    
    assign digit_sel = refresh_counter[19:18];
    
    // Digit selection
    always @(*) begin
        case (digit_sel)
            2'b00: begin
                an = 4'b1110;
                digit = data[3:0];
            end
            2'b01: begin
                an = 4'b1101;
                digit = data[7:4];
            end
            default: begin
                an = 4'b1111;
                digit = 4'b0000;
            end
        endcase
    end
    
    // 7-segment decoder
    always @(*) begin
        case (digit)
            4'h0: seg = 7'b1000000;
            4'h1: seg = 7'b1111001;
            4'h2: seg = 7'b0100100;
            4'h3: seg = 7'b0110000;
            4'h4: seg = 7'b0011001;
            4'h5: seg = 7'b0010010;
            4'h6: seg = 7'b0000010;
            4'h7: seg = 7'b1111000;
            4'h8: seg = 7'b0000000;
            4'h9: seg = 7'b0010000;
            4'hA: seg = 7'b0001000;
            4'hB: seg = 7'b0000011;
            4'hC: seg = 7'b1000110;
            4'hD: seg = 7'b0100001;
            4'hE: seg = 7'b0000110;
            4'hF: seg = 7'b0001110;
            default : seg = 7'b0000000;
        endcase
    end

endmodule