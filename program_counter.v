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