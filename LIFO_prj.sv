`include "RAM.sv"

module LIFO #(parameter SIZE = 8, parameter WIDTH = 8, parameter DinLENGTH = 8)(
  input clk,
  input reset,
  input read,
  input write,
  input [SIZE - 1:0] dataIn,
  output [SIZE - 1:0] dataOut,
  output empty,
  output full
);
  
  reg [3:0] sp;
  wire mem_write_enable;
  
  assign mem_write_enable = (write && !full) ? 1'b1 : 1'b0;
  
  RAM #(.WIDTH(WIDTH),
    .DinLENGTH(DinLENGTH)) memory (
    .clk(clk),
    .reset(reset),
    .addr(sp),
    .dataIn(dataIn),
    .write_enable(mem_write_enable),
    .dataOut(dataOut)
  );
  
  always @(posedge clk) begin
    if (reset == 1'b1) begin
      sp <= 4'b0000;
    end
    else if (write && !full) begin
      sp <= sp + 1;
    end
    else if (read && !empty) begin
      sp <= sp - 1;
    end
  end
  
  assign full = (sp == 4'b1000) ? 1 : 0;
  assign empty = (sp == 4'b0000) ? 1 : 0;
  
endmodule