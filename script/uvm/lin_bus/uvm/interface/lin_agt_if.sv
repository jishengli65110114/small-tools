`ifndef LIN_AGT_IF_SV
`define LIN_AGT_IF_SV
//the lin clk is 20Mhz
interface lin_agt_if (input clk,input rst_n);
//signal
    logic rx ;
    logic tx ;
// control flags
    bit has_checks      = 1;
    bit has_coverage    = 1; 

    clocking cb_mst @(posedge clk);
        default input #100ps output #100ps;
        input   rx;
        output  tx;
    endclocking:cb_mst

    clocking cb_slv @(posedge clk);
        default input #100ps output #100ps;
        input   tx;
        output  rx;
    endclocking:cb_slv
    
    clocking cb_mon @(posedge clk);
        default input #100ps output #100ps;
        input rx,tx;
    endclocking:cb_mon

    //covergroup 

    //property assertion

    initial begin:asserion_control
        fork
            forever begin
                wait(rst_n == 0);
                $assertoff();
                wait(rst_n == 1);
                if(has_checks) $asserton();
            end
        join_none 
    end

endinterface

`endif