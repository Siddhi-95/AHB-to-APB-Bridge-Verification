/////////apb CONFIG////////

class apb_config extends uvm_object;

        `uvm_object_utils (apb_config)
        virtual apb_if aif;

        //data count variables:
        static int drv_data_count = 0;
        static int mon_data_count = 0;


        uvm_active_passive_enum is_active = UVM_ACTIVE;

        extern function new(string name = "apb_config");
endclass

//---constructor-----////
function apb_config::new(string name = "apb_config");
        super.new(name);
endfunction
