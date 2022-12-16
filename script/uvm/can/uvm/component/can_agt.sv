`ifndef CAN_AGT_SV 
`define CAN_AGT_SV

class can_agt extends uvm_agent;
    can_agt_cfg         cfg;
    can_mst             mst;
    can_slv             slv;
    can_sqr             sqr;
    can_mon             mon;
    virtual can_agt_if  intf;
    typedef enum bit[1:0] {MASTER=0,SLVAER=1} type_e;
    `uvm_component_utils(can_agt)

    extern function new (string name,uvm_component parent);
    extern virtual function void build_phase(uvm_phase phase);
    extern virtual function void connect_phase(uvm_phase phase);
    extern virtual function void end_of_elaboration_phase(uvm_phase phase);
    extern virtual function void start_of_simulation_phase(uvm_phase phase);
    extern virtual task reset_phase(uvm_phase phase);
    extern virtual task configure_phase(uvm_phase phase);
    extern virtual task main_phase(uvm_phase phase);
    
endclass:can_agt

function can_agt::new(string name,uvm_component parent);
    super.new(name,parent);
endfunction:new

function void can_agt::build_phase(uvm_phase phase);
    super.build_phase(phase);
    mon = can_mon::type_id::create("mon",this);
    if(!uvm_config_db#(can_agt_cfg)::get(this,"","cfg",cfg))begin
        `uvm_fatal(get_type_name(),"There are not configuration handle")
    end
    if(!uvm_config_db#(virtual can_agt_if)::get(this,"","env_intf",intf))begin
        `uvm_fatal(get_type_name(),"There are not virtual intf handle")
    end
    uvm_config_db#(virtual can_agt_if)::set(this,"mon","can_agt_if",intf);
    uvm_config_db#(can_agt_cfg)::set(this,"mon","can_agt_cfg",cfg);
    if(cfg.agt_type == MASTER && cfg.is_active == UVM_ACTIVE)begin
        mst = can_mst::type_id::create("mst",this);
        sqr = can_sqr::type_id::create("sqr",this);
        uvm_config_db#(can_agt_cfg)::set(this,"mst","cfg",cfg);
        uvm_config_db#(virtual can_agt_if)::set(this,"mst","intf",intf);
    end
    if(cfg.agt_type == SLVAER && cfg.is_active == UVM_ACTIVE)begin
        slv = can_slv::type_id::create("slv",this);
        uvm_config_db#(can_agt_cfg)::set(this,"slv","cfg",cfg);
        uvm_config_db#(virtual can_agt_if)::set(this,"slv","intf",intf);
    end
endfunction:build_phase

function void can_agt::connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    if(cfg.agt_type == MASTER && cfg.is_active == UVM_ACTIVE)begin
        mst.seq_item_port.connect(sqr.seq_item_export);
    end
    else if(cfg.agt_type == SLVAER && cfg.is_active == UVM_ACTIVE)begin
        //slv.seq.item_port.connect(sqr.seq_item_export);
    end
endfunction:connect_phase

function void can_agt::end_of_elaboration_phase(uvm_phase phase);
    super.end_of_elaboration_phase(phase);
endfunction:end_of_elaboration_phase

function void can_agt::start_of_simulation_phase(uvm_phase phase);
    super.start_of_simulation_phase(phase);
endfunction:start_of_simulation_phase

task can_agt::reset_phase(uvm_phase phase);
    super.reset_phase(phase);
endtask:reset_phase

task can_agt::configure_phase(uvm_phase phase);
    super.configure_phase(phase);
endtask:configure_phase

task can_agt::main_phase(uvm_phase phase);
    super.main_phase(phase);
endtask:main_phase

`endif