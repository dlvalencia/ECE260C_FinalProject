package decryptor_pkg;
    import uvm_pkg::*;
`include "uvm_macros.svh"

    typedef struct {
        logic [7:0] pre_length;
        int pat_sel;
        logic [5:0] LFSR_Init;
    } st_testvars;

`include "scoreboard.svh"
`include "coverage.svh"
`include "random_tester.svh"
`include "random_test.svh"
endpackage : decryptor_pkg