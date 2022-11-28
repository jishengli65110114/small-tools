`ifndef LIN_ENV_PKG_SV
`define LIN_ENV_PKG_SV
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
package lin_env_pkg ;

    import uvm_pkg::*;
    import lin_agt_pkg::*;
    //------------------------------include search path------------------------------------- 
    // `include "/mnt/hgfs/jishengli/sda2/ubutun/2022Q4/uvm_q4/lin_bus/uvm/obj/lin_env_cfg.sv"
    // // `include "./lin_env_if.sv"
    // `include "/mnt/hgfs/jishengli/sda2/ubutun/2022Q4/uvm_q4/lin_bus/uvm/component/lin_scb.sv"
    // `include "/mnt/hgfs/jishengli/sda2/ubutun/2022Q4/uvm_q4/lin_bus/uvm/component/lin_env.sv"
    //------------------------------include no search path-------------------------------------
    `include "lin_env_cfg.sv"
    // `include "./lin_env_if.sv"
    `include "lin_scb.sv"
    `include "lin_env.sv"
endpackage:lin_env_pkg
   

`endif