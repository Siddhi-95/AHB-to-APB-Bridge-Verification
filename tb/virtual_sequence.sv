class virtual_sequence extends uvm_sequence #(uvm_sequence_item);

        `uvm_object_utils(virtual_sequence)

        ahb_sequencer ahb_seqrh[];
        apb_sequencer apb_seqrh[];

        virtual_sequencer vseqrh;

        AHB_APB_env_config m_cfg;

        extern function new(string name = "virtual_sequence");
        extern task body();

endclass: virtual_sequence

/////-------Constructor-------//////
function virtual_sequence::new(string name = "virtual_sequence");
        super.new(name);
endfunction: new

///-------Task body--------//////
task virtual_sequence::body();
        if(!uvm_config_db #(AHB_APB_env_config)::get(null, get_full_name(),"AHB_APB_env_config", m_cfg))
                `uvm_fatal("CONFIG","Cannot get() m_cfg from uvm_config_db. Have you set() it?")

                ahb_seqrh = new[m_cfg.no_of_ahb_agents];
                apb_seqrh = new[m_cfg.no_of_apb_agents];

                assert($cast(vseqrh, m_sequencer))
                else
                        `uvm_error("Body", "Error in casting virtual sequencer")

                //ahb_seqrh in env is assigned with ahb_seqrh in test
                foreach(ahb_seqrh[i])
						ahb_seqrh[i] = vseqrh.ahb_seqrh[i];

                //apb_seqrh in env is assigned with apb_seqrh in test
                foreach(apb_seqrh[i])
                        apb_seqrh[i] = vseqrh.apb_seqrh[i];
endtask: body


//////////Virtual Sequence//////////
class vseq extends virtual_sequence;

        `uvm_object_utils(vseq)

        //test sequence
        test_sequence test1;

        extern function new(string name = "vseq");
        extern task body();
endclass: vseq

//-------Constructor-------//////
function vseq::new(string name = "vseq");
        super.new(name);
endfunction: new

//------task body------//
task vseq::body();

        super.body();

        if(m_cfg.has_ahb_agent)
        begin
                test1 = test_sequence::type_id::create("test1");
                test1.start(ahb_seqrh[0]);
        end

endtask: body
