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