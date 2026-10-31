"""Refresh the browser demo from a settled VCD snapshot at every rising edge."""
import argparse
import json
import re
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]

def parse(path):
    content = path.read_text(encoding='utf-8')
    header, body = content.split('$enddefinitions $end', 1)
    scope, symbols = [], {}
    for line in header.splitlines():
        parts = line.split()
        if not parts:
            continue
        if parts[0] == '$scope':
            scope.append(parts[2])
        elif parts[0] == '$upscope':
            scope.pop()
        elif parts[0] == '$var' and scope == ['tb_level2']:
            symbols[parts[4]] = parts[3]
    unit = re.search(r'\$timescale\s+(\d+)\s*(ps|ns)\s+\$end', header)
    if not unit:
        raise ValueError('Expected a ps or ns timescale')
    scale = int(unit[1]) * (0.001 if unit[2] == 'ps' else 1)
    values, rows, previous_clock, time = {}, [], None, 0
    def sample():
        nonlocal previous_clock
        clock = values.get(symbols['clk'])
        if previous_clock != '1' and clock == '1':
            rows.append(dict(ns=time * scale,
                             count=int(values[symbols['count']], 2),
                             seg=values[symbols['seg']].zfill(7),
                             reset=int(values[symbols['reset']]),
                             run=int(values[symbols['run']])))
        previous_clock = clock
    for line in body.splitlines():
        line = line.strip()
        if not line:
            continue
        if line.startswith('#'):
            sample()
            time = int(line[1:])
        elif line[0] in '01xz':
            values[line[1:]] = line[0]
        elif line[0] in 'bB':
            value, symbol = line[1:].split()
            values[symbol] = value
    sample()
    return rows

def main():
    args = argparse.ArgumentParser()
    args.add_argument('--check', action='store_true')
    args = args.parse_args()
    rows = parse(ROOT / 'build/level2.vcd')
    if not rows:
        raise SystemExit('No rising edges found')
    demo = ROOT / 'demo/index.html'
    text = demo.read_text(encoding='utf-8')
    match = re.search(r'const trace=(\[.*?\]);', text)
    if not match:
        raise SystemExit('Embedded trace not found')
    if args.check:
        if json.loads(match[1]) != rows:
            raise SystemExit('Demo trace is stale. Run python scripts/sync_demo_trace.py')
        print(f'PASS: all {len(rows)} browser replay samples match the new Verilog run.')
    else:
        text = text[:match.start(1)] + json.dumps(rows, separators=(',', ':')) + text[match.end(1):]
        demo.write_text(text, encoding='utf-8')
        print(f'Refreshed {len(rows)} trace samples.')

if __name__ == '__main__':
    main()
