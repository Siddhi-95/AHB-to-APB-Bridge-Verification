class apb_agt_top extends uvm_env;
	
	//factory reg
	`uvm_component_utils(apb_agt_top)

	ahb_apb_env_config m_cfg;
	apb_agent agt[];

	//uvm_methods
        extern function new(string name = "apb_agt_top" , uvm_component parent);
        extern function void build_phase(uvm_phase phase);

endclass

//code for new
function apb_agt_top::new(string name="apb_agt_top",uvm_component parent);
	super.new(name,parent);
endfunction

//code for build phase
function void apb_agt_top::build_phase(uvm_phase phase);
	
	super.build_phase(phase);
	if(!uvm_config_db #(ahb_apb_env_config)::get(this,"","ahb_apb_env_config",m_cfg))
		`uvm_fatal(get_type_name,"not able to get the configuration")

	agt =new[m_cfg.no_of_apb_agents];
	foreach(agt[i])
	begin
		agt[i]=apb_agent::type_id::create($sformatf("agt[%0d]", i),this);
		uvm_config_db #(apb_agent_config)::set(this,$sformatf("agt[%0d]*", i), "apb_agent_config", m_cfg.apb_cfg[i]);
	end

endfunction
