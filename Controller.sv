module Controller(
  input clk,
  input reset,
  input read, 
  input write,
  input [1:0] chip_en, //01 - BUFFER // 10 - FIFO // 11 - LIFO
  input [1:0] mode, //01 - BUFFER // 10 - FIFO // 11 - LIFO
  output reg [3:0] opcode // 01_XX - BUFFER // 10_01 - 10_10 W/R FIFO // 11_01 - 11_10 W/R LIFO
);
  
  localparam BUFFER = 4'b01_01;
  localparam FIFO = 4'b10_10;
  localparam LIFO = 4'b11_11;
  
  localparam OP_BUFFER = 4'b01_00;
  
  localparam OP_FIFO_BLOCKED = 4'b10_00;
  localparam OP_FIFO_WRITE = 4'b10_01;
  localparam OP_FIFO_READ = 4'b10_10;
  
  localparam OP_LIFO_BLOCKED = 4'b10_00;
  localparam OP_LIFO_WRITE = 4'b11_01;
  localparam OP_LIFO_READ = 4'b11_10;
  
  always@ (posedge clk) 
    begin
      if (reset == 1'b1) begin
        opcode <= 4'bZZZZ;
      end
    end
  
  always@ (chip_en or mode or read or write)
      begin
        casex({chip_en, mode})
          //BUFFER
          BUFFER: opcode <= OP_BUFFER;
          //FIFO
          FIFO:
            begin
              if(write && read)
                opcode <= OP_FIFO_BLOCKED;
              else if(write)
                opcode <= OP_FIFO_WRITE;
              else if(read)
                opcode <= OP_FIFO_READ;
            end
          //LIFO
         LIFO:
            begin
              if(write && read)
                opcode <= OP_LIFO_BLOCKED;
              else if(write)
                opcode <= OP_LIFO_WRITE;
              else if(read)
                opcode <= OP_LIFO_READ;
            end
        endcase
  	end
  
endmodule