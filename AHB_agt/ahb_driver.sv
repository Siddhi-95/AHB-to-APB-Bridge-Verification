///AHB Driver//////

class ahb_driver extends uvm_driver#(ahb_xtns);

        //factory registeration
        `uvm_component_utils (ahb_driver)

        //local handle for interface
        virtual ahb_if.AHB_DRV_MP vif;

        ahb_xtns xtn;
        ahb_config ahb_cfg;

        extern function new(string name = "ahb_driver", uvm_component parent);
        extern function void build_phase(uvm_phase phase);
        extern function void connect_phase(uvm_phase phase);
        extern task run_phase(uvm_phase phase);
        extern task send_to_dut(ahb_xtns xtn);

endclass

////////---constructor-----//////
function ahb_driver::new(string name = "ahb_driver", uvm_component parent);
        super.new(name,parent);
endfunction

/////------Build Phase-----/////
function void ahb_driver::build_phase(uvm_phase phase);
        super.build_phase(phase);

        if(!uvm_config_db #(ahb_config)::get(this, "", "ahb_config", ahb_cfg))
                `uvm_fatal("ahb_driver", "cannot get the config file")

endfunction
////-----connect phase-------///////
function void ahb_driver::connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        vif = ahb_cfg.aif;
endfunction

//////---Run Phase-----/////
task ahb_driver::run_phase(uvm_phase phase);

        //Active low reset
        @(vif.ahb_drv_cb);
        vif.ahb_drv_cb.Hresetn <= 1'b0;

        repeat(2)
        @(vif.ahb_drv_cb);
        vif.ahb_drv_cb.Hresetn <= 1'b1;

        forever
                begin
                        seq_item_port.get_next_item(req);
        //              req.print();
                        send_to_dut(req);
                        seq_item_port.item_done();
                end
endtask


///----send to dut------/////
task ahb_driver::send_to_dut(ahb_xtns xtn);

        //drive addr and control info
        vif.ahb_drv_cb.Hwrite  <= xtn.Hwrite;
        vif.ahb_drv_cb.Htrans <= xtn.Htrans;
        vif.ahb_drv_cb.Hsize   <= xtn.Hsize;
        vif.ahb_drv_cb.Haddr   <= xtn.Haddr;
        vif.ahb_drv_cb.Hreadyin <= 1'b1; //since we have 1 AHB Master, Hreadyin will always be high indicating to slave that Master is ready to send

        @(vif.ahb_drv_cb);

        //wait till Hreadyout goes high - the moment it goes high drive Hwdata
        wait(vif.ahb_drv_cb.Hreadyout)
                vif.ahb_drv_cb.Hwdata<=xtn.Hwdata;

        //`uvm_info("AHB_DRIVER", "Displaying ahb_driver data", UVM_LOW)
        //xtn.print();

        //After driving Hwdata, we should immediately drive the address in the same cycle, so endtask w/o any delay

        ahb_cfg.drv_data_count++;
endtask

