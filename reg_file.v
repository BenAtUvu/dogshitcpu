module regFile(input clock,
     input reset,
     input [31:0] inputValAlu,
     input [31:0] inputValMem,
     input [4:0] reg1, reg2, regd,
     input [11:0] imm,
     input read_reg,
     input write_reg,
     input read_mem,
     input write_mem,
     output reg readMem,
     output reg writeMem,
     output reg [9:0] memSelect,
     output reg [31:0] memOut,
     output reg [31:0] regVal1, regVal2
    );
reg [31:0] registers [31:0];
reg lastInstructionWasReadMem;
reg [31:0] lastRegd;
always @(posedge clock) begin
if (reset == 1'b1) begin
  lastInstructionWasReadMem = 1'b0;
registers[0] = 0;
  
end
if(write_reg == 1'b1) begin
  registers[regd] <= inputValAlu;
  $display("writing reg write=%b, regd=%b, regval=%b",write_reg,regd,registers[regd]);

end
if(lastInstructionWasReadMem == 1'b1) begin
  registers[lastRegd] <= inputValMem;
  lastInstructionWasReadMem <= 1'b0;
  $display("mem read regd=%b, memout=%b",lastRegd,inputValMem);
end
if (write_mem == 1'b1) begin
  memSelect <= registers[reg1] + imm;
  memOut <= registers[reg2];
  writeMem <= 1'b1;
  $display("mem write sel=%b, Input=%b, out=%b",registers[reg2],registers[reg1] + imm,reg2);
end
else begin
  writeMem <= 1'b0;
end


if (read_mem == 1'b1) begin
    readMem <= 1'b1;
    memSelect <= registers[reg1] + imm;
    lastInstructionWasReadMem <= 1'b1;
    lastRegd <= regd;

    $display("mem read memSelect=%b, regd=%b, memout=%b",registers[reg1] + imm,regd,inputValMem);
end
else begin
  readMem <= 1'b0;
end
end
assign regVal1 = registers[reg1];
assign regVal2 = registers[reg2];


endmodule