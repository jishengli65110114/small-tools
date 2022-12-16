`ifndef CAN_AGT_CFG_SV
`define CAN_AGT_CFG_SV

class can_agt_cfg extends uvm_object;
    typedef enum bit[1:0] {MASTER = 0,SLVAER = 1} type_e;
    uvm_active_passive_enum is_active = UVM_ACTIVE; //the other value is UVM_PASSIVE
    type_e agt_type = MASTER;
    `uvm_object_utils_begin(can_agt_cfg)
        `uvm_field_enum(uvm_active_passive_enum,is_active,UVM_ALL_ON)
        `uvm_field_enum(type_e,agt_type,UVM_PRINT|UVM_COPY)
    `uvm_object_utils_end
    extern function new (string name = "");
    extern virtual function void set_master_type();
    extern virtual function void set_slave_type();

endclass

function can_agt_cfg::new(string name = "");
    super.new(name);
endfunction:new

function void can_agt_cfg::set_master_type();
    agt_type = MASTER;
endfunction:set_master_type

function void can_agt_cfg::set_slave_type();
    agt_type = SLVAER;
endfunction:set_slave_type

`endif