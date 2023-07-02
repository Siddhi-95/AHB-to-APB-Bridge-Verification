////////-Base sequence-----////
class base_sequence_ahb extends uvm_sequence #(ahb_xtn);

        `uvm_object_utils(base_sequence_ahb)
             
	        logic [31:0] haddr;
                logic hwrite;
                logic [2:0] hsize;
                logic [2:0] hburst;
	
        extern function new(string name = "base_sequence_ahb");
endclass

function base_sequence_ahb::new(string name = "base_sequence_ahb");
        super.new(name);
endfunction

//back to back write//
class write_back extends base_sequence_ahb;

	`uvm_object_utils(write_back)

	
                logic [31:0] haddr1;
                logic hwrite1;
                logic [2:0] hsize1;
                logic [2:0] hburst1;


	extern function new(string name = "write_back");
        extern task body();
endclass

function write_back::new(string name = "write_back");
        super.new(name);
endfunction


task write_back::body();

        repeat(15)
        begin
        req = ahb_xtn::type_id::create("req");

        start_item(req);
        assert(req.randomize() with {Htrans == 2'b10 && Hburst == 3'b000 && Hwdata inside {[0:32'h0000_ffff]};}); //first xtn is NS
        finish_item(req);

        end

	//store in local variables
        haddr = req.Haddr;
        hsize = req.Hsize;
        hburst = req.Hburst;
        hwrite = req.Hwrite;

        //-----UNSPECIFIED LENGTH---------//
        if(hburst == 3'b001)
        begin
                for(int i=0; i<req.length-1; i++)
                begin
                        //haddr = haddr + (2**hsize);

                        start_item(req);

                        if(hsize == 0)
                                assert(req.randomize() with {Hsize == hsize; Hburst == hburst;
                                                                                        Hwrite == hwrite; Htrans == 2'b11;
                                                                                        Haddr == haddr + 1'b1;});

                        if(hsize == 1)
                                assert(req.randomize() with {Hsize == hsize; Hburst == hburst;
                                                                                        Hwrite == hwrite; Htrans == 2'b11;
                                                                                        Haddr == haddr + 2'b10;});

                        if(hsize == 2)
                                assert(req.randomize() with {Hsize == hsize; Hburst == hburst;
                                                                                        Hwrite == hwrite; Htrans == 2'b11;
                                                                                        Haddr == haddr + 3'b100;});

                        finish_item(req);

                        haddr = req.Haddr;
                end
        end    

	start_item(req);
        assert(req.randomize() with {Htrans == 2'b00;}); //first xtn is NS
        finish_item(req);
                                                                   
endtask: body

///-------test sequence-------/////
class test_sequence extends base_sequence_ahb;

        `uvm_object_utils(test_sequence)

               // logic [31:0] haddr;
               // logic hwrite;
                //logic [2:0] hsize;
               // logic [2:0] hburst;

        extern function new(string name = "test_sequence");
        extern task body();
endclass

function test_sequence::new(string name = "test_sequence");
        super.new(name);
endfunction

task test_sequence::body();
	repeat(10)
	begin
        req = ahb_xtn::type_id::create("req");

        start_item(req);
	assert(req.randomize() with {Htrans == 2'b10 && Hburst inside {[1:7]} && Hwdata inside {[32'h0001_ffff:32'hffff_ffff]};}); //first xtn is NS
	finish_item(req);

        //store in local variables
        haddr = req.Haddr;
        hsize = req.Hsize;
        hburst = req.Hburst;
        hwrite = req.Hwrite;

        //-----INCR 4---------//
        if(hburst == 3'b011)
        begin
                for(int i=0; i<3; i++)
                begin
                        //haddr = haddr + (2**hsize);
                        start_item(req);

                        if(hsize == 0)
                                assert(req.randomize() with {Hsize == hsize; Hburst == hburst;
                                                                                        Hwrite == hwrite; Htrans == 2'b11;
                                                                                        Haddr == haddr + 1'b1;});

                        if(hsize == 1)
                                assert(req.randomize() with {Hsize == hsize; Hburst == hburst;
                                                                                        Hwrite == hwrite; Htrans == 2'b11;
                                                                                        Haddr == haddr + 2'b10;});

                        if(hsize == 2)
                                assert(req.randomize() with {Hsize == hsize; Hburst == hburst;
                                                                                        Hwrite == hwrite; Htrans == 2'b11;
                                                                                 	Haddr == haddr +3'b100;});
                        finish_item(req);

                        haddr = req.Haddr;
                end
        end

        //-----INCR 8---------//
        if(hburst == 3'b101)
        begin
                for(int i=0; i<7; i++)
                begin
                        //haddr = haddr + (2**hsize);

                        start_item(req);

                        if(hsize == 0)
                                assert(req.randomize() with {Hsize == hsize; Hburst == hburst;
                                                                                        Hwrite == hwrite; Htrans == 2'b11;
                                                                                        Haddr == haddr + 1'b1;});

                        if(hsize == 1)
                                assert(req.randomize() with {Hsize == hsize; Hburst == hburst;
                                                                                        Hwrite == hwrite; Htrans == 2'b11;
                                                                                        Haddr == haddr + 2'b10;});

                        if(hsize == 2)
                                assert(req.randomize() with {Hsize == hsize; Hburst == hburst;
                                                                                        Hwrite == hwrite; Htrans == 2'b11;
                                                                                        Haddr == haddr + 3'b100;});

                        finish_item(req);
 			haddr = req.Haddr;
                end
        end

        //-----INCR 16---------//
        if(hburst == 3'b111)
        begin
                for(int i=0; i<15; i++)
                begin
                        //haddr = haddr + (2**hsize);

                        start_item(req);

                        if(hsize == 0)
                                assert(req.randomize() with {Hsize == hsize; Hburst == hburst;
                                                                                        Hwrite == hwrite; Htrans == 2'b11;
                                                                                        Haddr == haddr + 1'b1;});

                        if(hsize == 1)
                                assert(req.randomize() with {Hsize == hsize; Hburst == hburst;
                                                                                        Hwrite == hwrite; Htrans == 2'b11;
                                                                                        Haddr == haddr + 2'b10;});

                        if(hsize == 2)
                                assert(req.randomize() with {Hsize == hsize; Hburst == hburst;
                                                                                        Hwrite == hwrite; Htrans == 2'b11;
                                                                                        Haddr == haddr + 3'b100;});

                        finish_item(req);

                        haddr = req.Haddr;
                end
        end
//-----INCR unspecified length---------//
        if(hburst == 3'b001)
        begin
                for(int i=0; i<req.length-1; i++)
                begin
                        //haddr = haddr + (2**hsize);

                        start_item(req);

                        if(hsize == 0)
                                assert(req.randomize() with {Hsize == hsize; Hburst == hburst;
                                                                                        Hwrite == hwrite; Htrans == 2'b11;
                                                                                        Haddr == haddr + 1'b1;});

                        if(hsize == 1)
                                assert(req.randomize() with {Hsize == hsize; Hburst == hburst;
                                                                                        Hwrite == hwrite; Htrans == 2'b11;
                                                                                        Haddr == haddr + 2'b10;});

                        if(hsize == 2)
                                assert(req.randomize() with {Hsize == hsize; Hburst == hburst;
                                                                                        Hwrite == hwrite; Htrans == 2'b11;
                                                                                        Haddr == haddr + 3'b100;});

                        finish_item(req);

                        haddr = req.Haddr;
                end
        end

        //----WRAP 4-----///
        if(hburst == 3'b010)
        begin
                for(int i=0; i<3; i++)
                begin
			start_item(req);

			if(hsize == 0)
                                assert(req.randomize() with {Hsize == hsize; Hburst == hburst;
                                                                                        Hwrite == hwrite; Htrans == 2'b11;
                                                                                        Haddr == {haddr[31:2], haddr[1:0] + 1'b1};});

                        if(hsize == 1)
                                assert(req.randomize() with {Hsize == hsize; Hburst == hburst;
                                                                                        Hwrite == hwrite; Htrans == 2'b11;
                                                                                        Haddr == {haddr[31:3], haddr [2:1]+ 1'b1, haddr[0]};});

                        if(hsize == 2)
                                assert(req.randomize() with {Hsize == hsize; Hburst == hburst;
                                                                                        Hwrite == hwrite; Htrans == 2'b11;
                                                                                        Haddr == {haddr[31:4], haddr[3:2] + 1'b1, haddr[1:0]};});

                        finish_item(req);

                        haddr = req.Haddr;
        end
        end

        //----WRAP 8-----///
        if(hburst == 3'b100)
        begin
                for(int i=0; i<7; i++)
                begin
			start_item(req);

                        if(hsize == 0)
                                assert(req.randomize() with {Hsize == hsize; Hburst == hburst;
                                                                                        Hwrite == hwrite; Htrans == 2'b11;
                                                                                        Haddr == {haddr[31:3], haddr[2:0] + 1'b1};});
			if(hsize == 1)
                                assert(req.randomize() with {Hsize == hsize; Hburst == hburst;
                                                                                        Hwrite == hwrite; Htrans == 2'b11;
                                                                                        Haddr == {haddr[31:4], haddr[3:1] + 1'b1, haddr[0]};});

                        if(hsize == 2)
                                assert(req.randomize() with {Hsize == hsize; Hburst == hburst;
                                                                                        Hwrite == hwrite; Htrans == 2'b11;
                                                                                        Haddr == {haddr[31:5], haddr[4:2] + 1'b1, haddr[1:0]};});

                        finish_item(req);

                        haddr = req.Haddr;
        end
        end

        //----WRAP 16-----///
        if(hburst == 3'b110)
        begin
                for(int i=0; i<15; i++)
                begin
			start_item(req);

                        if(hsize == 0)
                                assert(req.randomize() with {Hsize == hsize; Hburst == hburst;
                                                                                        Hwrite == hwrite; Htrans == 2'b11;
                                                                                        Haddr == {haddr[31:4], haddr[3:0] + 1'b1};});

			if(hsize == 1)
                                assert(req.randomize() with {Hsize == hsize; Hburst == hburst;
                                                                                        Hwrite == hwrite; Htrans == 2'b11;
                                                                                        Haddr == {haddr[31:5], haddr[4:1] + 1'b1, haddr[0]};});

                        if(hsize == 2)
                                assert(req.randomize() with {Hsize == hsize; Hburst == hburst;
                                                                                        Hwrite == hwrite; Htrans == 2'b11;
                                                                                        Haddr == {Haddr[31:6], haddr[5:2] + 1'b1, haddr[1:0]};});

                        finish_item(req);

                        haddr = req.Haddr;
        end
        end
	end

	
	start_item(req);
        assert(req.randomize() with {Htrans == 2'b00;}); //first xtn is NS
	finish_item(req);
	
	
endtask: body

//In AHB_SEQUENCE we will first create a Non-sequential transaction which will be stored in local variables as this data won't change for the entire transfer of data. Later, 
//depending on the randomized Hburst and Hsize values, SEQUENTIAL transactions will be generated. 
