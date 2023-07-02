////////-Base sequence-----////
class base_sequence_apb extends uvm_sequence #(apb_xtn);

        `uvm_object_utils(base_sequence_apb)

        extern function new(string name = "base_sequence_apb");
endclass

function base_sequence_apb::new(string name = "base_sequence_apb");
        super.new(name);
endfunction

///-------test sequence-------/////
class test_sequence_1 extends base_sequence_apb;

        `uvm_object_utils(test_sequence_1)

        extern function new(string name = "test_sequence_1");
        extern task body();
endclass

function test_sequence_1::new(string name = "test_sequence_1");
        super.new(name);
endfunction

task test_sequence_1::body();
        repeat(10);
                begin
                        req = apb_xtn::type_id::create("req");
                        start_item(req);
                        assert(req.randomize());
                        finish_item(req);
                end
endtask
