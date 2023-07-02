class apb_driver extends uvm_driver #(apb_xtn);

	//factory registration
	`uvm_component_utils(apb_driver)

	virtual apb_if.APB_DR_MP vif;

	apb_xtn xtn;

	apb_agent_config apb_cfg;

	extern function new(string name="APB_DRIVER",uvm_component parent);
	extern function void build_phase(uvm_phase phase);
	extern function void connect_phase(uvm_phase phase);
	extern task run_phase(uvm_phase);
	extern task send_to_dut(apb_xtn xtn);	

endclass

//---------Constructor-----------//
function apb_driver::new(string name="APB_DRIVER",uvm_component parent);
	super.new(name,parent);
endfunction

//----------Build Phase---------//
function void apb_driver::build_phase(uvm_phase phase);
	super.build_phase(phase);

	if(!uvm_config_db #(apb_agent_config)::get(this,"","apb_agent_config",apb_cfg))
		`uvm_fatal("DRIVER","cannot get config data");
	super.build_phase(phase);
endfunction

//---------------Connect Phase-------------//
function void apb_driver::connect_phase(uvm_phase phase);
	super.connect_phase(phase);
	vif=apb_cfg.vif;
endfunction

//////---Run Phase-----/////
task apb_driver::run_phase(uvm_phase phase);

        req = apb_xtn::type_id::create("req", this);

        forever
                begin
                        //seq_item_port.get_next_item(req);
                        send_to_dut(req);
                        //req.print();
                        //seq_item_port.item_done();
                end
endtask

///----send to dut------/////
task apb_driver::send_to_dut(apb_xtn xtn);
        wait(vif.apb_drv_cb.Pselx != 0); //wait for Psel to be high

        if(vif.apb_drv_cb.Pwrite == 0) //the moment Psel is high, check for Pwrite signal
                vif.apb_drv_cb.Prdata <= {$random};

        repeat(2) @(vif.apb_drv_cb); //wait for 2 cycles b4 generating next xtn
        //`uvm_info("apb_driver", "Displaying apb_driver data", UVM_LOW)
 //       xtn.print();
        apb_cfg.drv_data_count++;
endtask
