`timescale 1ns/1ps

module tb_lpf;

    reg clk;
    reg resetn;

    reg signed [15:0] s_axis_tdata;
    reg s_axis_tvalid;

    wire signed [15:0] m_axis_tdata;
    wire m_axis_tvalid;

    lpf_top dut (
        .aclk(clk),
        .resetn(resetn),
        .s_axis_tdata(s_axis_tdata),
        .s_axis_tvalid(s_axis_tvalid),
        .m_axis_tdata(m_axis_tdata),
        .m_axis_tvalid(m_axis_tvalid)
    );

    always #5 clk = ~clk;

    integer i;

    initial begin
        clk = 0;
        resetn = 0;
        s_axis_tdata = 0;
        s_axis_tvalid = 0;

        #20;
        resetn = 1;

        #10;
        s_axis_tvalid = 1;

        for (i = 0; i < 200; i = i + 1) begin
            @(posedge clk);

            s_axis_tdata = $rtoi(
                (20000.0 * $sin(2 * 3.14159 * i / 40.0)) +
                (2000.0  * $sin(2 * 3.14159 * i / 4.0))
            );
        end

        @(posedge clk);
        s_axis_tvalid = 0;

        #100;
        $stop;
    end

endmodule