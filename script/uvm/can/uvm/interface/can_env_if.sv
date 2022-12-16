`ifndef CAN_ENV_IF_SV
`define CAN_ENV_IF_SV
interface can_env_if(input clk1,input clk2,input rst_n);

    can_agt_if agt_intf(clk1,clk2,rst_n);
    // can_agt_if m_can_agt_intf_1();

endinterface:can_env_if



`endif