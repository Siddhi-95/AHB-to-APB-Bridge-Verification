class apb_xtn extends uvm_sequence_item;

        `uvm_object_utils(apb_xtn)

        logic Penable, Pwrite; //APB strobe, APB transfer direction - master

        //APB read data bus - slave
        rand logic [31:0] Prdata;

        //APB write data bus - master
        logic [31:0] Pwdata;

        //APB addr bus - master
        logic [31:0] Paddr;

        //APB select - master
        logic [3:0] Pselx;

	constraint Pselx_count { Pselx dist { 4'b0001:=4, 4'b0010:=4, 4'b0100:=4, 4'b1000:=4  } ;}

        extern function void do_print(uvm_printer printer);
endclass

function void apb_xtn::do_print(uvm_printer printer);

        super.do_print(printer);
        printer.print_field("Paddr", this.Paddr, 32, UVM_HEX);
        printer.print_field("Penable", this.Penable, 1, UVM_DEC);
        printer.print_field("Pwrite", this.Pwrite, 1, UVM_DEC);
        printer.print_field("Pselx", this.Pselx, 4, UVM_DEC);
        printer.print_field("Prdata", this.Prdata, 32, UVM_HEX);
	printer.print_field("Pwdata", this.Pwdata, 32, UVM_HEX);

endfunction

