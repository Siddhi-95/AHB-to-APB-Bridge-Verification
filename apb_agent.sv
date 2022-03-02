/////////-----apb AGENT-------//////-------//////

class apb_agent extends uvm_agent;

        `uvm_component_utils(apb_agent)

        apb_config apb_cfg;
        apb_driver apb_drv;
        apb_monitor apb_mon;
        apb_sequencer apb_seqr;

        extern function new(string name = "apb_agent", uvm_component parent);
        extern function void build_phase (uvm_phase phase);
        extern function void connect_phase (uvm_phase phase);
        extern task run_phase(uvm_phase phase);
endclass

/////-------constructor-----//////
function apb_agent::new(string name = "apb_agent", uvm_component parent);
        super.new(name, parent);
endfunction

////-----Build phase---//////
function void apb_agent::build_phase(uvm_phase phase);
        super.build_phase(phase);

        if(!uvm_config_db #(apb_config)::get(this, "", "apb_config", apb_cfg))
                `uvm_fatal("apb_agent", "cannot get the config file")


        apb_mon = apb_monitor::type_id::create("apb_mon", this);

        if(apb_cfg.is_active == UVM_ACTIVE)
        begin
                apb_drv = apb_driver::type_id::create("apb_drv", this);
				apb_seqr = apb_sequencer::type_id::create("apb_seqr", this);
        end
endfunction

////------connect_phase-------///////
function void apb_agent::connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        apb_drv.seq_item_port.connect(apb_seqr.seq_item_export);
endfunction

task apb_agent::run_phase(uvm_phase phase);
                uvm_top.print_topology;
endtask
