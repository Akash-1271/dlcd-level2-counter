# Working together

1. Read README and docs/DESIGN.md.
2. Create a descriptive branch, for example `fix/reset-test`.
3. Make a small change and explain its purpose.
4. Run `python scripts/verify.py`.
5. If the waveform changes, run `python scripts/sync_demo_trace.py`, then its `--check` mode.
6. For demo changes, run `npm ci`, `npx playwright install chromium` and `npm test`.
7. Open a pull request, describe the behavior and tests, and request Copilot review.
8. Address findings; merge after the latest checks pass and the requested review completes.

Do not commit build outputs, node_modules, personal absolute paths, credentials, contact details or ZIP archives. Keep checked-in evidence labeled as a recording.

Settle the Moore-controller interpretation with the instructor before changing the architecture; update RTL, tests and diagrams together.
