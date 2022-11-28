`ifndef LIN_TC_PKG_SV
`define LIN_TC_PKG_SV


package lin_tc_pkg;
    timeunit 1ns;
    timeprecision 1ps;
    import uvm_pkg::*;
    `include "uvm_macros.svh"

    import lin_agt_pkg::*;
    import lin_env_pkg::*;
    //------------------------------include search path------------------------------------- 
    // `include "/mnt/hgfs/jishengli/sda2/ubutun/2022Q4/uvm_q4/lin_bus/uvm/obj/sequence/sequence_lib.sv"
    // `include "/mnt/hgfs/jishengli/sda2/ubutun/2022Q4/uvm_q4/lin_bus/uvm/component/lin_base_test.sv"
    // `include "/mnt/hgfs/jishengli/sda2/ubutun/2022Q4/uvm_q4/lin_bus/uvm/test_case/my_case0.sv"
    //------------------------------include no search path-------------------------------------
    `include "sequence_lib.sv"
    `include "lin_base_test.sv"
    `include "my_case0.sv"
endpackage:lin_tc_pkg


`endif