*********************************************************************************************/

  // Include definitions
   `include "definitions.v"

      //This module represents a controller that controls the generation of APB output signals .
      module apb_controller (input Hclk,Hresetn,valid,Hwrite,
                             input flag_timer,flag_interruptc,flag_remap_pause_controller,flag_slave4,
                             input [`WIDTH-1:0]Haddr_reg_d1,Haddr_reg_d2,Haddr_reg_d3,inc_address,
                             input [1:0] Htrans,
                             input [2:0] Hsize,
                             input [`WIDTH-1:0]Hwdata,
                             input [`WIDTH-1:0]Prdata,
                             input [`WIDTH-1:0]config_reg_data,
                             output reg Penable,Pwrite,
                             output reg [`SLAVES-1:0]Pselx,
                             output reg [`WIDTH-1:0]Paddr,
                             output  reg Hreadyout,
                             output  reg [`WIDTH-1:0]Pwdata,Hrdata);


              //One hot encoding
              reg [7:0]pre_state,next_state,pre_state_reg,pre_state_reg_d1;

              //FSM States
              parameter ST_IDLE    =  8'b0000_0001,
                        ST_READ    =  8'b0000_0010,
                        ST_RENABLE =  8'b0000_0100,
                        ST_WWAIT   =  8'b0000_1000,
                        ST_WRITE   =  8'b0001_0000,
                        ST_WENABLE =  8'b0010_0000,
                        ST_WRITEP  =  8'b0100_0000,
                        ST_WENABLEP  =  8'b1000_0000;



                //Internal signals
                reg Hwritereg,Hwrite_reg_d2,Hwrite_reg_d3,Hwrite_reg_d4,Hwrite_reg_d5,Hwrite_reg_d6;
                reg start_count_flag;
                reg [3:0] no_of_trans;
                reg [3:0] trans_counter;
                reg [1:0] Htrans_reg;
                //reg [2:0] Hburst_reg;
                reg [2:0] Hsize_reg ;
                reg [2:0] Hsize_reg_d2;
                reg [2:0] Hsize_reg_d3;
                reg [2:0] Hsize_reg_d4;
                reg [2:0] Hsize_reg_d5;
                integer count ;
                reg [`WIDTH-1:0]Hwdata_reg_d1;  //Delayed by one cycle
                reg [`WIDTH-1:0]Hwdata_reg_d2;  //Delayed by two cycle
                //Flags for de-selecting a slave
                reg de_select_slave,de_select_slave_1,de_select_slave_2 ;
                //Counter logic for holding values
                reg count_write,count_read,count_read_d2,count_write_d2,count_write_d3,
                    count_write_d4,count_write_wait,count_write_wait_d2,count_write_wait_d3,
                    count_write_wait_d4;
                reg Hreadynxt;



        //Generation of Hwritereg and registering of data and address

         always@(posedge Hclk,negedge Hresetn)
            begin
             if(~Hresetn)
                begin
                 Hwritereg  <= 0 ;
                 Hwrite_reg_d2 <= 0;
                 Hwrite_reg_d3 <= 0;
                 Hwrite_reg_d4 <= 0;
                 Hwrite_reg_d5 <= 0;
                 Hwrite_reg_d6 <= 0;
                 Htrans_reg <= 0;
                 Hsize_reg  <= 0;
                 Hsize_reg_d2 <= 0;
                 Hsize_reg_d3 <= 0;
                 Hsize_reg_d4 <= 0;
                 Hsize_reg_d5 <= 0;
                 count_write_d2 <= 0;
                 count_write_d3 <= 0;
                 count_write_d4 <= 0;
                 count_read_d2 <=  0;
                 count_write_wait_d2 <= 0;
                 count_write_wait_d3 <= 0;
                 count_write_wait_d4 <= 0;

              end
             else
                begin
                 Hwritereg  <= Hwrite ;
                 Hwrite_reg_d2 <= Hwritereg;
                 Hwrite_reg_d3 <= Hwrite_reg_d2;
                 Hwrite_reg_d4 <= Hwrite_reg_d3;
                 Hwrite_reg_d5 <= Hwrite_reg_d4;
                 Hwrite_reg_d6 <= Hwrite_reg_d5;
                 Htrans_reg <= Htrans;
                 Hsize_reg  <= Hsize;
                 Hsize_reg_d2 <= Hsize_reg;
                 Hsize_reg_d3 <= Hsize_reg_d2;
                 Hsize_reg_d4 <= Hsize_reg_d3;
                 Hsize_reg_d5 <= Hsize_reg_d4;
                 count_write_d2 <= count_write;
                 count_write_d3 <= count_write_d2;
                 count_write_d4 <= count_write_d3;
                 count_read_d2 <=  count_read;
                 count_write_wait_d2 <= count_write_wait;
                 count_write_wait_d3 <= count_write_wait_d2;
                 count_write_wait_d4 <= count_write_wait_d3;
               end
            end


            always@(posedge Hclk,negedge Hresetn)
              begin
               if(~Hresetn)
                begin
                  Hwdata_reg_d1 <= 0;
                  Hwdata_reg_d2 <= 0;
                end
               else
                begin
                 Hwdata_reg_d1 <= Hwdata ;
                 Hwdata_reg_d2 <= Hwdata_reg_d1;
                end
              end

         //Present state logic
            always@(posedge Hclk,negedge Hresetn)
              begin
               if(~Hresetn)
                 begin
                  pre_state <= ST_IDLE ;
                  pre_state_reg <= 0 ;
                  pre_state_reg_d1 <= 0;
                  Hreadyout <= 1;
                 end
               else
                 begin
                      pre_state <= next_state ;
                      pre_state_reg <= pre_state ;
                      pre_state_reg_d1 <= pre_state_reg;
                      Hreadyout <= Hreadynxt;
                 end
             end

           //Logic for de_selecting a slave

            always@Paddr
             begin
              if(Paddr <= 8)
                begin
                  de_select_slave = 1;
                end
              else
                  de_select_slave = 0;
             end

           always@(posedge Hclk)
            begin
             de_select_slave_1 <= de_select_slave;
             de_select_slave_2 <= de_select_slave_1;
            end

            always@(posedge Hclk,negedge Hresetn)
              begin
               if(~Hresetn)
                 begin
                       pre_state_reg <= 0 ;
                 end
               else
                 begin
                       pre_state_reg <= pre_state ;
                 end
             end

       always@(posedge Hclk,negedge Hresetn)
         begin
          if(~Hresetn)
            count_write <= 0;

          else if(valid & (pre_state == ST_IDLE) & Hwrite)
            count_write <= count_write + 1;
          else
            count_write <= 0;
         end
       always@(posedge Hclk,negedge Hresetn)
         begin
          if(~Hresetn)
            count_read <= 0;
          else if(valid & (pre_state == ST_IDLE) & ~Hwrite)
            count_read <= count_read + 1;
          else
            count_read <= 0;
         end
       always@(posedge Hclk,negedge Hresetn)
         begin
          if(~Hresetn)
            count_write_wait <= 0;
          else if(valid & (pre_state == ST_RENABLE) & Hwrite)
            count_write_wait <= count_write_wait + 1;
          else
            count_write_wait <= 0;
         end

        //Task for Implementing the little Endianess on HWDATA
                      task Endianess(input [2:0]Hsize_t,input [31:0]Hwdata,input [1:0]addr);
                        begin
                        case(Hsize_t)
                         3'b000:         begin
                                            case(addr)
                                               `ADDR_OFFSET_BYTE_0:begin $display($time,"BYTE0_endian1");Pwdata = Hwdata[7:0];end
                                               `ADDR_OFFSET_BYTE_1:begin $display($time,"BYTE1_endian1");Pwdata = Hwdata[15:8];end
                                               `ADDR_OFFSET_BYTE_2:begin $display($time,"BYTE2_endian1");Pwdata = Hwdata[23:16];end
                                               `ADDR_OFFSET_BYTE_3:begin $display($time,"BYTE3_endian1");Pwdata = Hwdata[31:24];end
                                                default           :Pwdata = 0;
                                            endcase
                                         end
                         3'b001:          begin
                                            case(addr)
                                               `ADDR_OFFSET_HFWORD_0:Pwdata = Hwdata[15:0];
                                               `ADDR_OFFSET_HFWORD_2:Pwdata = Hwdata[31:16];
                                                default             :Pwdata = 0;
                                            endcase
                                          end
                         3'b010:          begin
                                            case(addr)
                                               `ADDR_OFFSET_WORD  :Pwdata = Hwdata;
                                                default           :Pwdata = 0;
                                            endcase
                                          end
                        default: Pwdata = 0;
                       endcase
                      end
                    endtask


           `ifndef WRAPPING_INCR
           always@(*)
             begin
               $display($time," ENTERED:&&");
               if(~Hresetn) Pwdata = 0;
               else
                 begin
                    Pwdata = Pwdata ;
                  case(pre_state)
                    ST_IDLE,ST_WWAIT,ST_WENABLEP,ST_READ,ST_RENABLE : Pwdata = Pwdata;
                    ST_WRITEP        : Endianess(Hsize_reg_d2,Hwdata_reg_d1,Paddr[1:0]);
                    ST_WRITE         : Endianess(Hsize_reg_d2,Hwdata_reg_d1,Paddr[1:0]);
                  endcase
                 end
            end
           `else
               always@(*)
                  begin
                    if(~Hresetn) Pwdata = 0;
                     else
                       begin
                           case(pre_state)
                            ST_IDLE,ST_WWAIT,ST_WENABLEP: Pwdata = Pwdata;
                            ST_WRITE         : begin    Endianess(Hsize_reg_d4,Hwdata_reg_d1,Paddr[1:0]) ;end
                            ST_WRITEP        : begin
                                                   if(count_write_d2)
                                                       Endianess(Hsize_reg_d2,Hwdata_reg_d1,Paddr[1:0]);
                                                   else
                                                       Endianess(Hsize_reg_d4,Hwdata_reg_d2,Paddr[1:0]);
                                               end
                            default          : Pwdata = Pwdata ;
                          endcase
                       end
                  end
             `endif

          `ifndef WRAPPING_INCR
             //Output logic for Paddr logic
           always@(*)
             begin
               if(~Hresetn)
                Paddr = 0;
               else
                        begin
                        Paddr = Paddr ;
                        case(pre_state)
                        ST_IDLE  : begin
                                    Paddr = Paddr ;
                                   end
                        ST_WWAIT : begin
                                     Paddr = Paddr ;
                                   end
                        ST_WRITEP :  begin
                                      Paddr = Haddr_reg_d1;
                                     end
                        ST_WENABLEP :begin
                                      Paddr = Paddr;
                                     end
                        ST_WRITE :   Paddr = Haddr_reg_d1;
                        ST_WENABLE : Paddr = Paddr;
                        ST_READ :    begin
                                      if(pre_state_reg == ST_IDLE)
                                          Paddr = inc_address;
                                      else
                                          Paddr = Haddr_reg_d2;
                                     end
                        ST_RENABLE : Paddr = Paddr ;
                        endcase
                       end
              end
             `else
                 always@(*)
                  begin
                   if(~Hresetn)
                     Paddr = 0;
                  else
                      begin
                       if(count_read & ~Hwrite)
                           begin
                            Paddr = inc_address;
                           end
                       else if(count_write_d2)
                           begin
                            Paddr = Haddr_reg_d1;
                           end
                       else
                         begin
                          Paddr = Paddr;
                          case(pre_state)
                           ST_WWAIT : begin
                                        Paddr = Paddr;
                                      end
                           ST_WRITEP : begin
                                         Paddr = Haddr_reg_d2;
                                       end
                           ST_WENABLEP :begin
                                         Paddr = Paddr;
                                        end
                           ST_WRITE    : begin
                                          Paddr = Haddr_reg_d2;
                                         end
                           ST_WENABLE  : Paddr = Paddr;
                           ST_READ     : begin
                                          Paddr = inc_address;
                                         end
                           ST_RENABLE :   Paddr = Paddr ;
                         endcase
                       end
                  end
                end
          `endif


        //Task for Implementing the little Endianess on PRDATA

                 task Endianess_read(input [2:0]Hsize_t,input [31:0]Hwdata,input [1:0]addr);
                        begin
                        case(Hsize_t)
                         3'b000:         begin
                                            case(addr)
                                               `ADDR_OFFSET_BYTE_0:begin Hrdata = Prdata[7:0]; end
                                               `ADDR_OFFSET_BYTE_1:begin Hrdata = Prdata[15:8];end
                                               `ADDR_OFFSET_BYTE_2:begin Hrdata = Prdata[23:16];end
                                               `ADDR_OFFSET_BYTE_3:begin Hrdata = Prdata[31:24];end
                                                default           :Hrdata = 0;
                                            endcase
                                         end
                         3'b001:          begin
                                            case(addr)
                                               `ADDR_OFFSET_HFWORD_0:Hrdata = Prdata[15:0];
                                               `ADDR_OFFSET_HFWORD_2:Hrdata = Prdata[31:16];
                                                default             :Hrdata = 0;
                                            endcase
                                          end
                         3'b010:          begin
                                            case(addr)
                                               `ADDR_OFFSET_WORD  :Hrdata = Prdata;
                                                default           :Hrdata = 0;
                                            endcase
                                          end
                        default: Hrdata = 0;
                       endcase
                      end
                    endtask


     //Output logic for Hrdata
         `ifndef WRAPPING_INCR
           always@(*)
             begin
                  case(pre_state)
                    ST_IDLE,ST_WWAIT,ST_WENABLEP,ST_READ: Hrdata = 0;
                    ST_RENABLE        : begin
                                            if(count_read_d2)Endianess_read(Hsize_reg_d2,Prdata,Paddr[1:0]);
                                            else Endianess_read(Hsize_reg_d3,Prdata,Paddr[1:0]);
                                        end

                  endcase
            end
           `else
               always@(*)
                  begin
                           case(pre_state)
                            ST_RENABLE        : begin
                                                 if(count_read_d2)Endianess_read(Hsize_reg_d2,Prdata,Paddr[1:0]);
                                                 else
                                                  Endianess_read(Hsize_reg_d4,Prdata,Paddr[1:0]);
                                                end
                            default           : Hrdata = 0;
                          endcase
                  end
             `endif



        //Next state logic
          always@*
            begin
              next_state = pre_state ; //Default assignment
              Hreadynxt = 1;
              case(pre_state)
               ST_IDLE : begin
                              if(valid)
                                begin
                                 if(Hwrite)
                                  begin
                                        next_state = ST_WWAIT ;
                                        Hreadynxt  = 1;
                                  end
                                else
                                  begin
                                   Hreadynxt = 0;
                                   next_state = ST_READ;
                                  end
                                end
                             else
                                  begin
                                   next_state = ST_IDLE ;
                                  end
                          end
               ST_READ  :
                        begin
                          Hreadynxt = 1;
                          next_state = ST_RENABLE ;
                        end

              ST_RENABLE: begin
                                 if(valid)
                                   begin
                                      if(Hwrite)
                                        begin
                                         Hreadynxt = 1;
                                         next_state = ST_WWAIT ;
                                        end
                                      else
                                        begin
                                         next_state = ST_READ;
                                         Hreadynxt  = 0;
                                        end
                                  end
                                 else
                                       begin
                                        next_state = ST_IDLE ;
                                        Hreadynxt  = 0;
                                       end
                          end
                ST_WENABLE :
                                begin
                                   Hreadynxt = 0;
                                   next_state = ST_IDLE;
                                 if(valid & ~Hwrite)
                                   next_state = ST_READ;
                                  else if(valid & Hwrite)
                                   next_state = ST_WWAIT;
                               end
               ST_WRITE :       begin
                                   Hreadynxt = 0;
                                   if(~valid | Hwrite)
                                     next_state = ST_WENABLE ;
                                   else
                                     next_state = ST_WENABLEP;
                              end

               ST_WENABLEP : begin
                                     Hreadynxt = 0;
                                 if(~Hwrite_reg_d2)
                                    begin
                                     next_state  = ST_READ;
                                    end
                                 else
                                   begin
                                    if(valid)
                                     next_state = ST_WRITEP;
                                    else
                                     begin
                                      next_state = ST_WRITE;
                                     end
                                  end
                              end
             ST_WRITEP  :
                           begin
                                if(Hwritereg)Hreadynxt = 1;
                                else Hreadynxt = 0;
                                next_state = ST_WENABLEP ;
                           end
             ST_WWAIT   :
                         begin
                                  begin
                                     Hreadynxt = 0;
                                   if(valid)
                                    begin
                                      next_state = ST_WRITEP;
                                      Hreadynxt = 0;
                                    end
                                   else if(~valid)
                                    begin
                                     next_state = ST_WRITE;
                                     Hreadynxt  = 0;
                                    end
                                   else
                                    next_state = ST_WWAIT;
                                  end
                         end
          endcase
        end


     //Output logic for APB
     always@(*)
         begin
           if(~Hresetn)
            {Penable,Pselx,Pwrite} = 0;
           else if(de_select_slave)
             Pselx = 0;
           else
            begin
              case(pre_state)
                ST_IDLE : begin
                              {Penable,Pselx} = 0;
                               Pwrite         = 0; //Holding the previous values
                          end
                ST_READ :begin
                             Pwrite = 0; //Pwrite is made active low
                            {Penable,Pselx} = {1'b0,1'b0};
                            if(flag_timer)
                             Pselx[0] = 1;
                            else if(flag_interruptc)
                             Pselx[1] = 1;
                            else if(flag_remap_pause_controller)
                             Pselx[2] = 1;
                            else if(flag_slave4)
                             Pselx[3] = 1;
                         end
               ST_RENABLE : begin
                              Penable   = 1;
                              Pwrite    = Pwrite;    //Hold the previous values
                            if(flag_timer)
                             Pselx[0] = 1;
                            else if(flag_interruptc)
                             Pselx[1] = 1;
                            else if(flag_remap_pause_controller)
                             Pselx[2] = 1;
                            else if(flag_slave4)
                             Pselx[3] = 1;
                            end

               ST_WWAIT   :begin
                              Penable  = 0;
                              Pwrite   = 0;
                              if(flag_timer)
                               Pselx[0] = 1;
                             else if(flag_interruptc)
                               Pselx[1] = 1;
                             else if(flag_remap_pause_controller)
                               Pselx[2] = 1;
                            else if(flag_slave4)
                               Pselx[3] = 1;
                           end
               ST_WRITE   :begin
                               Pwrite = 1;
                               Penable = 0;
                               Pselx = 0;
                            if(flag_timer)
                             Pselx[0] = 1;
                            else if(flag_interruptc)
                             Pselx[1] = 1;
                            else if(flag_remap_pause_controller)
                             Pselx[2] = 1;
                            else if(flag_slave4)
                             Pselx[3] = 1;
                           end
               ST_WENABLE  : begin
                              Penable = 1;
                              Pwrite  = Pwrite;  //Hold the previous values
                              if(flag_timer)
                               Pselx[0] = 1;
                              else if(flag_interruptc)
                               Pselx[1] = 1;
                              else if(flag_remap_pause_controller)
                               Pselx[2] = 1;
                              else if(flag_slave4)
                               Pselx[3] = 1;
                             end
               ST_WRITEP   :begin
                                Pwrite = 1;
                                Penable = 0;
                                if(flag_timer)
                                 Pselx[0] = 1;
                                else if(flag_interruptc)
                                 Pselx[1] = 1;
                                else if(flag_remap_pause_controller)
                                 Pselx[2] = 1;
                                else if(flag_slave4)
                                 Pselx[3] = 1;
                            end
              ST_WENABLEP  : begin
                               Penable = 1;
                               Pwrite  = Pwrite;  //Hold the previous values
                                if(flag_timer)
                                 Pselx[0] = 1;
                                else if(flag_interruptc)
                                 Pselx[1] = 1;
                                else if(flag_remap_pause_controller)
                                 Pselx[2] = 1;
                                else if(flag_slave4)
                                 Pselx[3] = 1;
                             end

              default      :  begin
                               Penable =  Penable; //Hold the previous values
                               Pwrite  =  Pwrite;  //Hold the previous values
                               Pselx   =  0;  //Hold the previous values
                              end
              endcase
             end
          end

        endmodule

