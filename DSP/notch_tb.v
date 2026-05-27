`timescale 1ns/1ps

module tb_notch;

    reg clk;
    reg resetn;

    reg signed [15:0] s_axis_tdata;
    reg s_axis_tvalid;

    wire signed [15:0] m_axis_tdata;
    wire m_axis_tvalid;

    notch dut (
        .aclk(clk),
        .resetn(resetn),
        .s_axis_tdata(s_axis_tdata),
        .s_axis_tvalid(s_axis_tvalid),
        .m_axis_tdata(m_axis_tdata),
        .m_axis_tvalid(m_axis_tvalid)
    );

    always #5 clk = ~clk;  // 100 MHz

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

        // 1 kHz sampling ? 1 sample per 100,000 clock cycles
        for (i = 0; i < 40000; i = i + 1) begin
            repeat (100000) @(posedge clk);

            s_axis_tdata = $rtoi(
                (15000.0 * $sin(2.0 * 3.14159 * i / 100.0)) +   // 10 Hz (target notch)
                (10000.0 * $sin(2.0 * 3.14159 * i / 20.0))     // 50 Hz (should pass)
            );
        end

        @(posedge clk);
        s_axis_tvalid = 0;

        #1000000;
        $stop;
    end

endmodule