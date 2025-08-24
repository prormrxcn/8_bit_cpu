module clock_divider #(
    parameter DIVISOR = 100000000  // Default: 100MHz to 1Hz
)(
    input wire clk_in,
    output reg clk_out
);

    reg [31:0] counter = 0;
    
    always @(posedge clk_in) begin
        if (counter >= DIVISOR - 1) begin
            counter <= 0;
            clk_out <= ~clk_out;
        end else begin
            counter <= counter + 1;
        end
    end

endmodule