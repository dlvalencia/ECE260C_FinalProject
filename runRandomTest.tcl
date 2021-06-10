exec xvlog -L uvm -sv ~/Xilinx/Vivado/2020.2/data/system_verilog/uvm_1.2/uvm_macros.svh ./SV_Files/decryptor_pkg.sv ./SV_Files/top_level_4_260_bfm.sv ./SV_Files/top_level_4_260.sv ./SV_Files/dat_mem.sv ./SV_Files/top.sv

exec xelab --timescale 1ns/1ps -L uvm top -s top_sim -debug typical

xsim top_sim -R -testplusarg UVM_TESTNAME=random_test