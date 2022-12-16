`timescale 1ns/1ps
// `include "../uvm/interface/can_agt_if.sv"
// `include "../uvm/interface/can_env_if.sv"


module can_tb_top;
    import uvm_pkg::*;
    import can_agt_pkg::*;
    import can_env_pkg::*;
    logic clk1,clk2;
    logic rst_n;
    can_env_if intf(.*);
    // can_env_if intf(clk,rst_n);
    //assign signal
    //assign v_if.m_tsn_axi_agt_if_0.clk=clk;
    //assign v_if.m_tsn_axi_agt_if_1.clk=clk;

    // assign v_if.m_tsn_axi_agt_if_0.tready = v_if.m_tsn_axi_agt_if_1.tready ;
    // assign v_if.m_tsn_axi_agt_if_1.tdata=v_if.m_tsn_axi_agt_if_0.tdata;
    // assign v_if.m_tsn_axi_agt_if_1.tvalid=v_if.m_tsn_axi_agt_if_0.tvalid;
//clock & rst_n
initial begin
    clk1 = 0;
    clk2 = 0;
    rst_n = 1;
    fork
        forever begin
            #1000 clk1 = ~clk1;//20MHz
            #250  clk2 = ~clk2;//500KHz
        end
        begin
           repeat(1)@(posedge clk1);
            rst_n = ~rst_n;
            @(posedge clk1);
            rst_n = ~rst_n; 
        end
    join_none
end
//configuretion
initial begin
    uvm_config_db#(virtual can_env_if)::set(uvm_root::get(),"uvm_test_top.env","can_env_intf",intf);
    run_test("my_case0");
end
initial begin  
    $fsdbDumpfile("can_tb_top.fsdb");
	$fsdbDumpvars(0,can_tb_top); 
    $fsdbDumpMDA();
    $vcdplusmemon();
    $vcdpluson;
end
endmodule