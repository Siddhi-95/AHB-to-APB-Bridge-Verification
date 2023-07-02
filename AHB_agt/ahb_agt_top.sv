class ahb_agt_top extends uvm_env;

	//factory registration
	`uvm_component_utils(ahb_agt_top)

	ahb_agent agt[]; //dynamic array for ahb agents
	ahb_apb_env_config m_cfg;//config object for env

	extern function new (string name = "ahb_agt_top", uvm_component parent);
	extern function void build_phase(uvm_phase phase);
	extern function void end_of_elaboration_phase (uvm_phase phase);

endclass

//------------Constructor----------//
function ahb_agt_top::new(string name = "ahb_agt_top", uvm_component parent);
	super.new(name,parent);
endfunction

//build phase
function void ahb_agt_top::build_phase(uvm_phase phase);

	super.build_phase(phase);

	if(!uvm_config_db#(ahb_apb_env_config)::get(this,"","ahb_apb_env_config",m_cfg))
		`uvm_fatal(get_type_name,"not able to get configuration")
	
	agt=new[m_cfg.no_of_ahb_agents];
	foreach(agt[i])
	begin
		agt[i]=ahb_agent::type_id::create($sformatf("agt[%0d]", i),this);
		uvm_config_db #(ahb_agent_config)::set(this,$sformatf("agt[%0d]*", i),"ahb_agent_config", m_cfg.ahb_cfg[i]);
//		ahb_agent_config config will be used by all the components below agents.

	end

endfunction

//end_of_elaboration_phase
function void ahb_agt_top::end_of_elaboration_phase(uvm_phase phase);
	super.end_of_elaboration_phase(phase);
	uvm_top.print_topology;
endfunctiommn

