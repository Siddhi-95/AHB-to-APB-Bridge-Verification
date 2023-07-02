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
				
parameter SINGLE = 3'b000, INCR4 = 3'b011, WRAP4 = 3'b010, INCR8 = 3'b101, WRAP8 = 3'b100, INCR16 = 3'b111, WRAP16 = 3'b110;
parameter IDLE = 2'b00, BUSY = 2'b01, NON_SEQ = 2'b10, SEQ = 2'b11;

property master_nowait_single;
	@(posedge clock) disable iff(( !Hresetn ))
	
	( Hburst == SINGLE ) |-> ( Htrans == NON_SEQ || Htrans == IDLE);
endproperty

SINGLE_XTN: assert property (master_nowait_single);

property master_nowait_incr4_wrap4; //if 
	@(posedge clock) disable iff(( !Hresetn ) ||  
	                            ( ( Htrans == IDLE ) ||
	                              ( Htrans == BUSY ) )
						)
	
	  ( Hburst == INCR4 || Hburst == WRAP4)   &&
	  ( Htrans == NON_SEQ )  |=>
	  ( ( Htrans == SEQ ) ) [*3]; //if hburst is incr4 or wrap 4 & 1st transfer is non-seq with okay resp, then in the nxt cyc we need 3 seq data tran//sfers with okay resp consecutively. when h trans is idle or busy, and hresp is not okay, then it(property) will be disabled.
endproperty

INCR4_WRAP4: assert property (master_nowait_incr4_wrap4)
		$display("Assertions Passed", $time);
	     else
		$display("Assertions failed", $time);


property master_nowait_incr8_wrap8; //if
        @(posedge clock) disable iff(( !Hresetn ) ||
                                    ( ( Htrans == IDLE ) ||
                                      ( Htrans == BUSY ) )
                                                )

          ( Hburst == INCR8 || Hburst == WRAP8)   &&
          ( Htrans == NON_SEQ )  ##1
          ( ( Htrans == SEQ ) ) [*7] |-> 1;
endproperty

INCR8_WRAP8: assert property (master_nowait_incr8_wrap8); 

property master_nowait_incr16_wrap16; //if
        @(posedge clock) disable iff(( !Hresetn ) ||
                                    ( ( Htrans == IDLE ) ||
                                      ( Htrans == BUSY ) )
                                                )

          ( Hburst == INCR16 || Hburst == WRAP16)   &&
          ( Htrans == NON_SEQ )  ##1
          ( ( Htrans == SEQ ) ) [*15] |-> 1;
endproperty

INCR16_WRAP16: assert property (master_nowait_incr16_wrap16);

sequence count_four1;
	( ( Hreadyout ) && ( Htrans == SEQ ) && ( ( Hburst == WRAP4 ) ||
	   ( Hburst == INCR4 ) ) ) [->3] ;
endsequence

sequence count_four2;
	( ( ( Htrans != IDLE ) && ( Htrans != NON_SEQ ) ) &&
	  ( ( Hburst == WRAP4 ) || ( Hburst == INCR4 ) ) ) throughout
	 (count_four1);
endsequence

property count_four;                                //BURST LENGTH
	@(posedge clock) disable iff(( !Hresetn ) )
	 
	
	( ( Htrans == NON_SEQ ) && ( Hreadyout ) && 
	 ( ( Hburst == WRAP4 ) || ( Hburst == INCR4 ) ) ) |=> ( count_four2 );
	 //1st clk cycle is htrans is non-seq, in the next clk cycle - (htrans cannot be Idle/non-seq
	 //and hburst can be Wrap or Incr) - This sequence should be high throughout Seq 2 (htrans is 3-SEQ and hburst can be
	 //wrap or Incr, Goto operator 3 times)
	 //Meaning address and control info cannot be changed during entire transfer
endproperty

COUNT_FOUR:assert property (count_four);

property four_beat_wrap_byte;
	bit [31:0] temp_addr;
	@(posedge clock) disable iff(!Hresetn) 
 
	( ( Hsize == 3'b000 ) && ( Hburst == WRAP4 ) &&
	  (Hreadyout) && (Htrans[1])) ##0 (1, temp_addr = Haddr) ##1
	   ( ( Htrans == SEQ ) || ( Htrans == BUSY ) ) ##0 (Hreadyout )[-> 1] ##0
		 (1, temp_addr[1:0] = temp_addr[1:0] + 3'd1)|-> //Wrap 4, Hsize 0
		 ( Haddr == temp_addr);
endproperty

//Htrans[1] -- ???
FOUR_BEAT_WRAP_BYTE: assert property (four_beat_wrap_byte);

property eight_beat_wrap_byte;
	bit [31:0] temp_addr;
	@(posedge clock) disable iff(!Hresetn) 
 
	( ( Hsize == 3'b000 ) && ( Hburst == WRAP8 ) &&
	  (Hreadyout) && (Htrans[1])) ##0 (1, temp_addr = Haddr) ##1
	   ( ( Htrans == SEQ ) || ( Htrans == BUSY ) ) ##0 (Hreadyout )[-> 1] ##0
		 (1, temp_addr[1:0] = temp_addr[2:0] + 3'd1)|-> //Wrap 8, Hsize 0
		 ( Haddr == temp_addr);
endproperty
EIGHT_BEAT_WRAP_BYTE: assert property (eight_beat_wrap_byte);


property sixteen_beat_wrap_byte;
	bit [31:0] temp_addr;
	@(posedge clock) disable iff(!Hresetn) 
 
	( ( Hsize == 3'b000 ) && ( Hburst == WRAP16 ) && (Hreadyout) &&( Htrans == NON_SEQ || Htrans == SEQ ))
	##0 (1, temp_addr = Haddr) ##1
	   ( ( Htrans == SEQ ) || ( Htrans == IDLE ) ) ##0 (Hreadyout) [-> 1] ##0
		 (1, temp_addr = temp_addr + 3'd1)|-> //Wrap 16, Hsize 0
		 Haddr == temp_addr;
endproperty
SIXTEEN_BEAT_WRAP_BYTE: assert property (sixteen_beat_wrap_byte);


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
								input Hrdata;
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
				input Hrdata;
        endclocking

        //DRIVER and monitor modport:
        modport AHB_DR_MP (clocking ahb_drv_cb);
        modport AHB_MON_MP (clocking ahb_mon_cb);


endinterface : ahb_if

