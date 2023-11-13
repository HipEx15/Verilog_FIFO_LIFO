// Code your design here

`include "Controller.sv"
`include "Execute.sv"

module Top #(parameter SIZE = 8, parameter WIDTH = 8, parameter DinLENGTH = 8)(
  input clk,
  input reset,
  input read, 
  input write,
  input [1:0] chip_en,
  input [1:0] mode,
  input [SIZE - 1:0] dataIn,
  output [SIZE - 1:0] dataOut,
  output empty,
  output full
);
  
  wire [3:0] opcodeTmp;
  
  Controller ctrl(
    .clk(clk),
    .reset(reset),
    .read(read),
    .write(write),
    .chip_en(chip_en),
    .mode(mode),
    .opcode(opcodeTmp)
  );
  
  Execute #(
    .SIZE(SIZE),
    .WIDTH(WIDTH),
    .DinLENGTH(DinLENGTH)
   ) exec (
    .clk(clk),
    .reset(reset),
    .opcode(opcodeTmp),
    .dataIn(dataIn),
    .dataOut(dataOut),
    .empty(empty),
    .full(full)
  );
  
endmodule