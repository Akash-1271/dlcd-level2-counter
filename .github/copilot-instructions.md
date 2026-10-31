# Review context

This is a beginner DLCD lab project. Review functional RTL correctness, synchronous reset priority, run/hold timing, wraparound, abcdefg active-high glyphs, browser controls, and tests.

The assignment has ambiguous wording: a two-state Moore controller versus direct run-controlled MUX behavior. The implementation uses direct run selection and has no separate controller state bit. This known limitation must remain visible in README and DESIGN; do not describe it as a fully implemented separate two-state controller.

Interactive browser mode is a JavaScript behavior model. Actual trace mode must match freshly simulated Verilog edge samples. Review this distinction and portable reproducibility. Keep code simple and maintain all tests. Do not remove checks to make CI pass.
