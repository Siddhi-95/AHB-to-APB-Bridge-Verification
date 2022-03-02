interface ahb_if(input bit clock);

        //Inputs or outputs:
                logic Hresetn, Hwrite; //clk,reset,transfer direction - master

                //transfer size - master
                logic [2:0] Hsize;

                //transfer type - master
                logic [1:0] Htrans;

                logic Hreadyin;
                //transfer done indicator - Slave
                logic Hreadyout;
                logic [31:0] Haddr;

                //burst type - master
                logic [2:0] Hburst;

                //transfer response - Slave
                logic [1:0] Hresp;

                //write data bus - master
                logic [31:0] Hwdata;

                //read data bus - slave
                logic [31:0] Hrdata;



        //AHB DRIVER clocking block:
        clocking ahb_drv_cb@(posedge clock);
                default input #1 output #1;
                                output Hwrite;
                                output Hreadyin;
								output Hwdata;
                                output Haddr;
                                output Htrans;
                                output Hburst;
                                output Hresetn;
                                output Hsize;
                                input Hreadyout;
        endclocking

        //AHB MONITOR clocking block:
                clocking ahb_mon_cb@(posedge clock);
                default input #1 output #1;
                                input Hwrite;
                                input Hreadyin;
                                input Hwdata;
                                input Haddr;
                                input Htrans;
                                input Hburst;
                                input Hresetn;
                                input Hsize;
                                input Hreadyout;
        endclocking

        //DRIVER and monitor modport:
        modport AHB_DRV_MP (clocking ahb_drv_cb);
        modport AHB_MON_MP (clocking ahb_mon_cb);


endinterface : ahb_if
