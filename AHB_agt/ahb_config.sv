/////////AHB CONFIG////////

class ahb_config extends uvm_object;

        `uvm_object_utils (ahb_config)
        virtual ahb_if aif;
        uvm_active_passive_enum is_active = UVM_ACTIVE;

        static int drv_data_count = 0;
        static int mon_data_count = 0;

        extern function new(string name = "ahb_config");
endclass

//---constructor-----////
function ahb_config::new(string name = "ahb_config");
        super.new(name);
endfunction
