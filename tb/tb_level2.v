`timescale 1ns/1ps

// Independent self-checking verification. Inputs change only on falling edges.
module tb_level2;
    reg clk = 1'b0;
    reg reset = 1'b1;
    reg run = 1'b0;
    wire [3:0] count;
    wire [6:0] seg;
    reg [3:0] decoder_hex;
    wire [6:0] decoder_seg;
    reg [3:0] expected_count = 4'h0;
    reg initialized = 1'b0;
    reg decoder_done = 1'b0;
    reg [15:0] seen = 16'h0000;
    integer edge_checks = 0;
    integer stability_checks = 0;
    integer decoder_checks = 0;
    integer run_checks = 0;
    integer hold_checks = 0;
    integer reset_checks = 0;
    integer wraps = 0;
    integer i;

    level2_top dut (.clk(clk), .reset(reset), .run(run), .count(count), .seg(seg));
    hex7seg decoder_dut (.hex(decoder_hex), .seg(decoder_seg));
    always #5 clk = ~clk;

    // Derive abcdefg bits from the physical segments lit by each glyph.
    // This oracle deliberately uses segment names, not the DUT binary table.
    function [6:0] expected_segments;
        input [3:0] value;
        reg [55:0] lit;
        reg [7:0] letter;
        integer j;
        begin
            case (value)
                4'h0: lit = "abcdef";
                4'h1: lit = "bc";
                4'h2: lit = "abdeg";
                4'h3: lit = "abcdg";
                4'h4: lit = "bcfg";
                4'h5: lit = "acdfg";
                4'h6: lit = "acdefg";
                4'h7: lit = "abc";
                4'h8: lit = "abcdefg";
                4'h9: lit = "abcdfg";
                4'ha: lit = "abcefg";
                4'hb: lit = "cdefg";
                4'hc: lit = "adef";
                4'hd: lit = "bcdeg";
                4'he: lit = "adefg";
                4'hf: lit = "aefg";
            endcase
            expected_segments = 7'b0000000;
            for (j = 0; j < 7; j = j + 1) begin
                letter = lit[j*8 +: 8];
                if ((letter >= "a") && (letter <= "g"))
                    expected_segments[6 - (letter - "a")] = 1'b1;
            end
        end
    endfunction

    task check_outputs;
        begin
            if (count !== expected_count)
                $fatal(1, "FAIL at %0t: count=%h expected=%h reset=%b run=%b", $time, count, expected_count, reset, run);
            if (seg !== expected_segments(expected_count))
                $fatal(1, "FAIL at %0t: seg=%b expected=%b count=%h", $time, seg, expected_segments(expected_count), count);
        end
    endtask

    always @(posedge clk) begin
        if (reset) begin
            expected_count = 4'h0;
            initialized = 1'b1;
            reset_checks = reset_checks + 1;
        end else if (initialized && run) begin
            if (expected_count == 4'hf) wraps = wraps + 1;
            expected_count = expected_count + 4'h1;
            run_checks = run_checks + 1;
        end else if (initialized) begin
            hold_checks = hold_checks + 1;
        end
        // Allow nonblocking assignments and the combinational decoder to settle.
        #1;
        if (initialized) begin
            check_outputs;
            edge_checks = edge_checks + 1;
            seen[count] = 1'b1;
            $display("EDGE t=%0t reset=%b run=%b count=%h seg=%b OK", $time, reset, run, count, seg);
        end
    end

    task cycle;
        input next_reset;
        input next_run;
        begin
            @(negedge clk);
            reset = next_reset;
            run = next_run;
            // Changing run/reset must not change the stored count off-edge.
            #1;
            check_outputs;
            stability_checks = stability_checks + 1;
            #2;
            check_outputs;
            stability_checks = stability_checks + 1;
            @(posedge clk);
            #2;
        end
    endtask

    initial begin
        $dumpfile("level2.vcd");
        $dumpvars(0, tb_level2);
        $display("DLCD Level 2 Problem 2 self-checking simulation");
        $display("seg[6:0]={a,b,c,d,e,f,g}, active high; checks occur after settling");
    end

    initial begin
        #1; // Drive the first value after all combinational processes are waiting.
        for (integer digit = 0; digit < 16; digit = digit + 1) begin
            decoder_hex = digit;
            #2;
            if (decoder_seg !== expected_segments(decoder_hex))
                $fatal(1, "FAIL decoder hex=%h seg=%b expected=%b", decoder_hex, decoder_seg, expected_segments(decoder_hex));
            decoder_checks = decoder_checks + 1;
            $display("DECODE hex=%h seg=%b OK", decoder_hex, decoder_seg);
        end
        decoder_done = 1'b1;
    end

    initial begin
        @(posedge clk); #2; // Establish a known state through synchronous reset.
        repeat (5) cycle(1'b0, 1'b1);
        $display("CHECK nonzero HOLD for six cycles, then immediate resume");
        repeat (6) cycle(1'b0, 1'b0);
        cycle(1'b0, 1'b1);
        $display("CHECK synchronous reset asserted off-edge at nonzero count, with run=1");
        cycle(1'b1, 1'b1);
        cycle(1'b1, 1'b1); // Reset must keep priority over counting.
        cycle(1'b0, 1'b0); // Reset release must not increment during HOLD.
        $display("CHECK two complete 16-count sequences and wraparound");
        repeat (32) cycle(1'b0, 1'b1);
        repeat (4) cycle(1'b0, 1'b0);
        cycle(1'b0, 1'b1);
        if (!decoder_done || decoder_checks != 16 || seen !== 16'hffff || wraps < 2 || hold_checks < 10 || reset_checks < 3)
            $fatal(1, "FAIL coverage decoder=%0d seen=%h wraps=%0d hold=%0d reset=%0d", decoder_checks, seen, wraps, hold_checks, reset_checks);
        $display("PASS: %0d edge checks, %0d between-edge checks, 16/16 decoder patterns, all 16 counts, %0d wraps; run=%0d hold=%0d reset=%0d", edge_checks, stability_checks, wraps, run_checks, hold_checks, reset_checks);
        $finish;
    end

    initial begin
        #2000;
        $fatal(1, "FAIL timeout: test did not complete within 2000 ns");
    end
endmodule
