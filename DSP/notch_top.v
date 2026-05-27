`timescale 1ns / 1ps

module notch (
    input aclk,
    input resetn,

    input  signed [15:0] s_axis_tdata,
    input  s_axis_tvalid,

    output signed [15:0] m_axis_tdata,
    output m_axis_tvalid
);

biquad_axi_stream #(
    // Q1.15 normalized coefficients (scaled down by 2)
    .b0(16'sd32111),
    .b1(-16'sd21636),   
    .b2(16'sd32111),
    .a1(-16'sd21636),   
    .a2(16'sd31454)
) notch_inst (
    .aclk(aclk),
    .resetn(resetn),

    .s_axis_tdata(s_axis_tdata),
    .s_axis_tvalid(s_axis_tvalid),
    .s_axis_tready(),

    .m_axis_tdata(m_axis_tdata),
    .m_axis_tvalid(m_axis_tvalid),
    .m_axis_tready(1'b1),
    .m_axis_tlast()
);

endmodule