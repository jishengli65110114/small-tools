`ifndef SEQUENCE_LIB_SV
`define SEQUENCE_LIB_SV


/* -----------------------------------can_base_sequence-----------------------------------------------*/
class can_base_sequence extends uvm_sequence #(can_trans);
    // can_trans req,rsp;
    `uvm_object_utils(can_base_sequence)
    extern function new(string name = "can_base_sequence");
    extern virtual function int get_rand_number_except(int min_thre,int max_thre,int except_num);
    extern virtual function int get_rand_number(int min_thre,int max_thre);
endclass:can_base_sequence

function can_base_sequence::new(string name= "can_base_sequence");
    super.new(name);
    // set_automatic_phase_objection(1); 
endfunction:new

function int can_base_sequence::get_rand_number_except(int min_thre,int max_thre,int except_num);
    int val = get_rand_number(min_thre,max_thre);
    while(val == except_num)
        val = get_rand_number(min_thre,max_thre);
    return val;
endfunction:get_rand_number_except

function int can_base_sequence::get_rand_number(int min_thre,int max_thre);
    int val;
    void'(std::randomize(val) with {val inside {[min_thre:max_thre]};});
    return val;
endfunction:get_rand_number

/* -----------------------------------------can_random_sequence-----------------------------------------*/
class can_random_sequence extends can_base_sequence;
//can bus fram struct
    //  Group: Variables
    rand bit [11-1:0] identify_can;
    rand bit          rtr_can;
    rand bit          ide_can;
    rand bit          r0_can;
    rand bit [4-1:0]  dlc_can;
    rand bit [8-1:0]  data_can[];
    rand bit [15-1:0] crc_sequence_can;
//can_fd fram struct
    //  Group: Variables
    rand bit [11-1:0] identify_can_fd;
    rand bit          r1_can_fd;//
    rand bit          ide_can_fd;
    rand bit          edl_can_fd;
    rand bit          r0_can_fd;
    rand bit          brs_can_fd;
    rand bit          esi_can_fd;
    rand bit [4-1:0]  dlc_can_fd;
    rand bit [8-1:0]  data_can_fd[];
    rand bit [4-1:0]  stuff_count_can_rd;
    rand bit [17-1:0] crc_can_fd1;
    rand bit [21-1:0] crc_can_fd2;
    rand bit [3-1:0]  ifs_can_fd;
//control parameter  
    rand bit [3:0]              fram_gap;
    rand fram_type              data_type;
    rand bus_type               can_type;
    `uvm_object_utils(can_random_sequence);
    constraint cstr{
        data_type == data_frame;
        can_type dist {can:= 10,can_fd:=20};
    }
    extern function new(string name = "can_base_sequence");
    extern virtual task body();
endclass:can_random_sequence

function can_random_sequence::new(string name);
    super.new(name);
endfunction:new

task can_random_sequence::body();
    `uvm_do_with(req,{  fram_gap    == local::fram_gap;
                        can_type    == local::can_type;
                        data_type   == local::data_type;
                        })
    get_response(rsp);
    `uvm_info(get_type_name(),"can random sequence is send success",UVM_LOW)
endtask:body

`endif