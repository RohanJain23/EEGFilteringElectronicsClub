`timescale 1ns / 1ps

module lpf_top (
    input aclk,
    input resetn,

    input  signed [15:0] s_axis_tdata,
    input  s_axis_tvalid,

    output signed [15:0] m_axis_tdata,
    output m_axis_tvalid
);

biquad_axi_stream #(
    .b0(16'sd4290),      // From 0.0201
    .b1(16'sd7590),      // From 0.0402
    .b2(16'sd4290),      // From 0.0201
    .a1(-16'sd25575),   // From -1.561 (Subtracted in your logic)
    .a2(16'sd10507)     // From 0.6413 (Subtracted in your logic)
) lpf_inst (
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
