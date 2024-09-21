// Code your testbench here
// or browse Examples
module muxTest();
reg clock;
reg reset;
wire memActRead1;
wire memActWrite1;
wire [9:0] memSelect1;
wire [31:0] memInput1;
wire [9:0] memSelect2;
wire [31:0] memInput2;
wire [31:0] memOutput1;
wire [31:0] memOutput2;
  cpu CPU(clock,
    	  reset,
          memOutput1,
          memInput1,
          memSelect1,
          memActRead1,
          memActWrite1,
          memOutput2,
          memInput2,
          memSelect2
          
         );
dumbMem memory(clock,
               reset,
                 memActRead1,
                 memActWrite1,
                 memSelect1,
                       memInput1,
                       memSelect2,
                       memInput2,
                       memOutput1,
                       memOutput2
                      ); 
//Mux8x1 UUT(out, In[7:0],In[10:8]);
  initial begin
    #2000 $finish;
  end
  initial begin
    clock = 0;	

    for(int i =0; i<200;i++) begin
         #10;
        clock = ~clock;
  	end
  end

 initial begin		
   
	reset = 1;
   #20;
   reset =0;
   
       //$display("test passed: sel=%d, Input=%b, out=%b",In[10:8],In[7:0],out);
   
        end
          
 initial begin
        $dumpfile("dump.vcd");
        $dumpvars;
      end
           
endmodule