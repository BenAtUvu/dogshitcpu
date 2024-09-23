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
