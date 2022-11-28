`ifndef LIN_AGT_PKG_SV
`define LIN_AGT_PKG_SV
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

package lin_agt_pkg;

    `include "uvm_macros.svh"
    import uvm_pkg::*;
    //------------------------------include search path------------------------------------- 
    // `include "/mnt/hgfs/jishengli/sda2/ubutun/2022Q4/uvm_q4/lin_bus/uvm/obj/lin_trans.sv"
    // // `include "lin_agt_if.sv"
    // `include "/mnt/hgfs/jishengli/sda2/ubutun/2022Q4/uvm_q4/lin_bus/uvm/obj/lin_agt_cfg.sv"
    // `include "/mnt/hgfs/jishengli/sda2/ubutun/2022Q4/uvm_q4/lin_bus/uvm/component/lin_sqr.sv"
    // `include "/mnt/hgfs/jishengli/sda2/ubutun/2022Q4/uvm_q4/lin_bus/uvm/component/lin_mst.sv"
    // `include "/mnt/hgfs/jishengli/sda2/ubutun/2022Q4/uvm_q4/lin_bus/uvm/component/lin_slv.sv"
    // `include "/mnt/hgfs/jishengli/sda2/ubutun/2022Q4/uvm_q4/lin_bus/uvm/component/lin_mon.sv"
    // `include "/mnt/hgfs/jishengli/sda2/ubutun/2022Q4/uvm_q4/lin_bus/uvm/component/lin_agt.sv"
    //------------------------------include no search path-------------------------------------
    `include "lin_trans.sv"
    // `include "lin_agt_if.sv"
    `include "lin_agt_cfg.sv"
    `include "lin_sqr.sv"
    `include "lin_mst.sv"
    `include "lin_slv.sv"
    `include "lin_mon.sv"
    `include "lin_agt.sv"

endpackage:lin_agt_pkg






`endif