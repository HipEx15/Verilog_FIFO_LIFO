`include "RAM.sv"

module Execute #(parameter SIZE = 8, parameter WIDTH = 8, parameter DinLENGTH = 8)(
  input clk,
  input reset,
  input [3:0] opcode,
  input [SIZE - 1:0] dataIn,
  output [SIZE - 1:0] dataOut,
  output empty,
  output full
);
  
  //Parameters coding
  
  localparam OP_BUFFER = 4'b01_00;
  localparam OP_FIFO_WRITE = 4'b10_01;
  localparam OP_FIFO_READ = 4'b10_10;
  localparam OP_LIFO_WRITE = 4'b11_01;
  localparam OP_LIFO_READ = 4'b11_10;
    
  wire [SIZE - 1 :0] addrTemp, dataInTemp;
  wire [SIZE - 1:0] dataOutTemp;
  wire Full, Empty;
  
  //LIFO variables
  
  reg [SIZE - 1:0] sp;
  
  //FIFO variables
  
  reg [SIZE - 1:0] w_ptr, r_ptr;
  reg [WIDTH - 1:0] next_w_ptr, next_r_ptr;
  reg [1:0] lastMode;
  
  wire [SIZE - 1:0] mem_addr;
  wire [SIZE - 1:0] mem_data;
  wire mem_write_enable;
  
  assign mem_addr = (reset == 1)? 0 : ((opcode[0]) ? w_ptr : r_ptr); // Address were we insert
  assign mem_data = (reset == 1)? 0 : ((opcode[0]) ? dataIn : dataOutTemp); // Inserted value
  
  RAM #(.WIDTH(WIDTH),
    .DinLENGTH(DinLENGTH)) memory (
    .clk(clk),
    .reset(reset),
    .addr(addrTemp),
    .dataIn(dataInTemp),
    .write_enable(mem_write_enable),
    .dataOut(dataOutTemp),
    .opcode(opcode),
    .full(Full),
    .empty(Empty)
  );
  
  always @ (posedge clk) 
    begin
      if (reset == 1'b1) 
        begin
          w_ptr <= 0;
          r_ptr <= 0;
          sp <= 0;
      	end
      else
        begin
          next_w_ptr = (full) ? w_ptr : ((w_ptr == (WIDTH - 1)) ? w_ptr : (w_ptr + 1));
          next_r_ptr = (empty) ? 0 : ((r_ptr == (WIDTH - 1)) ? r_ptr : (r_ptr + 1));
          //Logic for switching between mods
          if(opcode[3:2] != lastMode) 
            begin
              if(opcode[3:2] == 2'b10) 
                begin
				//FIFO -> LIFO
              	sp <= w_ptr - r_ptr;
                end 
              else if(opcode [3:2] == 2'b11)
                begin
                  //LIFO -> FIFO
                  w_ptr <= sp;
                  r_ptr <= 0;
                end
            end
       
          
          case(opcode)
            //FIFO
            //Write
            OP_FIFO_WRITE: 
              begin
                lastMode <= 2'b11;
                if(!full)
                  begin
                  	w_ptr <= next_w_ptr;
                  end
              end
            //Read
            OP_FIFO_READ:
              begin
                lastMode <= 2'b11;
                if(!empty)
                  begin
                  	r_ptr <= next_r_ptr;
                  end
              end
            //LIFO
            //Write
            OP_LIFO_WRITE:
              begin
                lastMode <= 2'b10;
                if(!full)
                  begin
                    if(sp < WIDTH-1)
                  		sp <= sp + 1;
                    else
                      	sp <= sp;
                  end
              end
            //Read
            OP_LIFO_READ:
              begin
                lastMode <= 2'b10;
                if(!empty)
                  begin
                    if(sp > 0)
                  		sp <= sp - 1;
                    else
                      	sp <= sp;
                  end
              end
          endcase
        end
    end
  
 // assign full = (reset == 1)? 0 : ((opcode[3:2] == 2'b10) ? (((w_ptr + 1) == r_ptr) || ((w_ptr == WIDTH - 1) && (r_ptr == 0))) : (opcode[3:2] == 2'b11) ? (sp == WIDTH) : 1'b0);
 // assign empty = (reset == 1)? 0 : ((opcode[3:2] == 2'b10) ? (w_ptr == r_ptr) : (opcode[3:2] == 2'b11) ? (sp == 0) : 1'b0);
  
  assign full = Full;
  assign empty = Empty;
  
  assign mem_write_enable = (reset == 1)? 0 : ((opcode[0] && !full) ? 1'b1 : 1'b0); //Setting the Read/Write foor memory
  

  assign addrTemp = (opcode[3:2] == 2'b10) ? mem_addr : (opcode[3:2] == 2'b11) ? sp : 1'b0;
  assign dataInTemp = (opcode[3:2] == 2'b10) ? mem_data : (opcode[3:2] == 2'b11) ? dataIn : 1'b0;
  
  //BUFFER
  assign dataOut = (opcode == OP_BUFFER) ? dataIn : dataOutTemp;
  
endmodule