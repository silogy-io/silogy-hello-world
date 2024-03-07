// A little vga module James wrote in 2019. That was 5 years ago!
//
// 
// 

module top
  (
   // Declare some signals so we can see how I/O works
   input i_clk,
   input i_reset_n, 
   //inputs ... 
   input  [9:0] i_vga_r,               
   input  [9:0] i_vga_g,
   input  [9:0] i_vga_b,
   //outputs ...  
   output reg [9:0] o_vga_r_DAC,
   output reg [9:0] o_vga_g_DAC,
   output reg [9:0] o_vga_b_DAC,
   output wire  [9:0] o_x_addr,
   output wire  [9:0] o_y_addr
   );
   /* verilator lint_off UNUSEDSIGNAL */
  wire vga_hs, vga_vs, vga_blank;
  // And an example sub module. The submodule will print stuff.
  vga vga (/*AUTOINST*/
           // Inputs
           .clock                        (i_clk),
           .reset_n                      (i_reset_n),
           .vga_r                        (i_vga_r),
           .vga_g                        (i_vga_g),
           .vga_b                        (i_vga_b),
           .vga_r_DAC                    (o_vga_r_DAC),
           .vga_g_DAC                    (o_vga_g_DAC),
           .vga_b_DAC                    (o_vga_b_DAC),
           .x_addr                       (o_x_addr),
           .y_addr                       (o_y_addr),
           .vga_hs                       (vga_hs),
           .vga_vs                       (vga_vs),
           .vga_blank                    (vga_blank)

         );

  // Print some stuff as an example
  initial begin
     if ($test$plusargs("trace") != 0) begin
        $display("[%0t] Tracing to logs/vga_dump.vcd...\n", $time);
        $dumpfile("logs/vga_dump.vcd");
        $dumpvars();
     end
     $display("[%0t] VGA model running...\n", $time);
  end

  always_ff @ (posedge i_clk) begin
         if (o_y_addr == 480) begin
            // Lets just render one page
            $finish;
         end
   end





endmodule
