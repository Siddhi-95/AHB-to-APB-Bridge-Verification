module top;

        //Import packages:
        import ahb_apb_bridge_pkg::*;
        import uvm_pkg::*;

        //Generate clock signal:
        bit clock;

        initial
                begin
                        clock = 1'b0;
                        forever #10 clock = ~clock;
                end

        //interface instantiation
        ahb_if in0(clock);
        apb_if in1(clock);

        rtl_top DUT(
            .Hclk(clock),
            .Hresetn(in0.Hresetn),
            .Htrans(in0.Htrans),
            .Hsize(in0.Hsize),
            .Hreadyin(in0.Hreadyin),
            .Hwdata(in0.Hwdata),
            .Haddr(in0.Haddr),
            .Hwrite(in0.Hwrite),
            .Hrdata(in0.Hrdata),
            .Hresp(in0.Hresp),
            .Hreadyout(in0.Hreadyout),
            .Pselx(in1.Pselx),
            .Pwrite(in1.Pwrite),
            .Penable(in1.Penable),
	    .Prdata(in1.Prdata),
            .Paddr(in1.Paddr),
	    .Pwdata(in1.Pwdata)
            ) ;

                initial
                        begin
                                uvm_config_db #(virtual ahb_if)::set(null, "*", "ahb_vif", in0);
                                uvm_config_db #(virtual apb_if)::set(null, "*", "apb_vif", in1);


                                run_test();
                        end
endmodule

