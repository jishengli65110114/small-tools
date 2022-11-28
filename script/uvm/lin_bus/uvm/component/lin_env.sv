`ifndef LIN_ENV_SV
`define LIN_ENV_SV
class lin_env extends uvm_env;
    virtual lin_env_if env_intf;
    virtual lin_agt_if agt_intf;
    lin_env_cfg cfg;
    lin_agt agt;
    lin_scb scb;

    uvm_tlm_analysis_fifo #(lin_trans) agt_ref_tx_fifo;//monitor to reference model 
    uvm_tlm_analysis_fifo #(lin_trans) agt_scb_rx_fifo;//monitor to scoreboard
    uvm_tlm_analysis_fifo #(lin_trans) ref_scb_rx_fifo;//reference model to scoreboard

    `uvm_component_utils(lin_env)
    extern function new(string name,uvm_component parent);
    extern virtual function void build_phase(uvm_phase phase);
    extern virtual function void connect_phase(uvm_phase phase);
    extern virtual function void end_of_elaboration_phase(uvm_phase phase);
    extern virtual function void start_of_simulation_phase(uvm_phase phase);
    extern virtual task reset_phase(uvm_phase phase);
    extern virtual task configure_phase(uvm_phase phase);
    extern virtual task main_phase(uvm_phase phase);
endclass:lin_env

function lin_env::new(string name , uvm_component parent);
    super.new(name,parent);
endfunction:new

function void lin_env::build_phase(uvm_phase phase);
    super.build_phase(phase);
    //just build one agent 
    agt = lin_agt::type_id::create("agt",this);
    if(!uvm_config_db#(lin_env_cfg)::get(this,"","cfg",cfg))begin
        `uvm_fatal(get_type_name(),"There are not configuration handle")
    end
    if(cfg.has_scb == 1)begin
        scb = lin_scb::type_id::create("scb",this);
    end
    if(!uvm_config_db#(virtual lin_env_if)::get(this,"","lin_env_intf",env_intf))begin
        `uvm_fatal(get_type_name(),"There are not virtual env_intf handle")
    end
    uvm_config_db#(virtual lin_agt_if)::set(this,"agt","env_intf",env_intf.agt_intf);
    uvm_config_db#(lin_agt_cfg)::set(this,"agt","cfg",cfg.m_cfg[0]);
    //uvm_tlm_analysis_fifo build
    agt_ref_tx_fifo = new("agt_ref_tx_fifo",this);
    ref_scb_rx_fifo = new("ref_scb_rx_fifo",this);
    agt_scb_rx_fifo = new("agt_scb_rx_fifo",this);

endfunction:build_phase

function void lin_env::connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    if(cfg.has_scb ==1)begin
        agt.mon.mon_analysis_port_rx.connect(agt_scb_rx_fifo.analysis_export);
        agt.mon.mon_analysis_port_tx.connect(agt_ref_tx_fifo.analysis_export);
    //ref connect to scb
        //reference model connect to agt_ref_tx_fifo;
        //mdl.gp.connect(agt_ref_tx.fifo.blocking_get_export);
        //reference model connect to ref_scb_rx_fifo;
        //mdl.ap.connect(ref_scb_rx_fifo.analysis_export);
        scb.monitor2scoboard_tx_port.connect(agt_ref_tx_fifo.blocking_get_export); 
        scb.monitor2scoboard_rx_port.connect(agt_scb_rx_fifo.blocking_get_export); 
        scb.refmodel2scoboard_rx_port.connect(ref_scb_rx_fifo.blocking_get_export);
        scb.refmodel2scoboard_tx_port.connect(agt_ref_tx_fifo.blocking_get_export);
        `uvm_info(get_type_name(), "fifo connected", UVM_DEBUG)   
    end
endfunction:connect_phase

function void lin_env::end_of_elaboration_phase(uvm_phase phase);
    super.end_of_elaboration_phase(phase);
endfunction:end_of_elaboration_phase

function void lin_env::start_of_simulation_phase(uvm_phase phase);
    super.start_of_simulation_phase(phase);
endfunction:start_of_simulation_phase

task lin_env::reset_phase(uvm_phase phase);
    super.reset_phase(phase);
endtask:reset_phase

task lin_env::configure_phase(uvm_phase phase);
    super.configure_phase(phase);
endtask:configure_phase

task lin_env::main_phase(uvm_phase phase);
    super.main_phase(phase);
endtask:main_phase

`endif 