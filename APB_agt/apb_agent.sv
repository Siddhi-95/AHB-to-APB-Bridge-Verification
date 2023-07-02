class apb_agent extends uvm_agent;
	
	//factory registration
	`uvm_component_utils(apb_agent)

	apb_driver apb_drv;
	apb_monitor apb_mon;
	apb_sequencer apb_seqr;

	apb_agent_config apb_cfg;

	extern function new(string name = "apb_agent", uvm_component parent);
	extern function void build_phase(uvm_phase phase);
	extern function void connect_phase (uvm_phase phase);
endclass

//-------------Constructor--------//
function apb_agent::new(string name="apb_agent", uvm_component parent);
	super.new(name,parent);
endfunction

//------------Build Phase---------//
function void apb_agent::build_phase(uvm_phase phase);
	super.build_phase(phase);

	if(!uvm_config_db#(apb_agent_config)::get(this,"","apb_agent_config",apb_cfg))
		`uvm_fatal(get_type_name,"unable to get configuration")

        apb_mon = apb_monitor::type_id::create("apb_mon",this);
        if(apb_cfg.is_active==UVM_ACTIVE)
        begin
        	apb_drv=apb_driver::type_id::create("apb_drv",this);
                apb_seqr=apb_sequencer::type_id::create("apb_seqr",this);
        end
endfunction

//-------------connect phase---------//
function void apb_agent::connect_phase(uvm_phase phase);
	super.connect_phase(phase);

        if(apb_cfg.is_active==UVM_ACTIVE)
        begin
        	apb_drv.seq_item_port.connect(apb_seqr.seq_item_export);
        end
endfunction
