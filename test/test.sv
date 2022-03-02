class base_test extends uvm_test;

        `uvm_component_utils(base_test)

        AHB_APB_env e_cfg;
        AHB_APB_env_config m_cfg;

        ahb_config ahbcfg[];
        apb_config apbcfg[];

        bit has_ahb_agent = 1;
        bit has_apb_agent = 1;
        int no_of_ahb_agents = 1;
        int no_of_apb_agents = 1;

        extern function new(string name = "base_test", uvm_component parent);
        extern function void build_phase(uvm_phase phase);
endclass: base_test

///////-Constructor class-------///
function base_test::new(string name = "base_test", uvm_component parent);
        super.new(name, parent);
endfunction: new

///////--Build phase--------/////
function void base_test:: build_phase(uvm_phase phase);
        super.build_phase(phase);

        m_cfg = AHB_APB_env_config::type_id::create("AHB_APB_env_config", this);
        e_cfg = AHB_APB_env::type_id::create("AHB_APB_env", this);

        if(has_ahb_agent)
                m_cfg.ahb_cfg = new[m_cfg.no_of_ahb_agents];

        if(has_apb_agent)
				m_cfg.ahb_cfg = new[m_cfg.no_of_ahb_agents];

        if(has_apb_agent)
                m_cfg.apb_cfg = new[m_cfg.no_of_apb_agents];

    //AHB agent configuration:
    if(has_ahb_agent)
        begin
            //ahbcfg = new[m_cfg.no_of_ahb_agents];
           ahbcfg = new[m_cfg.no_of_ahb_agents];

            foreach(ahbcfg[i])
                begin
                    ahbcfg[i]=ahb_config::type_id::create($sformatf("ahbcfg[%0d]",i));

                    //get the virtual interface from the config class:
                    if(!uvm_config_db #(virtual ahb_if)::get(this,"","vif_ahb", ahbcfg[i].aif))
                                `uvm_fatal("VIF CONFIG-WRITE","Cannot get() vif from uvm_config_db. Have you set it?")

                        ahbcfg[i].is_active = UVM_ACTIVE;
                        m_cfg.ahb_cfg[i]=ahbcfg[i];
                end
        end

    //APB agent configuration:
    if(has_apb_agent)
        begin
            apbcfg = new[m_cfg.no_of_apb_agents];
            foreach(apbcfg[i])
                begin
                    apbcfg[i]=apb_config::type_id::create($sformatf("apbcfg[%0d]",i));
					//get the virtual interface from the config class:
                    if(!uvm_config_db #(virtual apb_if)::get(this,"","vif_apb", apbcfg[i].aif))
                                `uvm_fatal("VIF CONFIG-WRITE","Cannot get() vif from uvm_config_db. Have you set it?")

                        apbcfg[i].is_active = UVM_ACTIVE;
                        m_cfg.apb_cfg[i]=apbcfg[i];
                end
        end

        m_cfg.has_ahb_agent = has_ahb_agent;
        m_cfg.has_apb_agent = has_apb_agent;
        m_cfg.no_of_ahb_agents = no_of_ahb_agents;
        m_cfg.no_of_apb_agents = no_of_apb_agents;

        uvm_config_db #(AHB_APB_env_config)::set(this, "*", "AHB_APB_env_config", m_cfg);

        //e_cfg = AHB_APB_env::type_id::create("AHB_APB_env", this);
endfunction: build_phase


////---------test 1------//////
class test_1 extends base_test;

        `uvm_component_utils(test_1)

        vseq t_seqh;

        extern function new(string name = "test_1", uvm_component parent);
        extern function void build_phase(uvm_phase phase);
        //extern function void end_of_elaboration_phase(uvm_phase phase);
        extern task run_phase(uvm_phase phase);
endclass
//////----------constructor-------///////
function test_1::new(string name = "test_1", uvm_component parent);
        super.new(name, parent);
endfunction

////---------build_phase----------///////
function void test_1::build_phase(uvm_phase phase);
        super.build_phase(phase);
endfunction

///////------end_of_elaboration_phase----------//////
//function void test_1::end_of_elaboration_phase(uvm_phase phase);
//      uvm_top.print_toplogy();
//endfunction

/////////-------run_phase---------////////
task test_1::run_phase(uvm_phase phase);

        phase.raise_objection(this);

        t_seqh = vseq::type_id::create("t_seqh");
        t_seqh.start(e_cfg.vseqrh);

        phase.drop_objection(this);
endtask
