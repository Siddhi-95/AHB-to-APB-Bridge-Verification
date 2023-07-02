//Scoreboard

class scoreboard extends uvm_scoreboard;
	
	//factory registration
	`uvm_component_utils(scoreboard)
	
	//Analysis FIFOs declaration
	uvm_tlm_analysis_fifo #(ahb_xtn) fifo_ahb[];
	uvm_tlm_analysis_fifo #(apb_xtn) fifo_apb[];
	
	//declare the handles for ahb_xtns and apb_xtns
	ahb_xtn ahb_data;
	apb_xtn apb_data;
	
	//handles for read and write coverage data
	ahb_xtn ahb_cov_data;
	apb_xtn apb_cov_data;

	//environment configuration object(handle) declaration:
	ahb_apb_env_config e_cfg;
	
	//define a queue to push data of AHB to compare it with APB
	ahb_xtn q[$];	
	//apb_xtn q1[$];

	int data_verified_count;

	//Std UVM Methods
	extern function new (string name = "scoreboard", uvm_component parent);
	extern function void build_phase (uvm_phase phase);
	extern task run_phase (uvm_phase phase);
	extern function void check_data (apb_xtn xtn);//user-defined function
	extern function void compare_data (int Hdata, Pdata, Haddr, Paddr);

	//coverage for AHB
	covergroup ahb_cg;
		option.per_instance = 1;

		//RST: coverpoint ahb_cov_data.Hresetn;
		
		SIZE: coverpoint ahb_cov_data.Hsize {bins b2[] = {[0:2]} ;}//1,2,4 bytes of data
		
		TRANS: coverpoint ahb_cov_data.Htrans {bins trans[] = {[2:3]} ;}//NS and S
		
		//BURST: coverpoint ahb_cov_data.Hburst {bins burst[] = {[0:7]} ;}
		
		ADDR: coverpoint ahb_cov_data.Haddr {bins first_slave = {[32'h8000_0000:32'h8000_03ff]} ;
						     bins second_slave = {[32'h8400_0000:32'h8400_03ff]};
                                                     bins third_slave = {[32'h8800_0000:32'h8800_03ff]};
                                                     bins fourth_slave = {[32'h8C00_0000:32'h8C00_03ff]};}

		DATA_IN: coverpoint ahb_cov_data.Hwdata {bins low = {[0:32'h0000_ffff]};
                                                         bins mid1 = {[32'h0001_ffff:32'hffff_ffff]};}

                DATA_OUT : coverpoint ahb_cov_data.Hrdata {bins low = {[0:32'h0000_ffff]};
                                                           bins mid1 = {[32'h0001_ffff:32'hffff_ffff]};}
		WRITE : coverpoint ahb_cov_data.Hwrite;

		SIZEXWRITE: cross SIZE, WRITE;

		//ADDRXDATA: cross ahb_cov_data.Haddr, ahb_cov_data.Hwdata;
	endgroup: ahb_cg

	covergroup apb_cg;
		option.per_instance = 1;
		
		ADDR : coverpoint apb_cov_data.Paddr {bins first_slave = {[32'h8000_0000:32'h8000_03ff]};
                                                      bins second_slave = {[32'h8400_0000:32'h8400_03ff]};
                                                      bins third_slave = {[32'h8800_0000:32'h8800_03ff]};
                                                      bins fourth_slave = {[32'h8C00_0000:32'h8C00_03ff]};}
				
		DATA_IN : coverpoint apb_cov_data.Pwdata {bins low = {[0:32'h0000_ffff]};
                                                          bins mid1 = {[32'h0001_ffff:32'hffff_ffff]};}

                DATA_OUT : coverpoint apb_cov_data.Prdata {bins low = {[0:32'hffff_ffff]};}

                WRITE : coverpoint apb_cov_data.Pwrite;

                SEL : coverpoint apb_cov_data.Pselx {bins first_slave = {4'b0001};
                                                     bins second_slave = {4'b0010};
                                                     bins third_slave = {4'b0100};
                                                     bins fourth_slave = {4'b1000};}

		WRITEXSEL: cross WRITE, SEL;
		//ADDRXWRITE: cross apv_cov_data.Paddr, apb_cov_data.Pwrite;
	endgroup: apb_cg
endclass: scoreboard

function scoreboard::new (string name = "scoreboard", uvm_component parent);
	super.new (name, parent);
	ahb_cov_data = new();
	apb_cov_data = new();
	ahb_cg = new();
        apb_cg = new();
endfunction: new

function void  scoreboard::build_phase(uvm_phase phase);
	super.build_phase(phase);
	
	//get the config object e_cfg
	if(!uvm_config_db #(ahb_apb_env_config)::get(this, "", "ahb_apb_env_config", e_cfg))
		`uvm_fatal("CONFIG", "Cannot get() e_cfg, have you set() it?")
		
	//create object for analysis fifo
	fifo_ahb = new[e_cfg.no_of_ahb_agents];
	fifo_apb = new[e_cfg.no_of_apb_agents];
	
	foreach(fifo_ahb[i])
	begin
		fifo_ahb[i] = new($sformatf("fifo_ahb[%0d]",i), this);
	end
	
	foreach(fifo_apb[i])
	begin
		fifo_apb[i] = new($sformatf("fifo_apb[%0d]",i), this);
	end
	
