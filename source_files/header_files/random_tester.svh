class random_tester;
    virtual top_level_4_260_bfm bfm;
    
    function new (virtual top_level_4_260_bfm b);
        bfm = b;
    endfunction : new

    protected function logic [5 : 0] get_init();
        bit [5 : 0] init_val;
        init_val = $random;
        if(init_val == 6'h00)
            return 6'h01;
        else
            return init_val;
    endfunction : get_init

    protected function logic [6:0] get_pre_length();
        bit [6 : 0] pre_length;
        pre_length = $random;
        if(pre_length < 7 || pre_length > 12)
            pre_length = 7;
        return pre_length;               
    endfunction : get_pre_length

    protected function logic [6:0] get_pat_sel();
        bit [6 : 0] pat_sel;
        pat_sel = $random;
        if(pat_sel > 5)
            pat_sel = 5;
        return pat_sel;               
    endfunction : get_pat_sel

    protected function st_testvars get_settings();
        st_testvars randomSettings;
        //Get the pre-length size
        randomSettings.LFSR_Init = get_init();
        randomSettings.pre_length = get_pre_length();
        randomSettings.pat_sel = get_pat_sel();
        return randomSettings;
    endfunction : get_settings
    
    protected function string get_string();
        bit [2:0] strSelect;
        strSelect = $random;
        //string randString;
        if(strSelect == 3'b000) begin
            return "Mr_Watson_come here_I_want_to_see_you";
        end
        else if(strSelect == 3'b001) begin
            return "    This string has leading spaces";
        end
        else if(strSelect == 3'b010) begin
            return "abcdefg12345   ";
        end
        else if(strSelect == 3'b011) begin
            return "Arrakis, Dune, Desert planet..";
        end
        else if(strSelect == 3'b100) begin
            return "All work and no play makes Jack a dull boy.";
        end
        else if(strSelect == 3'b101) begin
            return "Go then, there are other worlds than these.";
        end
        else if(strSelect == 3'b110) begin
            return "   abcdefg12345";
        end
        else begin
            return "M-O-O-N, that spells SystemVerilog!";
        end        
        //return randString
        
    endfunction : get_string

    task execute();
        st_testvars settings;
        repeat(10000) begin: random_loop
            //Get settings
            //$display("Loop top");
            settings = get_settings();
            bfm.reset_mem();
            bfm.encrypt_string(get_string(), settings);
            bfm.send_settings();
            @(posedge bfm.decryptDone);
            repeat(20) @(posedge bfm.clk);
        end : random_loop
        bfm.finish_test();
        #20ns;
        //$stop;
    endtask : execute

endclass : random_tester