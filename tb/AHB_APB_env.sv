class ahb_apb_env extends uvm_env;

        `uvm_component_utils(ahb_apb_env)

        ahb_agt_top ahb_top;
        apb_agt_top apb_top;

 //       virtual_sequencer vseqrh;
        scoreboard sb;

        ahb_apb_env_config e_cfg;

        extern function new(string name = "ahb_apb_env", uvm_component parent);
        extern function void build_phase (uvm_phase phase);
        extern function void connect_phase (uvm_phase phase);
endclass

//-----------Constructor-----------//
function ahb_apb_env::new(string name = "ahb_apb_env", uvm_component parent);
        super.new(name, parent);
endfunction

//-----------Build Phase-----------//
function void  ahb_apb_env::build_phase(uvm_phase phase);
        super.build_phase(phase);

        if(!uvm_config_db #(ahb_apb_env_config)::get(this, "", "ahb_apb_env_config", e_cfg))
                `uvm_fatal("env", "cannot get the env_config")

        if(e_cfg.has_ahb_agent)
        begin
                ahb_top = ahb_agt_top::type_id::create("ahb_top", this);
   //             uvm_config_db #(ahb_agent_config)::set(this, "*agt*", "ahb_agent_config", e_cfg.ahb_cfg);
        end
		if(e_cfg.has_apb_agent)
        begin
                apb_top = apb_agt_top::type_id::create("apb_top", this);
   //             uvm_config_db #(apb_agent_config)::set(this, "*agt*", "apb_agent_config", e_cfg.apb_cfg);
        end

   //     if(e_cfg.has_virtual_sequencer)
     //   begin
       //         vseqrh = virtual_sequencer::type_id::create("vseqrh", this);
       // end

        if(e_cfg.has_scoreboard)
        begin
                sb = scoreboard::type_id::create("sb", this);
        end

endfunction


function void ahb_apb_env::connect_phase(uvm_phase phase);
//	if(e_cfg.has_virtual_sequencer)
 //	begin
//		if(e_cfg.has_ahb_agent)
//		begin
 //			for(int i = 0; i < e_cfg.no_of_ahb_agents; i++)
 //			begin
   //				vseqrh.ahb_seqrh[i] = ahb_top.agt[i].ahb_seqr;
 //			end
 //		end
 
//		if(e_cfg.has_apb_agent)
  //		begin
 //			for(int i = 0; i < e_cfg.no_of_apb_agents; i++)
//			begin
 //				vseqrh.apb_seqrh[i] = apb_top.agt[i].apb_seqr;
 //			end
 //		end
  
		if(e_cfg.has_scoreboard)
 		begin
  			if(e_cfg.has_ahb_agent)
  			begin
 				foreach(e_cfg.ahb_cfg[i])
   				begin
	   				ahb_top.agt[i].ahb_mon.monitor_port.connect(sb.fifo_ahb[i].analysis_export);
 				end
 			end
 
			if(e_cfg.has_apb_agent)
 			begin
 				foreach(e_cfg.apb_cfg[i])
  				begin
	  				apb_top.agt[i].apb_mon.monitor_port.connect(sb.fifo_apb[i].analysis_export);
 				end
 			end
 		end
 //	end
endfunction	
