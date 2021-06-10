class random_test extends uvm_test;
   `uvm_component_utils(random_test);

 virtual top_level_4_260_bfm bfm;
   
   function new (string name, uvm_component parent);
      super.new(name,parent);
      if(!uvm_config_db #(virtual top_level_4_260_bfm)::get(null, "*","bfm", bfm))
        $fatal("Failed to get BFM");
   endfunction : new

   task run_phase(uvm_phase phase);
      random_tester random_tester_h;
      coverage      coverage_h;
      scoreboard    scoreboard_h;

      phase.raise_objection(this);

      random_tester_h = new(bfm);
      coverage_h      = new(bfm);
      scoreboard_h    = new(bfm);
      
      fork
         coverage_h.execute();
         scoreboard_h.execute();
      join_none

      random_tester_h.execute();
      scoreboard_h.display_score();
      coverage_h.display_cov();
      phase.drop_objection(this);
      $display("Test done!");
      $stop;
   endtask : run_phase

endclass
   