class ahb_xtns extends uvm_sequence_item;

        `uvm_object_utils(ahb_xtns)

        //Inputs or outputs:
        logic Hclk, Hresetn;
        rand logic Hwrite; //clk,reset,transfer direction - master

        //transfer size - master
        rand logic [2:0] Hsize;

        //transfer type - master
        rand logic [1:0] Htrans;

        //logic Hreadyin;
        //transfer done indicator - Slave
        //logic Hreadyout;
        rand logic [31:0] Haddr;

        //burst type - master
        rand logic [2:0] Hburst;

        //transfer response - Slave
        //logic [1:0] Hresp;

        //write data bus - master
        rand logic [31:0] Hwdata;

        //read data bus - slave
        logic [31:0] Hrdata; //o/p so not random

                //unspecified length
                rand logic [7:0] length;

                constraint valid_size {Hsize inside {[0:2]};} //since Hrdata and Hwdata are 32 bits wide
				//2^0=1 byte of Hwdata, 2^1=2 bytes, 2^2=4 bytes of data

                constraint valid_length {(2**Hsize) * length <= 1024;}

                constraint valid_haddr {Hsize == 1 -> Haddr % 2 == 0;
                                                                Hsize == 2 -> Haddr % 2 == 0;}

                constraint valid_haddr1 {Haddr inside {[32'h8000_0000 : 32'h8000_03ff],
                                               [32'h8400_0000 : 32'h8400_03ff],
                                               [32'h8800_0000 : 32'h8800_03ff],
                                               [32'h8c00_0000 : 32'h8c00_03ff]};}
        extern function void do_print(uvm_printer printer);

endclass

function void ahb_xtns::do_print(uvm_printer printer);
        super.do_print(printer);

        printer.print_field("Haddr", this.Haddr, 32, UVM_HEX);
        printer.print_field("Hwdata", this.Hwdata, 32, UVM_HEX);
//      printer.print_field("Hreadyin", this.Hreadyin, 1, UVM_DEC);
        printer.print_field("Hwrite", this.Hwrite, 1, UVM_DEC);
        printer.print_field("Htrans", this.Htrans, 2, UVM_DEC);
//      printer.print_field("Hburst", this.Hburst, 3, UVM_DEC);
endfunction
