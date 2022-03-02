class apb_agt_top extends uvm_env;

        //factory registration
        `uvm_component_utils(apb_agt_top)

        //apb agent
        apb_agent apb_agth[];

        //env_config object
        AHB_APB_env_config m_cfg;

        extern function new(string name = "apb_agt_top", uvm_component parent);
        extern function void build_phase(uvm_phase phase);

endclass: apb_agt_top

/////////--------constructor-------/////////
function apb_agt_top::new(string name = "apb_agt_top", uvm_component parent);
        super.new(name, parent);
endfunction: new

///////-------Build phase-------///////////
function apb_agt_top::build_phase(uvm_phase phase);
        super.build_phase(phase);

        if(!uvm_config_db #(AHB_APB_env_config)::get(this,"","AHB_APB_env_config",m_cfg))
                `uvm_fatal(get_type_name(),"ENV: read error")

                apb_agth = new[m_cfg.no_of_apb_agents];
        foreach(apb_agth[i])
                begin
                        apb_agth[i]=apb_agent::type_id::create($sformatf("apb_agth[%0d]",i), this);
                        uvm_config_db #(apb_config)::set(this,$sformatf("apb_agth[%0d]*", i),"apb_config", m_cfg.apb_config[i]);
                end

endfunction : build_phase
                             