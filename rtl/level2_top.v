`timescale 1ns/1ps

module level2_top (
    input clk,
    input reset,
    input run,
    output [3:0] count,
    output [6:0] seg
);
    counter4_run_hold counter (
        .clk(clk),
        .reset(reset),
        .run(run),
        .count(count)
    );

    // Display depends only on the stored count (Moore-style output).
    hex7seg display_decoder (
        .hex(count),
        .seg(seg)
    );
endmodule
