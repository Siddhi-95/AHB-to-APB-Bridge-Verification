class apb_driver extends uvm_driver#(apb_xtns);

        //factory registeration
        `uvm_component_utils (apb_driver)

        //local handle for interface
        virtual apb_if.AHP_DRV_MP vif;
        apb_xtns xtn;
        apb_config apb_cfg;

        extern function new(string name = "apb_driver", uvm_component parent);
        extern function void build_phase(uvm_phase phase);
        extern function void connect_phase(uvm_phase phase);
        extern task run_phase(uvm_phase phase);
        extern task send_to_dut(apb_xtns xtn);

endclass

////////---constructor-----//////
function apb_driver::new(string name = "apb_driver", uvm_component parent);
        super.new(name,parent);
endfunction

/////------Build Phase-----/////
function void apb_driver::build_phase(uvm_phase phase);
        super.build_phase(phase);

        if(!uvm_config_db #(apb_config)::get(this, "", "apb_config", apb_cfg))
                `uvm_fatal("apb_driver", "cannot get the config file")

endfunction

////-----connect phase-------///////
function void apb_driver::connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        vif = apb_cfg.aif;
endfunction

//////---Run Phase-----/////
task apb_driver::run_phase(uvm_phase phase);

        req = apb_xtns::type_id::create("req", this);

        forever
                begin
                        seq_item_port.get_next_item(req);
                        send_to_dut(req);
        //              req.print();
                        seq_item_port.item_done();
                end
endtask

///----send to dut------/////
task apb_driver::send_to_dut(apb_xtns xtn);
        wait(vif.apb_drv_cb.Pselx != 0); //wait for Psel to be high

        if(vif.apb_drv_cb.Pwrite == 0) //the moment Psel is high, check for Pwrite signal
                vif.apb_drv_cb.Prdata <= {$random};

        repeat(2) @(vif.apb_drv_cb); //wait for 2 cycles b4 generating next xtn
        //`uvm_info("apb_driver", "Displaying apb_driver data", UVM_LOW)
        //xtn.print();
        apb_cfg.drv_data_count++;
endtask
