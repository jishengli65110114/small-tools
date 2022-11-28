`ifndef LIN_SQR_SV
`define LIN_SQR_SV

class lin_sqr extends uvm_sequencer #(lin_trans);
    `uvm_component_utils(lin_sqr)

    extern function new(string name = "lin_sqr",uvm_component parent = null);

    
endclass

function lin_sqr::new(string name,uvm_component parent);
    super.new(name,parent);
endfunction:new

`endif