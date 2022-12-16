`ifndef MY_CASE0_SV
`define MY_CASE0_SV
//crc error
class case0_sequence extends can_base_sequence;

    // sequence combination
    can_random_sequence         random_req;
    `uvm_object_utils(case0_sequence)
    // `uvm_object_utils_begin(case0_sequence)
    //     `uvm_field_int(identify_id,UVM_ALL_ON)
    //     `uvm_field_int(dlc,UVM_ALL_ON)
    //     `uvm_field_int(data,UVM_ALL_ON)
    //     `uvm_field_int(crc,UVM_ALL_ON)        
    // `uvm_object_utils_end
    extern function new(string name = "case0_sequence");
    extern virtual task body();
endclass:case0_sequence

function case0_sequence::new(string name);
    super.new();
    //idea one (uvm1.2 recommand)
//   set_automatic_phase_objection(1);
endfunction:new

task case0_sequence::body();
    //idea two (uvm 1.1)https://zhuanlan.zhihu.com/p/446791549
    // starting_phase = get_starting_phase();
    // if(starting_phase != null)begin
    //     starting_phase.raise_objection(this);
    // end
    //case combination
    repeat(1000)begin
        `uvm_do_with(random_req,{fram_gap == 'h1;}) 
        // `uvm_do_with(req,{}) 
        // `uvm_info(get_type_name(),random_req.req.sprint(),UVM_LOW)
    end
    // if(starting_phase != null)begin
    //     starting_phase.drop_objection(this);
    // end
endtask:body

class my_case0 extends can_base_test;
    case0_sequence seq_0;
    `uvm_component_utils(my_case0)
    extern function new(string name ,uvm_component parent);
    extern virtual function void build_phase(uvm_phase phase);
    extern virtual task main_phase(uvm_phase phase);
endclass:my_case0

function my_case0::new(string name,uvm_component parent);
    super.new(name,parent);
    seq_0 = new("seq_0");
endfunction:new

function void my_case0::build_phase(uvm_phase phase);
    super.build_phase(phase);
    //method 1 to send sequence
    // uvm_config_db#(uvm_object_wrapper)::set(this,
    //                                         "env.agt.sqr.main_phase",
    //                                         "default_sequence",
    //                                         case0_sequence::type_id::get());
endfunction:build_phase
 
task my_case0::main_phase(uvm_phase phase);
    super.main_phase(phase);
    phase.phase_done.set_drain_time(this,200);
    //method 2 to send sequence
    // case0_sequence seq = new("seq");
    phase.raise_objection(this);
    seq_0.start(env.agt.sqr);
    #200ns;
    `uvm_info(get_full_name(),"mycase0 is begin",UVM_LOW)
    phase.drop_objection(this);
endtask:main_phase

`endif
