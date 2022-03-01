/////////-----AHB AGENT-------//////-------//////

class ahb_agent extends uvm_agent;

        `uvm_component_utils(ahb_agent)

        ahb_config ahb_cfg;
        ahb_driver ahb_drv;
        ahb_monitor ahb_mon;
        ahb_sequencer ahb_seqr;

        extern function new(string name = "ahb_agent", uvm_component parent);
        extern function void build_phase (uvm_phase phase);
        extern function void connect_phase (uvm_phase phase);
        extern task run_phase(uvm_phase phase);
endclass

/////-------constructor-----//////
function ahb_agent::new(string name = "ahb_agent", uvm_component parent);
        super.new(name, parent);
endfunction

////-----Build phase---//////
function void ahb_agent::build_phase(uvm_phase phase);
        super.build_phase(phase);

        if(!uvm_config_db #(ahb_config)::get(this, "", "ahb_config", ahb_cfg))
                `uvm_fatal("ahb_agent", "cannot get the config file")

        ahb_mon = ahb_monitor::type_id::create("ahb_mon", this);

        if(ahb_cfg.is_active == UVM_ACTIVE)
        begin
                ahb_drv = ahb_driver::type_id::create("ahb_drv", this);
                ahb_seqr = ahb_sequencer::type_id::create("ahb_seqr", this);
		end

endfunction

////------connect_phase-------///////
function void ahb_agent::connect_phase(uvm_phase phase);
        super.connect_phase(phase);

        if(ahb_cfg.is_active == UVM_ACTIVE)
        begin
                ahb_drv.seq_item_port.connect(ahb_seqr.seq_item_export);
        end
endfunction

task ahb_agent::run_phase(uvm_phase phase);
                uvm_top.print_topology;
endtask
