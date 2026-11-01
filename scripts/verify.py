"""Run both Verilog testbenches and check RTL compatibility from any directory."""
from pathlib import Path
import os
import shutil
import subprocess

ROOT = Path(__file__).resolve().parents[1]
BUILD = ROOT / 'build'

def tool(name):
    found = shutil.which(name)
    fallback = Path('C:/iverilog/bin') / (name + '.exe')
    if found:
        return found
    if os.name == 'nt' and fallback.is_file():
        return str(fallback)
    raise SystemExit(f'Missing {name}: install Icarus Verilog and add it to PATH.')

def run(args, log):
    result = subprocess.run([str(x) for x in args], cwd=BUILD, text=True,
                            stdout=subprocess.PIPE, stderr=subprocess.STDOUT)
    (BUILD / log).write_text(result.stdout, encoding='utf-8')
    print(result.stdout, end='')
    if result.returncode:
        raise SystemExit(result.returncode)
    return result.stdout

def main():
    BUILD.mkdir(exist_ok=True)
    compiler, runtime = tool('iverilog'), tool('vvp')
    rtl = [ROOT / 'rtl' / f for f in
           ('counter4_run_hold.v', 'hex7seg.v', 'level2_top.v')]
    run([compiler, '-g2005', '-Wall', '-s', 'level2_top', '-t', 'null', *rtl],
        'rtl-compile.log')
    for top, source, output in (
        ('tb_level2', 'tb_level2.v', 'simulation'),
        ('tb_exhaustive_recheck', 'tb_exhaustive_recheck.v', 'exhaustive')):
        binary = BUILD / (top + '.vvp')
        run([compiler, '-g2012', '-Wall', '-s', top, '-o', binary,
             *rtl, ROOT / 'tb' / source], output + '-compile.log')
        text = run([runtime, binary], output + '.log')
        if 'PASS:' not in text:
            raise SystemExit(f'{top} did not report PASS')
    if not (BUILD / 'level2.vcd').is_file():
        raise SystemExit('Missing waveform')
    print('PASS: both testbenches, RTL compatibility and waveform generation.')

if __name__ == '__main__':
    main()
