interface top_level_4_260_bfm;
    import decryptor_pkg::*;
    bit clk, init, rst;
    bit wr_en;
    logic [7 : 0] raddr, waddr, data_in, data_out;
    bit done;
    
    //BFM Variables for sending a set of operations or settings to the DUT
    logic [7:0] pre_length        ,          // bytes before first character in message
              msg_padded2[64]   ,		   // original message, plus pre- and post-padding
              msg_crypto2[64]   ,          // encrypted message according to the DUT
              msg_decryp2[64]   ,
              msg_copy[64]      ;          // recovered decrypted message from DUT
    logic [5:0] LFSR_ptrn[6]      ,		   // 6 possible maximal-length 6-bit LFSR tap ptrns
                LFSR_init         ,		   // NONZERO starting state for LFSR		   
                lfsr_ptrn         ,          // one of 6 maximal length 6-tap shift reg. ptrns
                lfsr2[64]         ;          // states of program 2 decrypting LFSR         
    // our original American Standard Code for Information Interchange message follows
    // note in practice your design should be able to handle ANY ASCII string
    string     str2;
    int str_len                   ;		   // length of string (character count)
    // displayed encrypted string will go here:
    string     str_enc2[64]       ;          // decryption program input
    string     str_dec2[64]       ;          // decrypted string will go here
    string     str_padded[64]     ;
    string     str2_copy [64]     ;
    int ct                        ;
    int lk                        ;		   // counts leading spaces for program 3
    int pat_sel                   ;          // LFSR pattern select
    bit decryptDone;
    bit testDone;
    //Create a clock
    always begin
        #5ns clk = 1;
        #5ns clk = 0;
    end
    
    task reset_mem();
        init = 'b1;
        testDone = 'b0;
        wr_en = 'b1;
        rst = 'b1;
        decryptDone <= 'b0;
        for(int idx=0; idx < 64; idx=idx+1) begin
            msg_crypto2[idx] = 0;
            msg_padded2[idx] = 0;
            msg_decryp2[idx] = 0;
            msg_copy[idx] = 0;
            str2_copy[idx] = string'(byte'(0));
            str_dec2[idx] = string'(byte'(0));
        end        
        for(int qp=0; qp<256; qp++) begin
            @(posedge clk);
            wr_en   <= 'b1;                   // turn on memory write enable
            waddr   <= qp;                 // write encrypted message to mem [64:127]
            data_in <= 0;
        end
        @(posedge clk)
        wr_en   <= 'b0;                   // turn off mem write for rest of simulation
        rst <= 'b0;
        ct <= 0;
        lk <= 0;
        str_len <= 0;
        @(posedge clk);
    endtask : reset_mem

    task encrypt_string(input string randString, input st_testvars iset);
        init = 'b1;
        wr_en = 'b0;
        decryptDone <= 'b0;
        //rst = 'b1;
        str2 = randString;
        str_len = randString.len;
        // the 6 possible (constant) maximal-length feedback tap patterns from which to choose
        LFSR_ptrn[0] = 6'h21;
        LFSR_ptrn[1] = 6'h2D;
        LFSR_ptrn[2] = 6'h30;
        LFSR_ptrn[3] = 6'h33;
        LFSR_ptrn[4] = 6'h36;
        LFSR_ptrn[5] = 6'h39;
        pat_sel = iset.pat_sel;
        pre_length = iset.pre_length;
        LFSR_init = iset.LFSR_Init;
        //$display("original message string length = %d",str_len);
        for(lk = 0; lk<str_len; lk++)
            if(str2[lk]==8'h5f) continue;	        // count leading _ chars in string
            else break;                          // we shall add these to preamble pad length
        //$display("embedded leading underscore count = %d",lk);

        lfsr_ptrn = LFSR_ptrn[pat_sel];
        lfsr2[0]     = iset.LFSR_Init;              // any nonzero value (zero may be helpful for debug)
        //$display("run encryption of this original message: ");
        //$display("%s",str2)        ;           // print original message in transcript window
        //$display();
        //$display("LFSR_ptrn = %h, LFSR_init = %h %h",lfsr_ptrn,LFSR_init,lfsr2[0]);
        for(int j=0; j<64; j++) 			   // pre-fill message_padded with ASCII _ characters
            msg_padded2[j] = 8'h5f;         
        for(int l=0; l<str_len; l++)  		   // overwrite up to 60 of these spaces w/ message itself
            msg_padded2[pre_length+l] = byte'(str2[l]);
        for(int l=0; l<str_len;l++)
            str_padded[l] = string'(msg_padded2[l]);
        for(int l=0; l<str_len;l++) begin
            msg_copy[l] = byte'(str2[l]);
            str2_copy[l] = string'(byte'(str2[l]));
        end
        // compute the LFSR sequence
        for (int ii=0;ii<63;ii++) begin :lfsr_loop
            lfsr2[ii+1] = (lfsr2[ii]<<1)+(^(lfsr2[ii]&lfsr_ptrn));//{LFSR[6:0],(^LFSR[5:3]^LFSR[7])};		   // roll the rolling code
            //$display("lfsr_ptrn %d = %h",ii,lfsr2[ii]);
        end	  :lfsr_loop
        for (int i=0; i<64; i++) begin		   // testbench will change on falling clocks
            msg_crypto2[i]        = msg_padded2[i] ^ lfsr2[i];  //{1'b0,LFSR[6:0]};	   // encrypt 7 LSBs
            str_enc2[i]           = string'(msg_crypto2[i]);
        end
        repeat(5) @(posedge clk);
        for(int qp=0; qp<64; qp++) begin
            @(posedge clk);
            wr_en   <= 'b1;                   // turn on memory write enable
            waddr   <= qp+64;                 // write encrypted message to mem [64:127]
            data_in <= msg_crypto2[qp];
        end
        @(posedge clk)
        wr_en   <= 'b0;                   // turn off mem write for rest of simulation
        rst <= 'b0;
    endtask : encrypt_string
    
    //Make a task that will send the string to decode?
    task send_settings();
        
    //    for(int n=64; n<128; n++)
    //	  dut.dm1.core[n] = msg_crypto2[n-64]; //{^msg_crypto2[n-64][6:0],msg_crypto2[n-64][6:0]};
        @(posedge clk) 
        init <= 0;
        @(posedge clk);              // wait for 6 clock cycles of nominal 10ns each
           
    endtask : send_settings
    
    initial begin : decryptLoop
        forever begin
            decryptDone <= 'b0;
            @(posedge clk);
            @(posedge done);                            // wait for DUT's done flag to go high 
            //$display("run decryption:");
            for(int nn=0; nn<64; nn++)			   // count leading underscores
                if(str2[nn]==8'h5f) ct++; 
                else break;
                //$display("ct = %d",ct);
            for(int n=0; n<str_len; n++) begin
                @(posedge clk);
                raddr          <= n;
                @(posedge clk);
                msg_decryp2[n] <= data_out;
            end
            for(int rr=0; rr<str_len+1; rr++)
                str_dec2[rr] = string'(msg_decryp2[rr]);
            decryptDone <= 'b1;
            @(posedge clk);   
        end
    end : decryptLoop
    
    task finish_test();
        testDone = 'b1;
    endtask : finish_test
endinterface
