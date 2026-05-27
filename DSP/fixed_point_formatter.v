`timescale 1ns / 1ps

module fixed_point_q14 (
    input              clk,
    input              resetn,

    input      [15:0]  adc_data,       
    input              adc_valid,

    output reg signed [15:0] q14_data, 
    output reg         q14_valid
);

    always @(posedge clk) begin
        if (!resetn) begin
            q14_data  <= 16'sd0;
            q14_valid <= 1'b0;
        end else begin
            q14_valid <= adc_valid;

            if (adc_valid) begin
                q14_data <= adc_data - 16'd32768;
            end
        end
    end

endmodule