//TO DO : ENUM // DEFINE // FLUSH MEMORY
module Top_tb;
  
  parameter WIDTH = 8;
  parameter DinLENGTH = 8;
  parameter SIZE = 8;
  
  reg clk, reset, read, write;
  reg [1:0] chip_en, mode;
  reg [SIZE-1 : 0] dataIn;
  
  wire [SIZE-1 : 0] dataOut;
  wire full, empty;
  
  Top #(
    .SIZE(SIZE),
    .WIDTH(WIDTH),
    .DinLENGTH(DinLENGTH)
  ) DUT (
    .clk(clk),
    .reset(reset),
    .read(read),
    .write(write),
    .chip_en(chip_en),
    .mode(mode),
    .dataIn(dataIn),
    .dataOut(dataOut),
    .empty(empty),
    .full(full)
  );
  
  initial begin
    clk = 1'b0;
    forever
      #5 clk = ~clk;
  end
  
  initial
    begin
      #10 reset = 1'b1; 
      #10 reset = 1'b0; read = 1'b0; write = 1'b0; dataIn = 8'd4;
      
      #20 chip_en = 2'b00; mode = 2'b00;
      //FIFO
      #20 chip_en = 2'b10; mode = 2'b10; write = 1'b1;
      
      //Inputs
      #10 dataIn = 8'd9;
      #10 dataIn = 8'd10;
      #10 dataIn = 8'd11;
      #10 dataIn = 8'd12;
      #10 dataIn = 8'd13;
      #10 dataIn = 8'd14;
      #10 dataIn = 8'd15;
      #10 dataIn = 8'd16;
      #10 dataIn = 8'd17;
      
      #20 write = 1'b0; read = 1'b1;
     
      #80 chip_en = 2'b11; mode = 2'b11;  read = 1'b0; write = 1'b1; 
      
      //LIFO
      #10 dataIn = 8'd8;
      #10 dataIn = 8'd9;
      #10 dataIn = 8'd10;
      #10 dataIn = 8'd11;
      #10 dataIn = 8'd12;
      #10 dataIn = 8'd13;
      #10 dataIn = 8'd14;
      
      #40 write = 1'b0; read = 1'b1;
      //BUFFER
      #80 chip_en = 2'b01; mode = 2'b01;  read = 1'b0; write = 1'b0;
      
      #20 dataIn = 8'd8;
      #10 dataIn = 8'd9;
      #10 dataIn = 8'd10;
      #10 dataIn = 8'd11;
      #10 dataIn = 8'd12;
      #10 dataIn = 8'd13;
      #10 dataIn = 8'd14;
      #10 dataIn = 8'd15;
            
      //FIFO -> LIFO
      
      #40 chip_en = 2'b10; mode = 2'b10; write = 1'b1; read = 1'b0;
      
      //Inputs
      #10 dataIn = 8'd8;
      #10 dataIn = 8'd9;
      //#10 dataIn = 8'd10;
      //#10 dataIn = 8'd11;
      #10 write = 1'b0;
      #20 chip_en = 2'b11; mode = 2'b11;  read = 1'b1; 
      
       //LIFO -> FIFO
      #60 chip_en = 2'b11; mode = 2'b11; read = 1'b0;
      #10 write = 1'b1;
      //Inputs
      #10 dataIn = 8'd10;
      #10 dataIn = 8'd11;
      
      
      #20 chip_en = 2'b10; mode = 2'b10;  read = 1'b1; write = 1'b0;
    end
  
  
  initial
    begin
      $dumpvars(0,DUT);
      $dumpfile("dump.vcd");
      #1000 $finish;
    end
  
endmodule