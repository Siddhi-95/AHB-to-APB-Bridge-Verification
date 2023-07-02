class ahb_apb_bridge_test extends uvm_test;

	`uvm_component_utils(ahb_apb_bridge_test)

	ahb_apb_env_config m_cfg;
	ahb_apb_env e_cfg;

	ahb_agent_config ahb_cfg[];
	apb_agent_config apb_cfg[];

	int no_of_ahb_agents=1;
	int no_of_apb_agents=1;
	bit has_scoreboard=1;
	bit has_virtual_sequencer=1;

	extern function new(string name="TEST",uvm_component parent);
	extern function void build_phase(uvm_phase phase);
	//extern task run_phase(uvm_phase);

endclass

//----------Constructor-----------//
function ahb_apb_bridge_test:: new(string name="TEST",uvm_component parent);
	super.new(name,parent);
endfunction

//-----------Build Phase----------//
function void ahb_apb_bridge_test:: build_phase(uvm_phase phase);
	super.build_phase(phase);	

	m_cfg = ahb_apb_env_config::type_id::create("ahb_apb_env_config", this);
        e_cfg = ahb_apb_env::type_id::create("ahb_apb_env", this);
	//these shud be written before declaring dynamic array

	if(m_cfg.has_ahb_agent)
	begin
		m_cfg.ahb_cfg=new[no_of_ahb_agents];
	end
	
	if(m_cfg.has_apb_agent)
	begin
		m_cfg.apb_cfg=new[no_of_apb_agents];
	end
	
	//m_cfg = ahb_apb_env_config::type_id::create("ahb_apb_env_config", this);
	//e_cfg = ahb_apb_env::type_id::create("ahb_apb_env", this);

	ahb_cfg=new[no_of_ahb_agents];
	apb_cfg=new[no_of_apb_agents];
	
	foreach(apb_cfg[i])
	begin
		apb_cfg[i]=apb_agent_config::type_id::create($sformatf("apb_cfg[%0d]",i));
		if(!uvm_config_db #(virtual apb_if)::get(this,"","apb_vif",apb_cfg[i].vif))
			`uvm_fatal("TEST","cannot get config data");

		apb_cfg[i].is_active=UVM_ACTIVE;
		m_cfg.apb_cfg[i]=apb_cfg[i];

		//uvm_config_db #(apb_agent_config)::set(this,$sformatf("*agt[%0d]*",i),"apb_agent_config",m_cfg.apb_cfg[i]);


	 
	end

	//uvm_config_db #(apb_agent_config)::set(this,$sformatf("*agt[%0d]*",i),"apb_agent_config",m_cfg.apb_cfg[i]);

	foreach(ahb_cfg[i])
	begin
		ahb_cfg[i]=ahb_agent_config::type_id::create($sformatf("ahb_cfg[%0d]",i));
		if(!uvm_config_db #(virtual ahb_if)::get(this,"","ahb_vif",ahb_cfg[i].vif))
			`uvm_fatal("TEST","cannot get config data");

		ahb_cfg[i].is_active=UVM_ACTIVE;
		m_cfg.ahb_cfg[i]=ahb_cfg[i];
	
		//uvm_config_db #(ahb_agent_config)::set(this,$sformatf("*agt[%0d]*",i),"ahb_agent_config",m_cfg.ahb_cfg[i]);


	end

	//uvm_config_db #(ahb_agent_config)::set(this,$sformatf("*agt[%0d]*",i),"ahb_agent_config",m_cfg.ahb_cfg[i]);


	m_cfg.no_of_ahb_agents=no_of_ahb_agents;
	m_cfg.no_of_apb_agents=no_of_apb_agents;
	m_cfg.has_scoreboard=has_scoreboard;
	m_cfg.has_virtual_sequencer=has_virtual_sequencer;
	
	uvm_config_db#(ahb_apb_env_config) ::set(this,"*","ahb_apb_env_config",m_cfg);
endfunction


////---------test 1------//////
class test_1 extends ahb_apb_bridge_test;

        `uvm_component_utils(test_1)

       // vseq t_seqh;
	test_sequence t_seqh;

        extern function new(string name = "test_1", uvm_component parent);
        extern function void build_phase(uvm_phase phase);
        extern task run_phase(uvm_phase phase);
endclass

function test_1::new(string name = "test_1", uvm_component parent);
        super.new(name, parent);
endfunction


////---------build_phase----------///////
function void test_1::build_phase(uvm_phase phase);
        super.build_phase(phase);
endfunction

/////////-------run_phase---------////////
task test_1::run_phase(uvm_phase phase);

        phase.raise_objection(this);

        t_seqh = test_sequence::type_id::create("t_seqh");
        t_seqh.start(e_cfg.ahb_top.agt[0].ahb_seqr);

        phase.drop_objection(this);
endtask

////---------test 1------//////
class test_2 extends ahb_apb_bridge_test;

        `uvm_component_utils(test_2)

       // vseq t_seqh;
        write_back t_seqh;

        extern function new(string name = "test_2", uvm_component parent);
        extern function void build_phase(uvm_phase phase);
        extern task run_phase(uvm_phase phase);
endclass

function test_2::new(string name = "test_2", uvm_component parent);
        super.new(name, parent);
endfunction


////---------build_phase----------///////
function void test_2::build_phase(uvm_phase phase);
        super.build_phase(phase);
endfunction

/////////-------run_phase---------////////
task test_2::run_phase(uvm_phase phase);

        phase.raise_objection(this);

        t_seqh = write_back::type_id::create("t_seqh");
        t_seqh.start(e_cfg.ahb_top.agt[0].ahb_seqr);
	#20ns;
        phase.drop_objection(this);
endtask

