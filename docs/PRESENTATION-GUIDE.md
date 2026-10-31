# How to check and present Level 2

Team: Saameer, Aniketh, Akash, Karishma.

## Animated presentation demo

Double-click `demo/index.html` to open the offline browser demonstration. No server or internet is required. Use F11 for full screen.

1. Start in Interactive behavior model; click Start clock to count.
2. Uncheck run and show that the value holds while the clock continues.
3. Check run to resume.
4. Pause the clock, check reset and show the value has not changed yet. Click Next rising edge to clear it.
5. Uncheck reset and step through F to 0.
6. Select Actual Verilog trace and Start clock to replay the 53 recorded clock edges from the tested VCD.

The interactive mode is a JavaScript model of the RTL equations. The trace mode replays actual Icarus output; it is not live execution of Verilog. Keep GTKWave and the PASS log available as timing and verification evidence. The standalone file embeds the recorded trace, so rerunning Verilog does not automatically replace that embedded dataset.

## Current status

The working counter, decoder, testbench, simulation logs, VCD, diagrams, and truth tables are ready. The latest independent rerun passed 53 edge checks, 104 between-edge checks, all 16 segment patterns, and two wraps. An additional test passed all 64 count/reset/run combinations.

One assignment point remains unresolved: the original asks for a separate two-state Moore controller. Our RTL instead uses the current run input to select the MUX directly, following its explicit datapath and immediate-edge requirements. The RUN/HOLD diagram describes control modes; it is not a stored controller implementation. Ask the instructor whether that interpretation is acceptable before treating the submission as fully compliant. Explain this accurately; do not claim a separate state register exists.

## Run it yourself

From the repository root, run `python scripts/verify.py`. Icarus Verilog must be installed and available on PATH. On Windows, `C:/iverilog/bin` is detected automatically. Generated files go to `build/`.

Open the actual waveform with `gtkwave build/level2.vcd`. Add clk, reset, run, count and seg from tb_level2. Count is hexadecimal; seg is binary. Zoom to 45-155 ns for hold/resume/reset and 295-325 ns for wraparound.

| Event | Waveform time |
| --- | --- |
| Count holds at 5 | 60-120 ns |
| Resume gives 6 | 125 ns |
| Reset asserted, count still 6 | 130-135 ns |
| Reset clears count | 135 ns |
| Reset beats run | 145 ns |
| F wraps to 0 | 315 ns and 475 ns |

## Four-person demo plan

1. Saameer: introduce the problem and RUN/HOLD control diagram.
2. Aniketh: explain incrementer, MUX, four DFFs and synchronous reset.
3. Akash: explain the hexadecimal decoder and abcdefg bit ordering.
4. Karishma: run verification, show PASS, demonstrate the browser and waveform.

Everyone should understand the whole design for viva. Allow 5-7 minutes. Use DESIGN.md for truth tables, diagrams and questions.

## Important presentation distinction

The interactive browser mode is a behavior model. Actual Verilog trace mode replays a recorded Icarus run; it does not execute Verilog in the browser. Run `python scripts/sync_demo_trace.py` after regenerating the waveform to refresh that recording. Use the PASS log and GTKWave as verification evidence.

The current design does not include a separately registered RUN/HOLD controller. Explain the documented interpretation and confirm acceptance with the instructor.
