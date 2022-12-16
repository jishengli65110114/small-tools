`ifndef CAN_AGT_PKG_SV
`define CAN_AGT_PKG_SV
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

package can_agt_pkg;

    `include "uvm_macros.svh"
    import uvm_pkg::*;
    // `include "/mnt/hgfs/jishengli/sda2/ubutun/2022Q4/uvm_q4/can_bus/uvm/obj/can_trans.sv"
    // // `include "can_agt_if.sv"
    // `include "/mnt/hgfs/jishengli/sda2/ubutun/2022Q4/uvm_q4/can_bus/uvm/obj/can_agt_cfg.sv"
    // `include "/mnt/hgfs/jishengli/sda2/ubutun/2022Q4/uvm_q4/can_bus/uvm/component/can_sqr.sv"
    // `include "/mnt/hgfs/jishengli/sda2/ubutun/2022Q4/uvm_q4/can_bus/uvm/component/can_mst.sv"
    // `include "/mnt/hgfs/jishengli/sda2/ubutun/2022Q4/uvm_q4/can_bus/uvm/component/can_slv.sv"
    // `include "/mnt/hgfs/jishengli/sda2/ubutun/2022Q4/uvm_q4/can_bus/uvm/component/can_mon.sv"
    // `include "/mnt/hgfs/jishengli/sda2/ubutun/2022Q4/uvm_q4/can_bus/uvm/component/can_agt.sv"
    `include "can_trans.sv"
    // `include "can_agt_if.sv"
    `include "can_agt_cfg.sv"
    `include "can_sqr.sv"
    `include "can_mst.sv"
    `include "can_slv.sv"
    `include "can_mon.sv"
    `include "can_agt.sv"
endpackage:can_agt_pkg






`endif