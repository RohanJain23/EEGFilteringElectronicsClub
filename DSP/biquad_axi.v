`timescale 1ns/1ps

module biquad_axi_stream #(
    parameter inout_width = 16,
    parameter inout_decimal_width = 15,

    parameter coefficient_width = 16,
    parameter coefficient_decimal_width = 15,

    parameter internal_width = 32,
    parameter internal_decimal_width = 15,

    // Q1.15 coefficients
    parameter signed [coefficient_width-1:0] b0 = 16'sd6722,
    parameter signed [coefficient_width-1:0] b1 = -16'sd12787,
    parameter signed [coefficient_width-1:0] b2 = 16'sd6722,
    parameter signed [coefficient_width-1:0] a1 = -16'sd1287,
    parameter signed [coefficient_width-1:0] a2 = 16'sd503
)(
    input aclk,
    input resetn,

    // AXI Stream input
    input  signed [inout_width-1:0] s_axis_tdata,
    input  s_axis_tlast,
    input  s_axis_tvalid,
    output s_axis_tready,

    // AXI Stream output
    output reg signed [inout_width-1:0] m_axis_tdata,
    output reg m_axis_tlast,
    output reg m_axis_tvalid,
    input  m_axis_tready
);

    assign s_axis_tready = 1'b1;

    // Sign-extend input
    wire signed [internal_width-1:0] input_int;
    assign input_int = {{(internal_width-inout_width){s_axis_tdata[inout_width-1]}}, s_axis_tdata};

    // Delay registers
    reg signed [internal_width-1:0] input_pipe1, input_pipe2;
    reg signed [internal_width-1:0] output_pipe1, output_pipe2;

    // Multipliers (wide)
    wire signed [2*internal_width-1:0] input_b0, input_b1, input_b2;
    wire signed [2*internal_width-1:0] output_a1, output_a2;

    assign input_b0 = input_int   * b0;
    assign input_b1 = input_pipe1 * b1;
    assign input_b2 = input_pipe2 * b2;

    assign output_a1 = output_pipe1 * a1;
    assign output_a2 = output_pipe2 * a2;

    // Accumulator
    wire signed [2*internal_width-1:0] acc;

    assign acc = input_b0 + input_b1 + input_b2
               - output_a1 - output_a2;

    // Scale back to Q1.15
    wire signed [internal_width-1:0] output_int;
    assign output_int = acc >>> internal_decimal_width; // >>> 15

    // Saturation (VERY important)
    wire signed [internal_width-1:0] output_sat;
    assign output_sat =
        (output_int > 32767)  ? 32767 :
        (output_int < -32768) ? -32768 :
        output_int;

    // Pipeline updates
    always @(posedge aclk) begin
        if (!resetn) begin
            input_pipe1  <= 0;
            input_pipe2  <= 0;
            output_pipe1 <= 0;
            output_pipe2 <= 0;
        end
        else if (s_axis_tvalid) begin
            input_pipe1  <= input_int;
            input_pipe2  <= input_pipe1;
            output_pipe1 <= output_sat;
            output_pipe2 <= output_pipe1;
        end
    end

    // Output stage
    always @(posedge aclk) begin
        if (!resetn) begin
            m_axis_tdata  <= 0;
            m_axis_tvalid <= 0;
            m_axis_tlast  <= 0;
        end
        else if (s_axis_tvalid) begin
            m_axis_tdata  <= output_sat[15:0];
            m_axis_tvalid <= 1'b1;
            m_axis_tlast  <= s_axis_tlast;
        end
        else begin
            m_axis_tvalid <= 1'b0;
        end
    end

endmodule