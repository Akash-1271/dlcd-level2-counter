`timescale 1ns/1ps

module counter4_run_hold (
    input clk,
    input reset,
    input run,
    output [3:0] count
);
    wire [3:0] count_plus_one;
    wire [3:0] next_count;

    // A four-bit result discards the carry: 1111 + 1 becomes 0000.
    assign count_plus_one = count + 4'b0001;

    // RUN and HOLD describe the current control mode selected by run.
    // There is no extra stored mode bit: the current run input selects
    // the D inputs immediately, ready for the next rising clock edge.
    level2_mux4 mux_count (
        .hold_value(count),
        .run_value(count_plus_one),
        .select_run(run),
        .out(next_count)
    );

    // These four one-bit flip-flops store the complete counter state.
    level2_dff_sync_reset ff0 (
        .clk(clk), .reset(reset), .d(next_count[0]), .q(count[0])
    );
    level2_dff_sync_reset ff1 (
        .clk(clk), .reset(reset), .d(next_count[1]), .q(count[1])
    );
    level2_dff_sync_reset ff2 (
        .clk(clk), .reset(reset), .d(next_count[2]), .q(count[2])
    );
    level2_dff_sync_reset ff3 (
        .clk(clk), .reset(reset), .d(next_count[3]), .q(count[3])
    );
endmodule

// Four-bit 2-to-1 MUX: run=0 feeds back count; run=1 feeds count+1.
module level2_mux4 (
    input [3:0] hold_value,
    input [3:0] run_value,
    input select_run,
    output [3:0] out
);
    assign out = select_run ? run_value : hold_value;
endmodule

// Synchronous active-high reset has priority over the selected D input.
module level2_dff_sync_reset (
    input clk,
    input reset,
    input d,
    output reg q
);
    always @(posedge clk) begin
        if (reset)
            q <= 1'b0;
        else
            q <= d;
    end
endmodule
