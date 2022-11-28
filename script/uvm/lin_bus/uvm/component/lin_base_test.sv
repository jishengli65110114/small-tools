`ifndef CAN_BASE_TEST_SV
`define CAN_BASE_TEST_SV

class lin_base_test extends uvm_test;
    lin_env env;
    lin_env_cfg  cfg;
    uvm_table_printer printer;

    `uvm_component_utils(lin_base_test)
    extern function new(string name,uvm_component parent);
    extern virtual function void build_phase(uvm_phase phase);
    extern virtual function void connect_phase(uvm_phase phase);
    extern virtual function void end_of_elaboration_phase(uvm_phase phase);
    extern virtual function void start_of_simulation_phase(uvm_phase phase);
    extern virtual task reset_phase(uvm_phase phase);
    extern virtual task configure_phase(uvm_phase phase); 
    extern virtual task main_phase(uvm_phase phase);
    extern virtual function void check_phase(uvm_phase phase);
    extern virtual function void init_vseq(uvm_sequence vseq);
endclass:lin_base_test

function lin_base_test::new(string name,uvm_component parent);
    super.new(name,parent);
endfunction:new

function void lin_base_test::build_phase(uvm_phase phase);
    super.build_phase(phase);
    env = lin_env::type_id::create("env",this);
    printer = new();
    printer.knobs.depth = 5;
    //build cfg & cfg redifine & deliver to bottom class
    cfg = lin_env_cfg::type_id::create("cfg");
    cfg.m_cfg[0].set_master_type;
    cfg.m_cfg[1].set_slave_type;
    uvm_config_db#(lin_env_cfg)::set(this,"env","cfg",cfg);

endfunction:build_phase

function void lin_base_test::connect_phase(uvm_phase phase);
    super.connect_phase(phase);
endfunction:connect_phase

function void lin_base_test::end_of_elaboration_phase(uvm_phase phase);
    `uvm_info(get_type_name(),$sformatf("Printing the test topology:\n%s",this.sprint(printer)),UVM_LOW)
    //`uvm_info(get_type_name(), "Print all Factory overrides", UVM_HIGH)
    //factory.print();
    //uvm_top.set_report_id_action_hier("ILLEGALNAME", UVM_NO_ACTION);
endfunction:end_of_elaboration_phase

function void lin_base_test::start_of_simulation_phase(uvm_phase phase);
    super.start_of_simulation_phase(phase);
endfunction:start_of_simulation_phase

task lin_base_test::reset_phase(uvm_phase phase);
    super.reset_phase(phase);
endtask:reset_phase

task lin_base_test::configure_phase(uvm_phase phase);
    super.configure_phase(phase);
endtask:configure_phase

task lin_base_test::main_phase(uvm_phase phase);
    super.main_phase(phase);

    phase.phase_done.set_drain_time(this,200);
    phase.raise_objection(this);
    //to do
    #10ns;
    //vseq = bae_xxxx_tb_virtual_seq::type_id::create();

    `uvm_info(get_full_name(),"lin_base_test start", UVM_HIGH)

    //init_vseq(vseq);

    //vseq.start(null);
    phase.drop_objection(this);
endtask:main_phase

function void lin_base_test::check_phase(uvm_phase phase);
    //check_config_usage();
    //uvm_config_db#(int)::dump();
endfunction:check_phase

function void lin_base_test::init_vseq(uvm_sequence vseq);
    //vseq.bae_xxxx_sequencer = top_env.xxxx_env.agent.sequencer;
endfunction:init_vseq

`endif