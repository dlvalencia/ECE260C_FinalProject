class coverage;
    
    virtual top_level_4_260_bfm bfm;
    
    int pat_sel;
    logic [7:0] pre_length, LFSR_init;

    covergroup cg;
        coverpoint pat_sel {
            bins patterns[] = {[0 : 5]};
        }
        coverpoint LFSR_init;
        coverpoint pre_length {
            bins lengths[] = {[7 : 12]};
        }
    endgroup

    function new (virtual top_level_4_260_bfm b);
        cg = new();
        bfm = b;
    endfunction : new

    task execute();
        forever begin : sampling_block
            @(negedge bfm.clk);
            pat_sel = bfm.pat_sel;
            pre_length = bfm.pre_length;
            LFSR_init = bfm.LFSR_init;
            cg.sample();
            @(posedge bfm.decryptDone);
            repeat(2) @(posedge bfm.clk);
            if(bfm.testDone) begin
                $display("Coverage = %0.2f %%", cg.get_inst_coverage());
                #10ns;
                //  $stop;
            end
                //$stop;
        end : sampling_block
        
    endtask : execute
    
    task display_cov();
        $display("Coverage = %0.2f %%", cg.get_inst_coverage());
    endtask : display_cov
    
endclass : coverage