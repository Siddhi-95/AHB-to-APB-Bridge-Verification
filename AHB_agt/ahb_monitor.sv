///AHB MOnitor////////////

class ahb_monitor extends uvm_monitor;

        //factory registeration
        `uvm_component_utils (ahb_monitor)

        //local handle for interface
        virtual ahb_if.AHB_MON_MP vif;

        ahb_xtns xtn;
        ahb_config ahb_cfg;

        uvm_analysis_port #(ahb_xtns) ahb;

        extern function new(string name = "ahb_monitor", uvm_component parent);
        extern function void build_phase(uvm_phase phase);
        extern function void connect_phase(uvm_phase phase);
        extern task run_phase(uvm_phase phase);
        extern task collect_data();

endclass

////////---constructor-----//////
function ahb_monitor::new(string name = "ahb_monitor", uvm_component parent);
        super.new(name,parent);
        ahb = new("ahb", this);

endfunction

/////------Build Phase-----/////
function void ahb_monitor::build_phase(uvm_phase phase);
        super.build_phase(phase);
        if(!uvm_config_db #(ahb_config)::get(this, "", "ahb_config", ahb_cfg))
                `uvm_fatal("ahb_monitor", "cannot get the config file")

endfunction

////-----connect phase-------///////
function void ahb_monitor::connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        vif = ahb_cfg.aif;
endfunction

//////---Run Phase-----/////
task ahb_monitor::run_phase(uvm_phase phase);
        forever
                begin
                        collect_data();
                end
endtask

///----collect data------/////
task ahb_monitor::collect_data();
        ahb_xtns xtn;
        xtn = ahb_xtns::type_id::create("xtn");

        wait(vif.ahb_mon_cb.Hreadyout && (vif.ahb_mon_cb.Htrans == 2'b10 || vif.ahb_mon_cb.Htrans == 2'b11))
         xtn.Htrans = vif.ahb_mon_cb.Htrans;
         xtn.Hwrite = vif.ahb_mon_cb.Hwrite;
         xtn.Hsize  = vif.ahb_mon_cb.Hsize;
         xtn.Haddr  = vif.ahb_mon_cb.Haddr;
         xtn.Hburst = vif.ahb_mon_cb.Hburst;

//the xtn will be either NS or S, first cycle - collect addr and control info

        @(vif.ahb_mon_cb);

        wait(vif.ahb_mon_cb.Hreadyout && (vif.ahb_mon_cb.Htrans == 2'b10 || vif.ahb_mon_cb.Htrans == 2'b11))
                xtn.Hwdata = vif.ahb_mon_cb.Hwdata;

        xtn.print();//no delay, in the same cycle control and addr shud be collected
        ahb.write(xtn); //Send to SB
        //`uvm_info("AHB_MONITOR", "Displaying ahb_monitor data", UVM_LOW)
        ahb_cfg.mon_data_count++;
endtask
