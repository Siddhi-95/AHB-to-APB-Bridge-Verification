class apb_agent_config extends uvm_object;

	// UVM Factory Registration Macro
	`uvm_object_utils(apb_agent_config)
	virtual apb_if vif;
	uvm_active_passive_enum is_active;

	static int drv_data_count = 0;
        static int mon_data_count = 0;

	extern function new(string name = "apb_agent_config");

endclass

function apb_agent_config::new(string name = "apb_agent_config");
	super.new(name);
endfunction

