interface apb_if (input bit clock);

        logic Penable, Pwrite; //APB strobe, APB transfer direction - master

        //APB read data bus - slave
        logic [31:0] Prdata;

        //APB write data bus - master
        logic [31:0] Pwdata;

        //APB addr bus - master
        logic [31:0] Paddr;

        //APB select - master
        logic [3:0] Pselx;

        //APB Driver
        clocking apb_drv_cb @(posedge clock);
                default input #1 output #1;
                output Prdata;
                input Penable;
                input Pwrite;
                input Pselx; //doubt
        endclocking

        //APB monitor
        clocking apb_mon_cb @(posedge clock);
                default input #1 output #1;
                input Prdata;
                input Penable;
                input Pwrite;
                input Pselx;
                input Paddr;
                input Pwdata;
        endclocking
	//DRIVER and monitor modport:
    modport APB_DRV_MP (clocking apb_drv_cb);
    modport APB_MON_MP (clocking apb_mon_cb);

endinterface: apb_if
