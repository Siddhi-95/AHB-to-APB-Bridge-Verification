class ahb_agent_config extends uvm_object;
	//factory registration
	`uvm_object_utils (ahb_agent_config)
	virtual ahb_if vif;
	uvm_active_passive_enum is_active;
	
	static int drv_data_count = 0;
        static int mon_data_count = 0;

	extern function new (string name = "ahb_agent_config");
endclass

function ahb_agent_config::new(string name = "ahb_agent_config");
	super.new(name);
endfunction
