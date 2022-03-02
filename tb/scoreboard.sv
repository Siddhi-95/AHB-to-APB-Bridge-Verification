class scoreboard extends uvm_scoreboard;

        `uvm_component_utils (scoreboard)

        uvm_tlm_analysis_fifo #(ahb_xtns) ahb_fifo[];
        uvm_tlm_analysis_fifo #(apb_xtns) apb_fifo[];

        //declare handles for ahb and apb txn class
        ahb_xtns ahb_xtn;
        apb_xtns check_xtn;

        //Declare the handles for read & write coverage data of type read_xtn and write_xtn respectively
        ahb_xtns ahb_cov_data;
        apb_xtns apb_cov_data;

        AHB_APB_env_config m_cfg;

        //define a queue to push data of AHB to compare it with APB
        ahb_xtns q[$];

        int data_verified_count;

        extern function new(string name="scoreboard", uvm_component parent);
        extern function void build_phase(uvm_phase phase);
        extern task run_phase(uvm_phase phase);
        extern function void check_data(apb_xtns xtn); //user-defined function
        extern function void compare_data(int Hdata, Pdata, Haddr, Paddr);

        //coverage for AHB
        covergroup ahb_cg;
                option.per_instance = 1;

                //RST : coverpoint ahb_cov_data.Hresetn {bins low = {[0:1]} ;}
                SIZE : coverpoint ahb_cov_data.Hsize {bins ad1[] = {[0:2]};} //1/2/4 bytes of data
				TRANS: coverpoint ahb_cov_data.Htrans {bins trans[] = {[2:3]};} //NS and Sequential
                //Burst : coverpoint ahb_cov_data.Hburst {bins burst = {[0:7};}
                ADDR : coverpoint ahb_cov_data.Haddr {bins first_slave = {[32'h8000_0000:32'h8000_03ff]};
                                                                                          bins second_slave = {[32'h8400_0000:32'h8400_03ff]};
                                                                                          bins third_slave = {[32'h8800_0000:32'h8800_03ff]};
                                                                                          bins fourth_slave = {[32'h8C00_0000:32'h8C00_03ff]};}

                DATA_IN : coverpoint ahb_cov_data.Hwdata {bins low = {[0:32'h0000_ffff]};
                                                                                                  bins mid1 = {[32'h0001_ffff:32'hffff_ffff]};}

                DATA_OUT : coverpoint ahb_cov_data.Hrdata {bins low = {[0:32'h0000_ffff]};
                                                                                                  bins mid1 = {[32'h0001_ffff:32'hffff_ffff]};}

                //resp : coverpoint ahb_cov_data.Hresp {bins resp[] = {[0,1]};}

                WRITE : coverpoint ahb_cov_data.Hwrite;
                //ready : coverpoint ahb_cov_data.Hreadyout;
        endgroup: ahb_cg

        covergroup apb_cg;
                option.per_instance = 1;//its not options, simply option

                ADDR : coverpoint apb_cov_data.Paddr {bins first_slave = {[32'h8000_0000:32'h8000_03ff]};
                                                                                          bins second_slave = {[32'h8400_0000:32'h8400_03ff]};
                                                                                          bins third_slave = {[32'h8800_0000:32'h8800_03ff]};
                                                                                          bins fourth_slave = {[32'h8C00_0000:32'h8C00_03ff]};}
				DATA_IN : coverpoint apb_cov_data.Pwdata {bins low = {[0:32'h0000_ffff]};
                                                                                                  bins mid1 = {[32'h0001_ffff:32'hffff_ffff]};}

                DATA_OUT : coverpoint apb_cov_data.Prdata {bins low = {[0:32'h0000_ffff]};
                                                                                                  bins mid1 = {[32'h0001_ffff:32'hffff_ffff]};}

                WRITE : coverpoint apb_cov_data.Pwrite;

                SEL : coverpoint apb_cov_data.Pselx {bins first_slave = {4'b0001};
                                                                                         bins second_slave = {4'b0010};
                                                                                         bins third_slave = {4'b0100};
                                                                                         bins fourth_slave = {4'b1000};}
        endgroup: apb_cg

endclass: scoreboard

//-----Constructor------//
function scoreboard::new(string name = "scoreboard", uvm_component parent);
        super.new(name, parent);
        ahb_cov_data = new;
        apb_cov_data = new;
        ahb_cg = new();
        apb_cg = new();
endfunction: new

//-------build phase-------//
function void scoreboard::build_phase(uvm_phase phase);
        super.build_phase(phase);

        if(!uvm_config_db #(AHB_APB_env_config)::get(this,"","AHB_APB_env_config",m_cfg))
			`uvm_fatal("CONFIG","Cannot get() e_cfg, have you set() it?")

        ahb_fifo = new[m_cfg.no_of_ahb_agents];
        apb_fifo = new[m_cfg.no_of_apb_agents];

        foreach(ahb_fifo[i])
        begin
                ahb_fifo[i] = new($sformatf("ahb_fifo[%0d]",i),this);
        end

        foreach(apb_fifo[i])
        begin
                apb_fifo[i] = new($sformatf("apb_fifo[%0d]",i),this);
        end

