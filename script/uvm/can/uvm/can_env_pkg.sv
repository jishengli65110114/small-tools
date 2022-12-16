`ifndef CAN_ENV_PKG_SV
`define CAN_ENV_PKG_SV
//interface
//transaction & config
//sequence & sequence_lib
//driver & monitor & sequencer
//agent
//reference_model
//scoreboard
//env
//base_test
//case0~n 
    `include "uvm_macros.svh"
package can_env_pkg ;

    import uvm_pkg::*;
    import can_agt_pkg::*;
    // `include "/mnt/hgfs/jishengli/sda2/ubutun/2022Q4/uvm_q4/can_bus/uvm/obj/can_env_cfg.sv"
    // // `include "./can_env_if.sv"
    // `include "/mnt/hgfs/jishengli/sda2/ubutun/2022Q4/uvm_q4/can_bus/uvm/component/can_scb.sv"
    // `include "/mnt/hgfs/jishengli/sda2/ubutun/2022Q4/uvm_q4/can_bus/uvm/component/can_env.sv"
    `include "can_env_cfg.sv"
    // `include "./can_env_if.sv"
    `include "can_scb.sv"
    `include "can_env.sv"
endpackage:can_env_pkg
   

`endif