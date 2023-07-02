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


property only_one_bit_high_Psel;
        @(posedge clock)  (Pselx == 4'b0000 || Pselx == 4'b1000 || Pselx == 4'b0100 || Pselx == 4'b0010 || Pselx == 4'b0001);
            
 //       @(posedge clock) $onehot0(Pselx);

endproperty;

ONLY_ONE_BIT_HIGH_PSEL: assert property (only_one_bit_high_Psel);
       
property penable_high_for_one_cycle;
	@(posedge clock) Penable[->1] |=> !(Penable);
endproperty

      PENABLE_HIGH: assert property (penable_high_for_one_cycle);

property after_addr_change_penable_high;
	@(posedge clock) 1'b1 ##1 $changed(Paddr) |=> Penable[->1] ##1 !(Penable);
endproperty

     ADDR_CHANGE_PENABLE_HIGH: assert property (after_addr_change_penable_high);


        //APB Driver
        clocking apb_drv_cb @(posedge clock);
                default input #1 output #1;
                output Prdata;
                input Penable;
                input Pwrite;
                input Pselx; 
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
    modport APB_DR_MP (clocking apb_drv_cb);
    modport APB_MON_MP (clocking apb_mon_cb);

endinterface: apb_if
