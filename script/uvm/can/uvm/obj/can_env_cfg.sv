`ifndef CAN_ENV_CFG_SV
`define CAN_ENV_CFG_SV
class can_env_cfg extends uvm_object;
    bit has_scb = 1;
    can_agt_cfg m_cfg[2];
    `uvm_object_utils(can_env_cfg)
    extern function new(string name = "");
endclass:can_env_cfg

function can_env_cfg::new(string name = "");
    super.new(name);
    foreach(m_cfg[i])begin
        m_cfg[i] = new($sformatf("m_cfg[%0d]",i));
    end
endfunction:new

`endif