module RAM #(parameter WIDTH = 8, parameter DinLENGTH = 32) (
  input clk,
  input reset,
  input [WIDTH - 1:0] addr,
  input [DinLENGTH - 1:0] dataIn,
  input write_enable,
  input [3:0] opcode,
  output reg [WIDTH - 1:0] dataOut,
  output reg full,
  output reg empty
);

  integer position;
  reg [DinLENGTH-1 : 0] Memory [WIDTH - 1 : 0];
  reg [WIDTH-1: 0] Counter;

  always @(write_enable)
    begin
      for(position = 0; position < DinLENGTH; position = position + 1) 
      		$display("%b", Memory[position]);
      $display("%d",10);
    end
  
  always @(posedge clk)
    begin
      if (reset) begin
        for(position = 0; position < WIDTH; position = position + 1) 
          Memory[position] <= 32'h0;
        dataOut <= 32'hZ;
        Counter <= 0;
        full <= 0;
        empty <= 0;
      end
      else if (write_enable && (opcode == 4'b10_01 || opcode == 4'b11_01)) 
        begin
          	if(Counter == WIDTH)
               begin
              	Counter = WIDTH;
                full <= 1;
                empty <= 0;
               end
          	else
              begin
                full <= 0;
                empty <= 0;
              	Counter = Counter + 1;
                Memory[addr] <= dataIn;
              end
        end
      else if (!write_enable && (opcode == 4'b10_10 || opcode == 4'b11_10)) 
        begin
          	if(Counter == 0)
              begin
                Counter = 0;
                empty <= 1;
                full <= 0;
              end
              else
                begin
                  	empty <= 0;
                  	full <= 0;
                	Counter = Counter - 1;
                 	dataOut <= Memory[addr];
   			 		Memory[addr] <= 0;
                end
       end
  end

endmodule