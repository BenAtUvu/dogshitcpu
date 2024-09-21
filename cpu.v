// Code your design here
module cu(input wire clock,
input wire reset,
input [31:0] instruction, 
output reg [4:0] select1, select2, regd,
output reg regfileRead, regfileWrite,
output reg [3:0] opcode,
output reg useImmAsReg2,
output reg [11:0] imm,
output reg readMem,
output reg writeMem);
always @(posedge clock)
begin
if (instruction[6:2] == 5'b00100) begin
//addi
  if (instruction[14:12] == 3'b000)begin
    $display("\n-----intruction addi------\n");
      select1 <= instruction[19:15];
      regd <= instruction[11:7];
      imm <= instruction[31:20];
      opcode <= 4'b0000;
      regfileRead <= 1'b1;
      regfileWrite = 1'b1;
      readMem <= 1'b0;
      writeMem <= 1'b0;
      useImmAsReg2 <= 1'b1;

	end
end
else if (instruction[6:2] == 5'b01000) begin
//sw 
    if (instruction[14:12] == 3'b010)begin
      $display("\n-----intruction sw------\n");
    
    
    imm <= {instruction[31:25], instruction[11:7]};
    select1 <= instruction[19:15];
    select2 <= instruction[24:20];
    regfileWrite <= 1'b0;
    regfileRead <= 1'b0;
    readMem <= 1'b0;
    writeMem <= 1'b1;
    useImmAsReg2 <= 1'b1;
    //offset <= {instruction[31:27], instruction[11:7]}
    //memSelect <= instruction[19:15] + {instruction[31:27], instruction[11:7]};
end
end

else if (instruction[6:2] == 5'b00000) begin
    //lw
    if(instruction[14:12] == 3'b010) begin
      $display("\n-----intruction lw------\n");
        imm <= {instruction[31:20]};
        select1 <= instruction[19:15];
        regd <= instruction[11:7];
        regfileWrite <= 1'b1;
        regfileRead <= 1'b0;
        readMem <= 1'b1;
        writeMem <= 1'b0;
        useImmAsReg2 <= 1'b1;
        
        //offset plus imm
    end
end
else begin
  regfileWrite <= 1'b0;
  regfileRead <= 1'b0;
  readMem <= 1'b0;
  writeMem <= 1'b0;
  useImmAsReg2 <= 1'b0;
end


end
endmodule
module pc(
input wire clock,
input wire reset,
input [31:0] jump,
input jumpEnable,
output reg [31:0] countOut);
  reg [31:0] count;
  always @(posedge clock) begin
    if(reset == 1) begin
      count = 0;
    end
    
    if(jumpEnable == 1'b1) begin
      count <= jump;
    end else begin
      count <= count + 1;
    end
    countOut <= count;
  end
  
endmodule
module activateImm(input activate,
              input [11:0] imm,
              input [31:0] reg2,
              output reg [31:0] result);
  always @(*) begin
    if(activate == 1)begin
      result <= {20'b00000000000000000000,imm};
    end
    else begin
      result <= reg2;
    end
  end
endmodule
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

module alu(input wire clock,
 input reset,
 input [3:0]opcode,
 input [31:0] reg1, reg2,
 output [31:0] alu_out);
reg [31:0] ALU_Result;
wire [8:0] tmp;
assign alu_out = ALU_Result; // ALU out
assign tmp = {1'b0,reg1} + {1'b0,reg2};
assign CarryOut = tmp[8]; // Carryout flag
  always @(*)
begin
case(opcode)
4'b0000: // Addition
 ALU_Result = reg1 + reg2 ; 
4'b0001: // Subtraction
 ALU_Result = reg1 - reg2 ;
4'b0010: // Multiplication
 ALU_Result = reg1 * reg2;
4'b0011: // Division
 ALU_Result = reg1/reg2;
4'b0100: // Logical shift left
 ALU_Result = reg1<<1;
4'b0101: // Logical shift right
 ALU_Result = reg1>>1;
4'b0110: // Rotate left
 ALU_Result = {reg1[6:0],reg2[7]};
4'b0111: // Rotate right
 ALU_Result = {reg1[0],reg2[7:1]};
4'b1000: //  Logical and 
 ALU_Result = reg1 & reg2;
4'b1001: //  Logical or
 ALU_Result = reg1 | reg2;
4'b1010: //  Logical xor 
 ALU_Result = reg1 ^ reg2;
4'b1011: //  Logical nor
 ALU_Result = ~(reg1 | reg2);
4'b1100: // Logical nand 
 ALU_Result = ~(reg1 & reg2);
4'b1101: // Logical xnor
 ALU_Result = ~(reg1 ^ reg2);
4'b1110: // Greater comparison
 ALU_Result = (reg1>reg2)?8'd1:8'd0 ;
4'b1111: // Equal comparison   
  ALU_Result = (reg1==reg2)?8'd1:8'd0 ;
default: ALU_Result = reg1 + reg2 ; 
endcase
end
endmodule

module dumbMem(input wire clock,
               input reset,
     input read1,
     input write1,
     input [9:0] select1,
     input [31:0] inputVal1,
     input [9:0] select2,
     input [31:0] inputVal2,
     output reg [31:0] outVal1,
     output reg [31:0] outVal2);
reg [31:0]memory[1023:0];
always @(posedge clock) begin
  if(reset == 1'b1) begin
    //addi x1, x0, 1
    //                     imm         rs1      op       rd     op
    memory[0] <=  {12'b000000000001,5'b00000,3'b000,5'b00001,5'b00100,2'b11};
    //sw x1, 512(x0) 
    memory[1] <=  {7'b0001000,5'b00001,5'b00000,3'b010,5'b00000,5'b01000,2'b11};
    //lw x2, 512(x0)
    memory[2] <=  {12'b000100000000,5'b00000,3'b010,5'b00010,5'b00000,2'b11};
    //addi x2, x2, 1
    //                   imm           rs1      op      rd       op
    memory[3] <=  {12'b000000000010,5'b00010,3'b000,5'b00010,5'b00100,2'b11};

    memory[4] <=  {12'b000000000010,5'b00010,3'b000,5'b00010,5'b00100,2'b11};

    memory[5] <=  {12'b000000000010,5'b00010,3'b000,5'b00010,5'b00100,2'b11};

    //memory[4] <=  {12'b000000000010,5'b00010,3'b111,5'b00010,5'b00100,2'b11};
  end
// if(read1 == 1'b1) begin
// outVal1 <= memory[select1];
// $display("mem read in mem sel=%b, Input=%b, out=%b",select1,memory[select1],outVal1);
// end
if(write1 == 1'b1 ) begin
memory[select1] <= inputVal1;
$display("mem write in mem sel=%b, Input=%b, out=%b",select1,memory[select1],inputVal1);

end

outVal2 <= memory[select2];
end
assign outVal1 = memory[select1];
endmodule

module cpu(input wire clock,
input wire reset,
 input [31:0] memory1,
 output wire [31:0] regToMem,
 output reg [9:0] memSelect1,
 output wire memRead1_out,
 output wire memWrite1_out,
 input [31:0] memory2,
 output [31:0] toMemory2,
 output reg [9:0] memSelect2
          );
//cu out/in
wire [4:0] cu_select1, cu_select2, regd;
wire [3:0] cu_opcode;
wire [11:0] cu_imm;
reg [31:0] instruction;
wire cu_memRead1;
wire cu_memWrite1;
//alu stuff
wire [31:0] alu_out;
wire [31:0] alu_in2;
//mem stuff
reg [31:0] memoryData;


//regfile
wire [31:0] regFileOut1, regFileOut2;
wire regfileRead;
wire regfileWrite;
wire regfileReadMem;
wire regfileWriteMem;

wire [9:0] regfile_memSelect;
reg loadedFirstInstuction;

wire [31:0]count;
wire [31:0] jump;
wire jumpEnable;
pc ProgramCounter(
  clock,
  reset,
  jump,
  jumpEnable,
  count
);
always @(*) begin
  memoryData <= memory1;
  instruction <= memory2;
  memSelect1 <= regfile_memSelect;
  memSelect2 <= count;

end
activateImm ActivateImm(ImmActivate,
              cu_imm,
              regFileOut2,
              alu_in2
);
cu controlUnit(clock,
      reset,
      instruction, 
      cu_select1, cu_select2, regd, 
      regfileRead, regfileWrite,
       cu_opcode,
       ImmActivate,
      cu_imm,
      cu_memRead1,
      cu_memWrite1
      );
regFile registerFile(clock,
     reset,
     alu_out,
     memoryData,
     cu_select1, cu_select2, regd,
     cu_imm,
     regfileRead,
     regfileWrite,
     cu_memRead1,
     cu_memWrite1,  
     memRead1_out,
     memWrite1_out,
     regfile_memSelect,
     regToMem,
     regFileOut1, regFileOut2);
  
alu ALU(clock, reset, cu_opcode,regFileOut1, alu_in2, alu_out);

endmodule