endfunction: build_phase

task scoreboard::run_phase(uvm_phase phase);

        fork
                begin
                forever
                        begin
                                ahb_fifo[0].get(ahb_xtn);
                        //      ahb_xtn.display("Data from SB");
                                q.push_back(ahb_xtn);
                                $display("Size of the Queue = %d", q.size);
                                ahb_cov_data = ahb_xtn;
                                //sample the AHB cover group
                                ahb_cg.sample();
                        end
                end
				begin
				forever
                        begin
                                apb_fifo[0].get(check_xtn);
                        //      apb_xtn.display("Data from SB");
                                check_data(check_xtn);
                                apb_cov_data = check_xtn;
                                //sample the APB cover group
                                apb_cg.sample();
                        end
                end
        join

endtask:run_phase

//-------comparing AHB and APB data------//
function void scoreboard::check_data(apb_xtns xtn);
        //ahb transaction data
        ahb_xtn = q.pop_front();

        if(ahb_xtn.Hwrite)
        begin
                case(ahb_xtn.Hsize)

                2'b00:
                begin
                        if(ahb_xtn.Haddr[1:0] == 2'b00)
                                compare_data(ahb_xtn.Hwdata[7:0], check_xtn.Pwdata[7:0], ahb_xtn.Haddr, check_xtn.Paddr);
                        if(ahb_xtn.Haddr[1:0] == 2'b01)
                                compare_data(ahb_xtn.Hwdata[15:8], check_xtn.Pwdata[7:0], ahb_xtn.Haddr, check_xtn.Paddr);
                        if(ahb_xtn.Haddr[1:0] == 2'b10)
                                compare_data(ahb_xtn.Hwdata[23:16], check_xtn.Pwdata[7:0], ahb_xtn.Haddr, check_xtn.Paddr);
                        if(ahb_xtn.Haddr[1:0] == 2'b11)
                                compare_data(ahb_xtn.Hwdata[31:24], check_xtn.Pwdata[7:0], ahb_xtn.Haddr, check_xtn.Paddr);

                end
				2'b01:
                begin
                        if(ahb_xtn.Haddr[1:0] == 2'b00)
                                compare_data(ahb_xtn.Hwdata[15:0], check_xtn.Pwdata[15:0], ahb_xtn.Haddr, check_xtn.Paddr);
                        if(ahb_xtn.Haddr[1:0] == 2'b10)
                                compare_data(ahb_xtn.Hwdata[31:16], check_xtn.Pwdata[15:0], ahb_xtn.Haddr, check_xtn.Paddr);
                end

                2'b10:
                        compare_data(ahb_xtn.Hwdata, check_xtn.Pwdata, ahb_xtn.Haddr, check_xtn.Paddr);

                endcase
        end

        else
        begin
                case(ahb_xtn.Hsize)

                2'b00:
                begin
                        if(ahb_xtn.Haddr[1:0] == 2'b00)
                                compare_data(ahb_xtn.Hrdata[7:0], check_xtn.Prdata[7:0], ahb_xtn.Haddr, check_xtn.Paddr);
                        if(ahb_xtn.Haddr[1:0] == 2'b01)
                                compare_data(ahb_xtn.Hrdata[15:8], check_xtn.Prdata[7:0], ahb_xtn.Haddr, check_xtn.Paddr);
                        if(ahb_xtn.Haddr[1:0] == 2'b10)
                                compare_data(ahb_xtn.Hrdata[31:16], check_xtn.Prdata[7:0], ahb_xtn.Haddr, check_xtn.Paddr);
                        if(ahb_xtn.Haddr[1:0] == 2'b11)
                                compare_data(ahb_xtn.Hrdata[31:16], check_xtn.Prdata[7:0], ahb_xtn.Haddr, check_xtn.Paddr);

                end

                2'b01:
                begin
						if(ahb_xtn.Haddr[1:0] == 2'b00)
                                compare_data(ahb_xtn.Hrdata[15:0], check_xtn.Prdata[15:0], ahb_xtn.Haddr, check_xtn.Paddr);
						if(ahb_xtn.Haddr[1:0] == 2'b10)
                                compare_data(ahb_xtn.Hrdata[31:16], check_xtn.Prdata[15:0], ahb_xtn.Haddr, check_xtn.Paddr);
                end

                2'b10:
                        compare_data(ahb_xtn.Hrdata, check_xtn.Prdata, ahb_xtn.Haddr, check_xtn.Paddr);

                endcase
        end
endfunction

function void scoreboard::compare_data(int Hdata, Pdata, Haddr, Paddr);

        if(Haddr == Paddr)
                $display("Address compared Successfully");
        else
        begin
                $display("Address not compared Successfully");
                $finish;
        end

        if(Hdata == Pdata)
                $display("Address compared Successfully");
        else
        begin
                $display("Address not compared Successfully");
                $finish;
        end

        data_verified_count ++;
endfunction

                         


