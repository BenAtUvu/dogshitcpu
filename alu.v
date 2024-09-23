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