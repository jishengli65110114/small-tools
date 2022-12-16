`ifndef CAN_SQR_SV
`define CAN_SQR_SV

class can_sqr extends uvm_sequencer #(can_trans);
    `uvm_component_utils(can_sqr)

    extern function new(string name = "can_sqr",uvm_component parent = null);

    
endclass

function can_sqr::new(string name,uvm_component parent);
    super.new(name,parent);
endfunction:new

`endif