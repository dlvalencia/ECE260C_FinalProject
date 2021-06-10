class scoreboard;

    //Define the BFM
    virtual top_level_4_260_bfm bfm;

    real errorCount = 0.0;
    real totalCount = 0.0;
    
    function new(virtual top_level_4_260_bfm b);
        bfm = b;
    endfunction : new
    
    task execute();
        forever begin : self_checking_loop
            @(posedge bfm.decryptDone);
            repeat(2) @(posedge bfm.clk);
            ++totalCount;
            //repeat(4) @(posedge bfm.clk); //wait a couple of clock cycles to avoid race condition
            //Check if the input string and the output string are the same
            if(bfm.msg_copy != bfm.msg_decryp2) begin
                $display("Errors / Tests = %d/%d", ++errorCount, totalCount);
                $display("Settings used:\n");
                $display("pre-length: %h\npat_sel: %d\nLFSR_Init: %h", bfm.pre_length, bfm.pat_sel, bfm.LFSR_init);
                $display("============================================");
                $display("================I/O STRINGS=================");
                $display("============================================");
                $display("Sent: ");
                for(int k = 0; k < 64; k++)
                    $write("%s", bfm.str2_copy[k]);
                $display("\nRecv: ");
                for(int k = 0; k < 64; k++)
                    $write("%s", bfm.str_dec2[k]);
                $display("\n");
                $display("============================================");
                $display("============================================");
                //$stop;
            end
        end : self_checking_loop
    endtask : execute

    task display_score();
        $display("Error rate: %f/%f (%f)", errorCount, totalCount, errorCount/totalCount);
    endtask : display_score

endclass : scoreboard