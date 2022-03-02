*********************************************************************************************/

   // Include definitions
   `include "definitions.v"
     module ahb (
                input                           Hclk,  //Ports
                input                           Hresetn,
                input           [1:0]           Htrans,
                //input                 [2:0]           Hburst,
                input           [2:0]           Hsize,
                input                           Hreadyin,
                input           [`WIDTH-1:0]    Hwdata,
                input           [`WIDTH-1:0]    Haddr,
                input                           Hwrite,
                input                           Hreadyout_in,
                input                           enable,
                output          [1:0]           Hresp,
                output                          Hreadyout,
                output          [`SLAVES-1:0]   Pselx_out,
                output                          valid,
                output           [`WIDTH-1:0]   config_reg_data,
                output           reg [`WIDTH-1:0] inc_address,Haddr_reg_d1,Haddr_reg_d2,Haddr_reg_d3);

          //Internal signals
          reg   [`WIDTH-1:0] wait_time_config_reg; // address of this register is 'h0
          reg   [`WIDTH-1:0] slave1_address = 'h8000_0000; // address of this register is 'h1
          reg   [`WIDTH-1:0] slave2_address = 'h8400_0000; // address of this register is 'h3
          reg   [`WIDTH-1:0] slave3_address = 'h8800_0000; // address of this register is 'h5
          reg   [`WIDTH-1:0] slave4_address = 'h8c00_0000; // address of this register is 'h7
          reg   [`WIDTH-1:0] slave1_offset  =  'h0000_03ff; // address of this register is 'h2
          reg   [`WIDTH-1:0] slave2_offset  =  'h0000_03ff; // address of this register is 'h4
          reg   [`WIDTH-1:0] slave3_offset  =  'h0000_03ff; // address of this register is 'h6
          reg   [`WIDTH-1:0] slave4_offset  =  'h0000_03ff; // address of this register is 'h8
          reg   [`WIDTH-1:0] Hrdata_reg;
          reg   error_reg ;
          reg   [`WIDTH-1:0] Haddr_reg,Haddr_reg_2,Haddr_reg_3,Pwdata_out_im;
          reg   [2:0] pstate,nstate;
          reg   [1:0]pre_state,next_state;
          reg   config_mode, Hwrite_reg, Hwrite_reg_2;
          reg   time_out = 0;
          reg   [`WIDTH-1:0] wait_count = 0, Hrdata_reg_2;
          reg   invalid_len, read_reg, read_reg_3, read_reg_2;
          reg   [1:0] Hresp_count, Hresp_flag, Hresp_flag_im, Htrans_reg, Htrans_reg_2;
          reg   Hresp_Hreadyout,Hresp_Hreadyout_im,Hreadyout_reg,Hreadyout_reg_2,Hreadyin_reg,Hreadyin_reg_2 ;
          reg   [2:0] Hsize_reg,Hsize_reg_2;
          reg   Hreadyout_in_reg;
          reg   error;

          //FSM States
          parameter [2:0] IDLE = 3'b011,
                    CONFIG = 3'b100,
                    NORMAL = 3'b101;


        assign  Pselx_out[0]    =       (Haddr  >= slave1_address && (Haddr < slave1_address + slave1_offset)  ? 1 : 0);
        assign  Pselx_out[1]    =       (Haddr  >= slave2_address && (Haddr < slave2_address + slave2_offset)  ? 1 : 0);
        assign  Pselx_out[2]    =       (Haddr  >= slave3_address && (Haddr < slave3_address + slave3_offset)  ? 1 : 0);
        assign  Pselx_out[3]    =       (Haddr  >= slave4_address && (Haddr < slave4_address + slave4_offset)  ? 1 : 0);
        assign  Hreadyout       =  (Hresp == 0)?((Haddr >= 'h00 && Haddr<= 'h08 && Hwrite == 1) ? 1 : Hreadyout_in):(Hresp_Hreadyout ? 0 : 1);
        assign  valid           =  (Hresetn & Hreadyin & Hresp!=2'b10 & Htrans !=2'b01 & Htrans!=2'b00 &
                                   ((!(Haddr >=0 & Haddr <=8) & Hwrite == 1 ) || Hwrite == 0) )? 1'b1  : 1'b0;
        assign  Hresp           =  (Hresp_flag==2'b10) ? 2'b10 :  0;
        assign  config_reg_data =   Hrdata_reg ;

        always@(posedge Hclk,negedge Hresetn)
         begin
           if(!Hresetn)
            pre_state <= 2'b00;
          else
            pre_state <= next_state;
         end

        always@(posedge Hclk,negedge Hresetn)
           begin
            if(~Hresetn)
              {inc_address,Haddr_reg_d1,Haddr_reg_d2,Haddr_reg_d2,Haddr_reg_d3} <= 0;
            else
             begin
                  inc_address  <= Haddr;
                  Haddr_reg_d1 <= inc_address;
                  Haddr_reg_d2 <= Haddr_reg_d1;
                  Haddr_reg_d3 <= Haddr_reg_d2;

             end
           end


        always @(posedge Hclk,negedge Hresetn)
         begin
          if(!Hresetn)
           begin
            {Hresp_flag,Hresp_Hreadyout,Hrdata_reg} <= 0;
           end
          else
            begin
             Hresp_flag      <= Hresp_flag_im;
             Hresp_Hreadyout <= Hresp_Hreadyout_im;
             Hrdata_reg      <= (Hwrite_reg == 0 && Hresetn != 0 && Hreadyin_reg == 1)?
                                (Haddr_reg_3 == 'h00 ? wait_time_config_reg :
                                Haddr_reg_3 == 'h01 ? slave1_address :
                                Haddr_reg_3 == 'h03 ? slave2_address :
                                Haddr_reg_3 == 'h05 ? slave3_address :
                                Haddr_reg_3 == 'h07 ? slave4_address :
                                Haddr_reg_3 == 'h02 ? slave1_offset :
                                Haddr_reg_3 == 'h04 ? slave2_offset :
                                Haddr_reg_3 == 'h06 ? slave3_offset :slave4_offset) : 0;
           end
        end

        //ERROR LOGIC
        always @(posedge Hclk,negedge Hresetn)
        begin:BLOCK6
          if(~Hresetn)
            error <= 0;
          else
            begin:BLOCK5
             error <= 0;
              if(pre_state == 2'b00 & Htrans == 2'b11)
                begin:BLOCK4
                 if(!(Haddr >=0 && Haddr <=8))
                  begin :BLOCK1
                    error <= 0;
                    case(Hsize)
                     3'b001 : begin
                               if(Haddr[0] != 'h0)
                                begin
                                 $display($time,"Error due to ADDRESS ALIGNMENT HADDR[0] ################### ");
                                 error <= 1;
                                end
                              end
                     3'b010 : begin
                                if(Haddr[1:0] != 'h0)
                                begin
                                 $display($time,"Error due to ADDRESS ALIGNMENT HADDR[1:0]################### ");
                                 error <= 1;
                                end
                              end
                     3'b011 : begin
                               if(Haddr[2:0] != 'h0)
                                begin
                                 $display($time,"Error due to ADDRESS ALIGNMENT HADDR [2:0]################### ");
                                 error <= 1;
                                end
                              end
                    3'b100 : begin
                              if (Haddr[3:0] != 'h0)
                                begin
                                 $display($time,"Error due to ADDRESS ALIGNMENT HADDR [3:0]################### ");
                                 error <= 1;
                                end
                             end
                   3'b101 : begin
                             if (Haddr[4:0] != 'h0)
                                begin
                                 $display($time,"Error due to ADDRESS ALIGNMENT HADDR[4:0] ################### ");
                                 error <= 1;
                                end
                            end
                  3'b110 :  begin
                              if(Haddr[5:0] != 'h0)
                                begin
                                 $display($time,"Error due to ADDRESS ALIGNMENT HADDR[5:0] ################### ");
                                 error <= 1;
                                end
                            end
                3'b111 : begin
                          if(Haddr[6:0] != 'h0)
                                begin
                                 $display($time,"Error due to ADDRESS ALIGNMENT HADDR[6:0] ################### ");
                                 error <= 1;
                                end
                         end
                 endcase
               end
              if (Htrans == 2'b11 & Htrans_reg == 0)
                   begin:BLOCK2
                          begin
                           error <= 1;
                           $display($time,"Error due to sequence SEQ after IDLE &&&&&&&&&&&&&&&& ");
                          end
                   end
             else if (Htrans == 2'b11 & Htrans_reg == 2'b10)
                  begin:BLOCK3
                    if((Hsize != Hsize_reg)  || (Hwrite != Hwrite_reg))
                      begin
                         $display($time,"Error due to mismatch ***************** ",error);
                         error <= 1;
                      end
                 end

                if ((Htrans == 2'b10 || Htrans == 2'b11) && ((Hsize >= 3'b110 && `WIDTH < 512)
                                 || (Hsize >= 3'b101 && `WIDTH < 256 )
                                 || (Hsize >= 3'b100 && `WIDTH < 128 )
                                 || (Hsize >= 3'b011 && `WIDTH < 64 )
                                 || (Hsize >= 3'b010 && `WIDTH < 32 )))
                          error <= 1;
           end
        end
      end

     always @(pre_state,error)
      begin
          case(pre_state)
            2'B00: begin
                       if(error)
                         begin
                          next_state = 2'B01;
                          Hresp_flag_im = 2'b10;
                          Hresp_Hreadyout_im = 1;
                         end
                        else
                         begin
                          next_state = 2'B00;
                          Hresp_flag_im = 0;
                          Hresp_Hreadyout_im = 0;
                         end
                  end
           2'B01 : begin
                   $display("inside 2'B01 state", $time);
                   next_state = 2'B10;
                   Hresp_flag_im = 2'b10;
                   Hresp_Hreadyout_im = 0;
                 end
           default : begin
                        $display("inside DEFAULT state", $time);
                        next_state = 2'B00;
                        Hresp_flag_im = 0;
                        Hresp_Hreadyout_im = 0;
                     end
          endcase
       end
        //TIME OUT LOGIC
        always @(posedge Hclk, negedge Hresetn)
        begin
                if (!Hresetn)
                 begin
                  time_out <= 0;
                 end
                else if (Hreadyin)
                 begin
                   if(Htrans == 2'b01)
                      begin
                             wait_count <= wait_count+1;
                             if(wait_count == wait_time_config_reg)
                                time_out <= 1;
                             else
                                time_out <= 0;
                      end
                    else
                        begin
                         wait_count <= 0;
                         time_out <= 0;
                        end
                end
               else
                begin
                 time_out <= 0;
                 wait_count <= 0;
                end
        end

        always @(posedge Hclk, negedge Hresetn)
        begin
                if (!Hresetn)
                 begin
                  pstate <= IDLE;
                 end
                else
                 begin
                  pstate <= nstate;
                 end
        end
        always @( pstate, Hresetn, Hreadyin, Htrans, Hwrite, Hsize, Haddr, Hreadyout)
        begin
           case(pstate)
             IDLE :
               begin
                if (Htrans == 2'b00)
                begin
                  nstate = IDLE;
                end
                else if (Htrans == 2'b01 || Hreadyin == 0)
                begin
                  nstate = pstate;
                end
                else if ((Haddr == 'h01 || Haddr == 'h02 || Haddr == 'h03 || Haddr == 'h04 || Haddr == 'h05 || Haddr == 'h06
                          || Haddr == 'h07 || Haddr == 'h08 ||
                          Haddr == 'h00))
                          begin
                                if(Hwrite)
                                 begin
                                  nstate = CONFIG;
                                  read_reg = 0;
                                 end
                                else
                                 begin
                                  nstate = NORMAL;
                                  read_reg = 1;
                                 end
                         end
                else
                                begin
                                   nstate = NORMAL;
                                  if (Hwrite)
                                        begin
                                        read_reg = 0;
                                        end
                                  else
                                        begin
                                        read_reg = 0;
                                        end
                                end


                end
        CONFIG :
                begin
                if (Htrans == 2'b00)
                begin
                        nstate = IDLE;
                end
                else if (Htrans == 2'b01 || Hreadyin == 0)
                begin
                        nstate = pstate;
                end
                else if (Haddr == 'h01 || Haddr == 'h02 || Haddr == 'h03 || Haddr == 'h04 || Haddr == 'h05 || Haddr == 'h06
                         || Haddr == 'h07 || Haddr == 'h08 || Haddr == 'h00)
                                begin
                                        if (Hwrite)
                                                begin
                                                nstate = CONFIG;
                                                read_reg = 0;
                                                end
                                        else
                                                begin
                                                nstate = NORMAL;
                                                read_reg = 1;
                                                end
                                end
                else
                        begin
                          nstate = NORMAL;
                           if(Hwrite)
                            begin
                             read_reg = 0;
                            end
                           else
                             begin
                              read_reg = 0;
                             end
                        end
                 //CONFIGURATION OF REGISTERS
                     if(Hwrite_reg == 1 && Hresp == 2'b00)
                      begin
                        if (Haddr_reg == 'h01)
                        begin
                        slave1_address = Hwdata;
                        end
                        else if(Haddr_reg == 'h02)
                        begin
                        slave1_offset = Hwdata;
                        end
                        else if(Haddr_reg == 'h03)
                        begin
                        slave2_address = Hwdata;
                        end
                        else if(Haddr_reg == 'h04)
                        begin
                        slave2_offset = Hwdata;
                        end
                        else if(Haddr_reg == 'h05)
                        begin
                        slave3_address = Hwdata;
                        end
                        else if(Haddr_reg == 'h06)
                        begin
                        slave3_offset = Hwdata;
                        end
                        else if(Haddr_reg == 'h07)
                        begin
                        slave4_address = Hwdata;
                        end
                        else if (Haddr_reg == 'h08)
                        begin
                        slave4_offset = Hwdata;
                        end
                        else if (Haddr_reg == 'h00)
                        begin
                        wait_time_config_reg = Hwdata;
                        end
                     end
                     else
                        begin
                                slave1_address = slave1_address;
                                slave2_address = slave2_address;
                                slave3_address = slave3_address;
                                slave4_address = slave4_address;
                                slave1_offset = slave1_offset;
                                slave2_offset = slave2_offset;
                                slave3_offset = slave3_offset;
                                slave4_offset = slave4_offset;
                                wait_time_config_reg = wait_time_config_reg;
                        end
                end

        NORMAL :
                begin
                 if (Htrans == 2'b00)
                   begin
                    nstate = IDLE;
                   end
                else if (Htrans == 2'b01 || Hreadyin == 0)
                  begin
                   nstate = pstate;
                  end
                if (Haddr == 'h01 || Haddr == 'h02 || Haddr == 'h03 || Haddr == 'h04 || Haddr == 'h05 || Haddr == 'h06
                   || Haddr == 'h07 || Haddr == 'h08 || Haddr == 'h00)
                        begin
                                if (Hwrite)
                                begin
                                nstate = CONFIG;
                                read_reg = 0;
                                end
                                else
                                begin
                                nstate = NORMAL;
                                read_reg = 1;
                                end
                        end
                else
                  begin
                        nstate = NORMAL;
                        if (Hwrite)
                         begin
                          read_reg = 0;
                         end
                        else
                         begin
                          read_reg = 0;
                         end
                  end
                end
        default:
                begin
                        nstate = IDLE;
                        read_reg = 0;
                end
        endcase
end

   always@(posedge Hclk,negedge Hresetn)
     begin
        if(~Hresetn)
         begin
                read_reg_2 <= 0;
                read_reg_3 <= 0;
                Haddr_reg <=  0;
                Htrans_reg <= 0;
                Hsize_reg <=  0;
        //      Hburst_reg <= 0;
                Hwrite_reg <= 0;
                Hreadyout_reg <= 0;
                Hreadyin_reg <= 0;
                Hrdata_reg_2 <= 0;
                Haddr_reg_2 <= 0;
                Htrans_reg_2 <=0;
                Hsize_reg_2 <= 0;
                Hwrite_reg_2 <=0;
                Hreadyout_reg_2 <= 0;
                Hreadyin_reg_2 <= 0;
         end
       else
        begin
                read_reg_2      <= read_reg;
                read_reg_3      <= read_reg_2;
                Haddr_reg       <= Haddr;
                Haddr_reg_2     <= Haddr_reg;
                Haddr_reg_3     <= Haddr_reg_2;
                Htrans_reg      <= Htrans;
                Htrans_reg_2    <= Htrans_reg;
                Hsize_reg       <= Hsize;
                Hsize_reg_2     <= Hsize_reg;
                Hwrite_reg      <= Hwrite;
                Hwrite_reg_2    <= Hwrite_reg;
                Hreadyout_reg   <= Hreadyout;
                Hreadyout_reg_2 <= Hreadyout_reg;
                Hreadyin_reg    <= Hreadyin;
                Hreadyin_reg_2  <= Hreadyin_reg;
                Hrdata_reg_2    <= Hrdata_reg;
        end
   end

        always @(posedge Hclk, negedge Hresetn)
        begin
        if(!Hresetn)
         begin
          invalid_len   <=      0;
         end
        else if(!Hreadyin_reg)
        begin
        invalid_len     <=      0;
        end
        else if (~Hreadyout_in)
        begin
                invalid_len     <=0;
        end
        else
        begin
                if (Hwrite_reg)  //Write transfer
                begin
                case (Htrans_reg)
                2'b00 : begin
                        invalid_len     <=      0;
                        end
                2'b01 : begin
                        invalid_len     <=      0;
                        end
                default:begin
                        case (Hsize_reg_2)
                         `ifdef WIDTH_1024
                        3'b000: begin
                                invalid_len     <=      0;
                                end
                        3'b001: begin
                                invalid_len     <=      0;
                                end
                        3'b010: begin
                                invalid_len     <=      0;
                                end
                        3'b011: begin
                                invalid_len     <=      0;
                                end
                        3'b100: begin
                                invalid_len     <=      0;
                                end
                        3'b101: begin
                                invalid_len     <=      0;
                                end
                        3'b110: begin
                                invalid_len     <=      0;
                                end
                        3'b111: begin
                                invalid_len     <=      0;
                                end
                        `endif
                        `ifdef WIDTH_512
                        3'b000: begin
                                invalid_len     <=      0;
                                end
                        3'b001: begin
                                invalid_len     <=      0;
                                end
                        3'b010: begin
                                invalid_len     <=      0;
                                end
                        3'b011: begin
                                invalid_len     <=      0;
                                end
                        3'b100: begin
                                invalid_len     <=      0;
                                end
                        3'b101: begin
                                invalid_len     <=      0;
                                end
                        3'b110 :begin
                                invalid_len     <=      0;
                                end
                        default:begin
                                invalid_len     <=      1;
                                end
                        `endif
                        `ifdef WIDTH_256
                        3'b000: begin
                                invalid_len     <=      0;
                                end
                        3'b001: begin
                                invalid_len     <=      0;
                                end
                        3'b010: begin
                                invalid_len     <=      0;
                                end
                        3'b011: begin
                                invalid_len     <=      0;
                                end
                        3'b100: begin
                                invalid_len     <=      0;
                                end
                        3'b101:begin
                                invalid_len     <=      0;
                                end
                        default:begin
                                invalid_len     <=      1;
                                end
                        `endif
                        `ifdef WIDTH_128
                        3'b000: begin
                                invalid_len     <=      0;
                                end
                        3'b001: begin
                                invalid_len     <=      0;
                                end
                        3'b010: begin
                                invalid_len     <=      0;
                                end
                        3'b011: begin
                                invalid_len     <=      0;
                                end
                        3'b100:begin
                                invalid_len     <=      0;
                                end
                        default:begin
                                invalid_len     <=      1;
                                end
                        `endif
                        `ifdef WIDTH_64
                        3'b000: begin
                                invalid_len     <=      0;
                                end
                        3'b001: begin
                                invalid_len     <=      1;
                                end
                        `endif

                        `ifdef WIDTH_32
                        3'b000: begin
                                $display("Width = 32, size 8 bits");
                                invalid_len     <=      0;
                                end
                        3'b001: begin
                                $display("Width = 32, size 16 bits");
                                invalid_len     <=      0;
                                end
                        3'b010:begin
                                $display("Width = 32, size 32 bits");
                                invalid_len     <=      0;
                                end
                        default:begin
                                $display("Width = 32, size more than 32 bits");
                                invalid_len     <=      1;
                                end
                        `endif
                        endcase
                      end // end of non-sequential Mode
                endcase
                end // end of writing mode
             else               // Read transfer
                begin
                case (Hsize)
                `ifdef WIDTH_1024
                        default: begin
                                        invalid_len     <=      0;
                                 end
                `endif
                `ifdef WIDTH_512
                        3'b111 :        begin
                                        invalid_len     <=      1;
                                        end
                        default:        begin
                                        invalid_len     <=      0;
                                        end
                `endif
                `ifdef WIDTH_256
                        3'b111, 3'b110 : begin
                                         invalid_len    <=      1;
                                         end
                        default:        begin
                                        invalid_len     <=      0;
                                        end

                `endif
                `ifdef WIDTH_128
                        3'b111, 3'b110, 3'b101 : begin
                                                  invalid_len   <=      1;
                                                 end
                        default:                begin
                                                invalid_len     <=      0;
                                                end
                `endif
                `ifdef WIDTH_64
                        3'b111, 3'b110, 3'b101, 3'b100 : begin
                                                          invalid_len   <=      1;
                                                         end
                        default:                        begin
                                                          invalid_len   <=      0;
                                                        end

                `endif
                `ifdef WIDTH_32
                3'b111, 3'b110, 3'b101, 3'b100, 3'b011 : begin
                                                                invalid_len     <=      1;
                                                         end
                        default:                        begin
                                                                invalid_len     <=      0;
                                                        end
                `endif

                endcase
        end
      end
     end
endmodule
