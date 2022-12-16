`ifndef CAN_AGT_IF_SV
`define CAN_AGT_IF_SV
//The can clk1 is 500k && The can_fd clk2 is 20Mhz
interface can_agt_if (input clk1,input clk2,input rst_n);
//clk1 = 500k && clk2 =  20M
//signal
    logic rx ;
    logic tx ;
// control flags
    bit has_checks      = 1;
    bit has_coverage    = 1; 

    clocking cb_mst1 @(posedge clk1);
        default input #1ps output #1ps;
        input   rx;
        output  tx;
    endclocking:cb_mst1

    clocking cb_mon1 @(posedge clk1);
        default input #1ps output #1ps;
        input rx,tx;
    endclocking:cb_mon1

    clocking cb_mst2 @(posedge clk2);
        default input #1ps output #1ps;
        input   rx;
        output  tx;
    endclocking:cb_mst2

    clocking cb_mon2 @(posedge clk2);
        default input #1ps output #1ps;
        input rx,tx;
    endclocking:cb_mon2

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