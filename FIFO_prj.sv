`include "RAM.sv"

module FIFO #(parameter SIZE = 8, parameter WIDTH = 8, parameter DinLENGTH = 8)(
  input clk,
  input reset,
  input read,
  input write,
  input [SIZE - 1:0] dataIn,
  output [SIZE - 1:0] dataOut,
  output empty,
  output full
);
  
  reg [SIZE - 1:0] w_ptr, r_ptr;
  wire [SIZE - 1:0] mem_addr;
  wire [SIZE - 1:0] mem_data;
  wire mem_write_enable;

  assign mem_addr = (write) ? w_ptr : r_ptr;
  assign mem_data = (write) ? dataIn : dataOut;
  assign mem_write_enable = (write && !full) ? 1'b1 : 1'b0;

  RAM #(.WIDTH(WIDTH),
    .DinLENGTH(DinLENGTH)) memory (
    .clk(clk),
    .reset(reset),
    .addr(mem_addr),
    .dataIn(mem_data),
    .write_enable(mem_write_enable),
    .dataOut(dataOut)
  );

  always @(posedge clk) begin
    if (reset == 1'b1) begin
      w_ptr <= 8'b0000_0000;
      r_ptr <= 8'b0000_0000;
    end
    else if (write && !full) begin
      w_ptr <= w_ptr + 1;
    end
    else if (read && !empty) begin
      r_ptr <= r_ptr + 1;
    end
  end

  assign full = ((w_ptr + 1) == r_ptr) || ((w_ptr == SIZE - 1) && (r_ptr == 0));
  assign empty = (w_ptr == r_ptr);

endmodule