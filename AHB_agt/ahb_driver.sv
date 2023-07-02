//AHB_Driver

class ahb_driver extends uvm_driver #(ahb_xtn);
	
	//factory registration
	`uvm_component_utils (ahb_driver)
	
	//interface
	virtual ahb_if.AHB_DR_MP vif;
	
	ahb_xtn xtn;

	ahb_agent_config ahb_cfg;
	
	extern function new (string name = "ahb_driver", uvm_component parent);
	extern function void build_phase (uvm_phase phase);
	extern function void connect_phase (uvm_phase phase);
	extern task run_phase(uvm_phase phase);
	extern task send_to_dut (ahb_xtn xtn);
endclass: ahb_driver

//-----------Constructor----------//
function ahb_driver::new (string name = "ahb_driver", uvm_component parent);
	super.new (name, parent);
endfunction: new

//-----------Build Phase---------//
function void ahb_driver::build_phase (uvm_phase phase);
	super.build_phase(phase);
	
	if(!uvm_config_db #(ahb_agent_config)::get(this, "", "ahb_agent_config", ahb_cfg))
	//m_cfg is the local handle through which we want to read the variable from config db
	//first 3 parameters of get method gives the address 
		`uvm_fatal("CONFIG","Cannot get() m_cfg from uvm_config_db. Have you set it?")
endfunction: build_phase

//----------Connect Phase---------//
function void ahb_driver::connect_phase (uvm_phase phase);
	super.connect_phase(phase);
	
	//interface connection
	vif=ahb_cfg.vif;
	
endfunction: connect_phase

//////---Run Phase-----/////
task ahb_driver::run_phase(uvm_phase phase);

        //Active low reset
        @(vif.ahb_drv_cb);
        vif.ahb_drv_cb.Hresetn <= 1'b0;

        repeat(3)
        @(vif.ahb_drv_cb);
        vif.ahb_drv_cb.Hresetn <= 1'b1;

        forever
                begin
                        seq_item_port.get_next_item(req); //get the data from sequencer
                        req.print();
                        send_to_dut(req);
                        seq_item_port.item_done();
                end
endtask


///----send to dut------/////
task ahb_driver::send_to_dut(ahb_xtn xtn);

        //drive addr and control info
        vif.ahb_drv_cb.Hwrite  <= xtn.Hwrite;
        vif.ahb_drv_cb.Htrans <= xtn.Htrans;
        vif.ahb_drv_cb.Hsize   <= xtn.Hsize;
        vif.ahb_drv_cb.Haddr   <= xtn.Haddr;
        vif.ahb_drv_cb.Hreadyin<= 1'b1;
		
        @(vif.ahb_drv_cb);

        //wait till Hreadyout goes high - the moment it goes high drive Hwdata
        wait(vif.ahb_drv_cb.Hreadyout)
                vif.ahb_drv_cb.Hwdata<=xtn.Hwdata;

        //`uvm_info("AHB_DRIVER", "Displaying ahb_driver data", UVM_LOW)
        //xtn.print();

        //After driving Hwdata, we should immediately drive the address in the same cycle, so endtask w/o any delay

        ahb_cfg.drv_data_count++;
	$display("No of packets driven = %0d", ahb_cfg.drv_data_count);
endtask

/*In AHB_DRIVER, we will declare the local interface handle and assign it to the interface defined in AHB_CONFIG in the connect phase.
First, get the data from the Sequencer and drive this data to the DUT (Bridge) via the Interface.*/
