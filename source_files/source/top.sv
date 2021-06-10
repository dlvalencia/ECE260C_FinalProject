`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06/09/2021 01:00:28 PM
// Design Name: 
// Module Name: top
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

module top;
   import uvm_pkg::*;
`include "uvm_macros.svh"
   import   decryptor_pkg::*;

   top_level_4_260_bfm       bfm();
   top_level_4_260 DUT (.clk(bfm.clk), .init(bfm.init), .rst(bfm.rst), .wr_en(bfm.wr_en), .raddr(bfm.raddr),
                       .waddr(bfm.waddr), .data_in(bfm.data_in), .data_out(bfm.data_out), .done(bfm.done));

initial begin
// the following replaces the testbench call from Ch 10
  uvm_config_db #(virtual top_level_4_260_bfm)::set(null, "*", "bfm", bfm);
  run_test();
end

endmodule : top
