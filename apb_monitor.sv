///APB MOnitor////////////

class apb_monitor extends uvm_monitor;

        //factory registeration
        `uvm_component_utils (apb_monitor)

        //local handle for interface
        virtual apb_if.APB_MON_MP vif;
        apb_xtns xtn;
        apb_config apb_cfg;

        uvm_analysis_port #(apb_xtns) apb;

        extern function new(string name = "apb_monitor", uvm_component parent);
        extern function void build_phase(uvm_phase phase);
        extern function void connect_phase(uvm_phase phase);
        extern task run_phase(uvm_phase phase);
        extern task collect_data();

endclass

////////---constructor-----//////
function apb_monitor::new(string name = "apb_monitor", uvm_component parent);
        super.new(name,parent);
        apb = new("apb", this);
endfunction
/////------Build Phase-----/////
function void apb_monitor::build_phase(uvm_phase phase);
        super.build_phase(phase);

        if(!uvm_config_db #(apb_config)::get(this, "", "apb_config", apb_cfg))
                `uvm_fatal("apb_monitor", "cannot get the config file")

endfunction
////-----connect phase-------///////
function void apb_monitor::connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        vif = apb_cfg.aif;
endfunction

//////---Run Phase-----/////
task apb_monitor::run_phase(uvm_phase phase);
        forever
                begin
                        collect_data();
                end
endtask

///----collect data------/////
task apb_monitor::collect_data();
        apb_xtns xtn;
        xtn = apb_xtns::type_id::create("xtn");

        wait(vif.apb_mon_cb.Penable)
                xtn.Paddr = vif.apb_mon_cb.Paddr;
                xtn.Pwrite = vif.apb_mon_cb.Pwrite; //An automatic var. or elem. of a dynamic var. (xtn) may not be the LHS of a non-blocking assignment.

                xtn.Pselx = vif.apb_mon_cb.Pselx;//collect control info

        if(xtn.Pwrite == 1)
				xtn.Pwdata = vif.apb_mon_cb.Pwdata; //collect data
        else
                xtn.Prdata = vif.apb_mon_cb.Prdata;

        @(vif.apb_mon_cb); //give 1 cycle delay - Setup + Prenable

        apb.write(xtn);

        `uvm_info("apb_monitor", "Displaying apb_monitor data", UVM_LOW)
        apb_cfg.mon_data_count++;
endtask

