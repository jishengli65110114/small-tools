`ifndef SEQUENCE_LIB_SV
`define SEQUENCE_LIB_SV


/* -----------------------------------lin_base_sequence-----------------------------------------------*/
class lin_base_sequence extends uvm_sequence #(lin_trans);
    // lin_trans req,rsp;
    `uvm_object_utils(lin_base_sequence)
    extern function new(string name = "lin_base_sequence");
    extern virtual function int get_rand_number_except(int min_thre,int max_thre,int except_num);
    extern virtual function int get_rand_number(int min_thre,int max_thre);
endclass:lin_base_sequence

function lin_base_sequence::new(string name= "lin_base_sequence");
    super.new(name);
    // set_automatic_phase_objection(1); 
endfunction:new

function int lin_base_sequence::get_rand_number_except(int min_thre,int max_thre,int except_num);
    int val = get_rand_number(min_thre,max_thre);
    while(val == except_num)
        val = get_rand_number(min_thre,max_thre);
    return val;
endfunction:get_rand_number_except

function int lin_base_sequence::get_rand_number(int min_thre,int max_thre);
    int val;
    void'(std::randomize(val) with {val inside {[min_thre:max_thre]};});
    return val;
endfunction:get_rand_number

/* -----------------------------------------lin_random_sequence-----------------------------------------*/
class lin_random_sequence extends lin_base_sequence;
    //  Group: Variables
    rand bit [5-1:0]            lin_break      =-1 ;//used to signal the beginning of a new frame
    rand bit [8-1:0]            sync           =-1 ;// 
    rand bit [8-1:0]            identifier     =-1 ;
    rand int                    response_space =-1 ;
    rand bit [8-1:0]            data[]             ; 
    rand bit [8-1:0]            checksum       =-1 ;
    rand bit [8-1:0]            inter_byte_space;//must be non-negative
    //control parameter
    rand bit [4-1:0]            data_lenth = -1;     
    rand bit [3:0]              fram_gap   = -1;
    rand trans_type             data_type ;
    rand trans_role             data_role ;
    //for monitor receive
    rand bit [8-1:0]            data_mon[$]; 
    `uvm_object_utils(lin_random_sequence);
    constraint cstr{
      fram_gap inside {[1:10]};
      data_type == unconditional_frame;
      data_role == master_node; 
    }
    extern function new(string name = "lin_base_sequence");
    extern virtual task body();
endclass:lin_random_sequence

function lin_random_sequence::new(string name);
    super.new(name);
endfunction:new

task lin_random_sequence::body();
    `uvm_do_with(req,{ local::lin_break     >=0 ->  lin_break      == local::lin_break;
                       local::response_space>=0 ->  response_space == local::response_space;
                       local::identifier    >=0 ->  identifier     == local::identifier;
                       local::fram_gap      >=0 ->  fram_gap       == local::fram_gap;
                                                    data_type      == local::data_type;
                                                    data_role      == local::data_role; 
                        })
    get_response(rsp);
    `uvm_info(get_type_name(),"lin random sequence is send success",UVM_DEBUG)
endtask:body

`endif