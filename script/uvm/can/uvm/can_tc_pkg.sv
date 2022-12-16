`ifndef CAN_TC_PKG_SV
`define CAN_TC_PKG_SV


package can_tc_pkg;
    timeunit 1ns;
    timeprecision 1ps;
    import uvm_pkg::*;
    `include "uvm_macros.svh"

    import can_agt_pkg::*;
    import can_env_pkg::*;

    // `include "/mnt/hgfs/jishengli/sda2/ubutun/2022Q4/uvm_q4/can_bus/uvm/obj/sequence/sequence_lib.sv"
    // `include "/mnt/hgfs/jishengli/sda2/ubutun/2022Q4/uvm_q4/can_bus/uvm/component/can_base_test.sv"
    // `include "/mnt/hgfs/jishengli/sda2/ubutun/2022Q4/uvm_q4/can_bus/uvm/test_case/my_case0.sv"
    `include "sequence_lib.sv"
    `include "can_base_test.sv"
    `include "my_case0.sv"

endpackage:can_tc_pkg


`endif