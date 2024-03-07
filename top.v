///////////////////////////////////////////////////////////////////////////////
// Description:       Simple test bench for SPI Master module
///////////////////////////////////////////////////////////////////////////////


module top(
    input i_reset_n,
    input i_clk,
    input [7:0] i_TX_Byte,
    input i_TX_DV,
    output o_TX_Ready,
    output o_RX_DV,
    output [7:0] o_RX_Byte

  );
  
  parameter SPI_MODE = 3; // CPOL = 1, CPHA = 1
  parameter CLKS_PER_HALF_BIT = 4;  // 6.25 MHz

 
  /* verilator lint_off UNUSEDSIGNAL */
  logic w_SPI_Clk;
  logic w_SPI_MOSI;


  // Instantiate UUT
  SPI_Master 
  #(.SPI_MODE(SPI_MODE),
    .CLKS_PER_HALF_BIT(CLKS_PER_HALF_BIT)) SPI_Master_UUT
  (
   // Control/Data Signals,
   .i_Rst_L(i_reset_n),     // FPGA Reset
   .i_Clk(i_clk),         // FPGA Clock
   
   // TX (MOSI) Signals
   .i_TX_Byte(i_TX_Byte),     // Byte to transmit on MOSI
   .i_TX_DV(i_TX_DV),         // Data Valid Pulse with i_TX_Byte
   .o_TX_Ready(o_TX_Ready),   // Transmit Ready for Byte
   
   // RX (MISO) Signals
   .o_RX_DV(o_RX_DV),       // Data Valid pulse (1 clock cycle)
   .o_RX_Byte(o_RX_Byte),   // Byte received on MISO

   // SPI Interface
   .o_SPI_Clk(w_SPI_Clk),
   .i_SPI_MISO(w_SPI_MOSI),
   .o_SPI_MOSI(w_SPI_MOSI)
   );


  //// Sends a single byte from master.
  //task SendSingleByte(input [7:0] data);
  //  @(posedge r_Clk);
  //  r_Master_TX_Byte <= data;
  //  r_Master_TX_DV   <= 1'b1;
  //  @(posedge r_Clk);
  //  r_Master_TX_DV <= 1'b0;
  //  @(posedge w_Master_TX_Ready);
  //endtask // SendSingleByte

  //
  //initial
  //  begin
  //    // Required for EDA Playground
  //    $dumpfile("dump.vcd"); 
  //    $dumpvars;
  //    
  //    repeat(10) @(posedge r_Clk);
  //    r_Rst_L  = 1'b0;
  //    repeat(10) @(posedge r_Clk);
  //    r_Rst_L          = 1'b1;
  //    
  //    // Test single byte
  //    SendSingleByte(8'hC1);
  //    $display("Sent out 0xC1, Received 0x%X", r_Master_RX_Byte); 
  //    
  //    // Test double byte
  //    SendSingleByte(8'hBE);
  //    $display("Sent out 0xBE, Received 0x%X", r_Master_RX_Byte); 
  //    SendSingleByte(8'hEF);
  //    $display("Sent out 0xEF, Received 0x%X", r_Master_RX_Byte); 
  //    repeat(10) @(posedge r_Clk);
  //    $finish();      
  //  end // initial begin

endmodule // SPI_Slave
