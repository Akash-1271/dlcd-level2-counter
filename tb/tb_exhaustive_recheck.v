`timescale 1ns/1ps
module tb_exhaustive_recheck;
 reg clk=0, reset=0, run=0;
 wire [3:0] count;
 wire [6:0] seg;
 integer q,r,u,k,checks=0;
 reg [3:0] old_count;
 reg [6:0] old_seg;
 level2_top dut(.clk(clk),.reset(reset),.run(run),.count(count),.seg(seg));
 task step;
  input rst;
  input en;
  input [3:0] expected;
  input check_stable;
  begin
   old_count=count; old_seg=seg;
   reset=rst; run=en;
   #2;
   if(check_stable && ((count !== old_count) || (seg !== old_seg)))
    $fatal(1,"Off-edge output change q=%h reset=%b run=%b",old_count,rst,en);
   #3; clk=1;
   #1;
   if(count !== expected) $fatal(1,"Transition failure old=%h reset=%b run=%b got=%h expected=%h",old_count,rst,en,count,expected);
   #4; clk=0;
  end
 endtask
 initial begin
  for(q=0;q<16;q=q+1) begin
   for(r=0;r<2;r=r+1) begin
    for(u=0;u<2;u=u+1) begin
     step(1,0,0,0);
     for(k=0;k<q;k=k+1) step(0,1,k+1,1);
     step(r,u,r ? 0 : (u ? ((q+1)%16) : q),1);
     checks=checks+1;
    end
   end
  end
  $display("PASS: exhaustive recheck of all %0d combinations of count[3:0], reset and run, including off-edge stability.",checks);
  $finish;
 end
endmodule