endfunction: build_phase

task scoreboard::run_phase(uvm_phase phase);

	fork
		
		begin
		forever
			begin
				fifo_ahb[0].get(ahb_data);
				q.push_back(ahb_data);
				$display("Size of the queue = %d", q.size);
				ahb_cov_data = ahb_data;
				//sample the AHB CG
				ahb_cg.sample();
			end
		end

		begin
		forever
			begin		
				fifo_apb[0].get(apb_data);
				//q1.push_back(apb_data);
				check_data(apb_data);
				apb_cov_data = apb_data;
				//sample the APB CG
				apb_cg.sample();
			end
		end


	join
endtask: run_phase

//-------comparing AHB and APB data------//
function void scoreboard::check_data(apb_xtn xtn);
        //ahb transaction data
        ahb_data = q.pop_front();
	
        if(ahb_data.Hwrite)
        begin
                case(ahb_data.Hsize)

                2'b00:
                begin
                        if(ahb_data.Haddr[1:0] == 2'b00)
                                compare_data(ahb_data.Hwdata[7:0], apb_data.Pwdata[7:0], ahb_data.Haddr, apb_data.Paddr);
                        if(ahb_data.Haddr[1:0] == 2'b01)
                                compare_data(ahb_data.Hwdata[15:8], apb_data.Pwdata[7:0], ahb_data.Haddr, apb_data.Paddr);
                        if(ahb_data.Haddr[1:0] == 2'b10)
                                compare_data(ahb_data.Hwdata[23:16], apb_data.Pwdata[7:0], ahb_data.Haddr, apb_data.Paddr);
                        if(ahb_data.Haddr[1:0] == 2'b11)
                                compare_data(ahb_data.Hwdata[31:24], apb_data.Pwdata[7:0], ahb_data.Haddr, apb_data.Paddr);

                end
		2'b01:
                begin
                        if(ahb_data.Haddr[1:0] == 2'b00)
                                compare_data(ahb_data.Hwdata[15:0], apb_data.Pwdata[15:0], ahb_data.Haddr, apb_data.Paddr);
                        if(ahb_data.Haddr[1:0] == 2'b10)
                                compare_data(ahb_data.Hwdata[31:16], apb_data.Pwdata[15:0], ahb_data.Haddr, apb_data.Paddr);
                end

                2'b10:
                        compare_data(ahb_data.Hwdata, apb_data.Pwdata, ahb_data.Haddr, apb_data.Paddr);

                endcase
        end

        else
        begin
                case(ahb_data.Hsize)

                2'b00:
                begin
                        if(ahb_data.Haddr[1:0] == 2'b00)
                                compare_data(ahb_data.Hrdata[7:0], apb_data.Prdata[7:0], ahb_data.Haddr, apb_data.Paddr);
                        if(ahb_data.Haddr[1:0] == 2'b01)
                                compare_data(ahb_data.Hrdata[7:0], apb_data.Prdata[15:8], ahb_data.Haddr, apb_data.Paddr);
                        if(ahb_data.Haddr[1:0] == 2'b10)
                                compare_data(ahb_data.Hrdata[7:0], apb_data.Prdata[23:16], ahb_data.Haddr, apb_data.Paddr);
                        if(ahb_data.Haddr[1:0] == 2'b11)
                                compare_data(ahb_data.Hrdata[7:0], apb_data.Prdata[31:24], ahb_data.Haddr, apb_data.Paddr);

                end

                2'b01:
                begin
			if(ahb_data.Haddr[1:0] == 2'b00)
                                compare_data(ahb_data.Hrdata[15:0], apb_data.Prdata[15:0], ahb_data.Haddr, apb_data.Paddr);
			if(ahb_data.Haddr[1:0] == 2'b10)
                                compare_data(ahb_data.Hrdata[15:0], apb_data.Prdata[31:16], ahb_data.Haddr, apb_data.Paddr);
                end

                2'b10:
                        compare_data(ahb_data.Hrdata, apb_data.Prdata, ahb_data.Haddr, apb_data.Paddr);

                endcase
        end
endfunction

function void scoreboard::compare_data(int Hdata, Pdata, Haddr, Paddr);

        if(Haddr == Paddr)
	begin
                $display("Address compared Successfully");
		$display("HADDR=%h, PADDR=%h", Haddr, Paddr);
	end
        else
        begin
                $display("Address not compared Successfully");
		$display("HADDR=%h, PADDR=%h", Haddr, Paddr);
               // $finish;
        end

        if(Hdata == Pdata) 
	begin
                $display("Data compared Successfully");
		$display("HDATA=%h, PDATA=%h", Hdata, Pdata);
	end
        else
        begin
                $display("Data not compared Successfully");
		$display("HDATA=%h, PDATA=%h", Hdata, Pdata);
               // $finish;
        end

        data_verified_count ++;
	$display ("Data verified = %d", data_verified_count);
endfunction

