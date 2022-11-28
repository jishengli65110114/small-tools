`ifndef LIN_ENV_IF_SV
`define LIN_ENV_IF_SV
interface lin_env_if(input clk,input rst_n);

    lin_agt_if agt_intf(clk,rst_n);
    // lin_agt_if m_lin_agt_intf_1();

endinterface:lin_env_if



`endif