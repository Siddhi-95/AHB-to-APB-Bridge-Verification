class AHB_APB_env_config extends uvm_object;

        `uvm_object_utils(AHB_APB_env_config)

        bit has_ahb_agent = 1;
        bit has_apb_agent = 1;
        int no_of_ahb_agents = 1;
        int no_of_apb_agents = 1;
        bit has_scoreboard = 1;
        bit has_virtual_sequencer = 1;


        ahb_config ahb_cfg[];
        apb_config apb_cfg[];

        extern function new(string name = "AHB_APB_env_config");
endclass

function AHB_APB_env_config::new(string name = "AHB_APB_env_config");
        super.new(name);
endfunction
