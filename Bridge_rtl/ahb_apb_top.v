// Include definitions
`include "definitions.v"
   module rtl_top (input  Hclk,
                   input  Hresetn,
                   input  [1:0] Htrans,
                   input        [2:0]Hsize,
                   input        Hreadyin,
                   input        [`WIDTH-1:0]Hwdata,
                   input        [`WIDTH-1:0]Haddr,
                   input                Hwrite,
                   input        [`WIDTH-1:0]Prdata,
                   output       [`WIDTH-1:0]Hrdata,
                   output       [1:0]Hresp,
                   output       Hreadyout,
                   output       [`SLAVES-1:0]Pselx,
                   output       Pwrite,
                   output       Penable,
                   output  [`WIDTH-1:0] Paddr,
                   output  [`WIDTH-1:0] Pwdata
                    ) ;

       wire     valid,Pwrite_wire,Penable_wire,Hreadyout_wire;
       wire     [`WIDTH-1 : 0]  Pwdata_wire, Paddr_wire, Prdata_wire,inc_address,Haddr_reg_d1,Haddr_reg_d2,Haddr_reg_d3;
       wire     [`SLAVES-1 : 0] Pselx_out, Pselx_wire;
       wire     [`WIDTH-1:0] config_data;

      ahb AHB_SLAVE(Hclk,
                   Hresetn,
                   Htrans,
                   Hsize,
                   Hreadyin,
                   Hwdata,
                   Haddr,
                   Hwrite,
                   Hreadyout_wire,
                   Penable_wire,
                   Hresp,
                   Hreadyout,
                   Pselx_out,
                   valid,
                   config_data,
                   inc_address,Haddr_reg_d1,Haddr_reg_d2,Haddr_reg_d3) ;

     apb_controller FSM(Hclk,
                        Hresetn,
                        valid,
                        Hwrite,
                        Pselx_out[0],
                        Pselx_out[1],
                        Pselx_out[2],
                        Pselx_out[3],
                        Haddr_reg_d1,Haddr_reg_d2,Haddr_reg_d3,inc_address,
                        Htrans,
                        Hsize,
                        Hwdata,
                        Prdata_wire,
                        config_data,
                        Penable_wire,
                        Pwrite_wire,
                        Pselx_wire,
                        Paddr_wire,
                        Hreadyout_wire,
                        Pwdata_wire,
                        Hrdata);

    apb APB_MASTER(    Paddr_wire,
                       Penable_wire,
                       Pwrite_wire,
                       Pwdata_wire,
                       Pselx_wire,
                       Prdata,
                       Paddr,
                       Pwrite,
                       Penable,
                       Pwdata,
                       Pselx,
                       Prdata_wire );


 endmodule
