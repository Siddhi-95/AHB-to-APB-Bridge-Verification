class virtual_sequencer extends uvm_sequencer #(uvm_sequence_item);

        `uvm_component_utils(virtual_sequencer)

        ahb_sequencer ahb_seqrh[];
        apb_sequencer apb_seqrh[];

        AHB_APB_env_config m_cfg;

        extern function new(string name = "virtual_sequencer", uvm_component parent);
        extern function void build_phase(uvm_phase phase);

endclass: virtual_sequencer

// Define Constructor new() function
function virtual_sequencer::new(string name="virtual_sequencer",uvm_component parent);
   super.new(name,parent);
endfunction
// function void build_phase

function void virtual_sequencer::build_phase(uvm_phase phase);
   super.build_phase(phase);
   // get the config object using uvm_config_db
   if(!uvm_config_db #(AHB_APB_env_config)::get(this,"","AHB_APB_env_config",m_cfg))
      `uvm_fatal("CONFIG","cannot get() m_cfg from uvm_config_db. Have you set() it?")
   ahb_seqrh = new[m_cfg.no_of_ahb_agents];
   apb_seqrh = new[m_cfg.no_of_apb_agents];
endfunction
