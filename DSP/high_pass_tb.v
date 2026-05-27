`timescale 1ns/1ps

module tb_hpf;

    reg clk;
    reg resetn;

    reg signed [15:0] s_axis_tdata;
    reg s_axis_tvalid;

    wire signed [15:0] m_axis_tdata;
    wire m_axis_tvalid;

    hpf_top dut (
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

        // 100 kHz sampling ? 1 sample per 1000 clock cycles
        for (i = 0; i < 40000; i = i + 1) begin
            repeat (100000) @(posedge clk);

            s_axis_tdata = $rtoi(
                (10000.0  * $sin(2.0 * 3.14159 * i / 1000.0)) +  // 100 Hz
                (15000.0 * $sin(2.0 * 3.14159 * i / 100.0))     // 1 kHz
            );
        end

        @(posedge clk);
        s_axis_tvalid = 0;

        #100000;
        $stop;
    end

endmodule