class ahb_agt_top extends uvm_env;

        //factory registration
        `uvm_component_utils(ahb_agt_top)

        //AHB agent
        ahb_agent ahb_agth[];

        //env_config object
        AHB_APB_env_config m_cfg;

        extern function new(string name = "ahb_agt_top", uvm_component parent);
        extern function void build_phase(uvm_phase phase);

endclass: ahb_agt_top

/////////--------constructor-------/////////
function ahb_agt_top::new(string name = "ahb_agt_top", uvm_component parent);
        super.new(name, parent);
endfunction: new

///////-------Build phase-------///////////
function void ahb_agt_top::build_phase(uvm_phase phase);
        super.build_phase(phase);

        if(!uvm_config_db #(AHB_APB_env_config)::get(this,"","AHB_APB_env_config",m_cfg))
                `uvm_fatal(get_type_name(),"ENV: read error")

        ahb_agth = new[m_cfg.no_of_ahb_agents];
        foreach(ahb_agth[i])
                begin
                        ahb_agth[i]=ahb_agent::type_id::create($sformatf("ahb_agth[%0d]",i), this);
                        uvm_config_db #(ahb_config)::set(this,$sformatf("ahb_agth[%0d]*", i),"ahb_config", m_cfg.ahb_cfg[i]);
                end
endfunction : build_phase
                          
