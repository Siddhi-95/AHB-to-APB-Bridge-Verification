class ahb_xtn extends uvm_sequence_item;

        `uvm_object_utils(ahb_xtn)

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

	constraint Hsize_count {Hsize dist { 3'b000:=3, 3'b001:=3, 3'b010:=3     } ;}

        constraint valid_length {(2**Hsize) * length <= 1024;} //length should not cross 1Kb

        constraint valid_haddr {Hsize == 1 -> Haddr % 2 == 0;
                                Hsize == 2 -> Haddr % 4 == 0;} // address should always be even

        constraint valid_haddr1 {Haddr inside {[32'h8000_0000 : 32'h8000_03ff],
                                               [32'h8400_0000 : 32'h8400_03ff],
                                               [32'h8800_0000 : 32'h8800_03ff],
                                               [32'h8c00_0000 : 32'h8c00_03ff]};} // 4 slaves
        extern function void do_print(uvm_printer printer);

endclass

function void ahb_xtn::do_print(uvm_printer printer);
        super.do_print(printer);

        printer.print_field("Haddr", this.Haddr, 32, UVM_HEX);
        printer.print_field("Hwdata", this.Hwdata, 32, UVM_HEX);
        printer.print_field("Hwrite", this.Hwrite, 1, UVM_DEC);
        printer.print_field("Htrans", this.Htrans, 2, UVM_DEC);
	printer.print_field("Hsize", this.Hsize, 2, UVM_DEC);
	printer.print_field("Hburst", this.Hburst, 3, UVM_HEX);
	printer.print_field("Hrdata", this.Hrdata, 32, UVM_HEX);

endfunction
