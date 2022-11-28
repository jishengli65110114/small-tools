`timescale 1ns/1ps
// `include "../uvm/interface/lin_agt_if.sv"
// `include "../uvm/interface/lin_env_if.sv"


module lin_tb_top;
    import uvm_pkg::*;
    import lin_agt_pkg::*;
    import lin_env_pkg::*;
    logic clk;
    logic rst_n;
    lin_env_if intf(.*);
    // lin_env_if intf(clk,rst_n);
    //assign signal
    assign intf.agt_intf.rx =  intf.agt_intf.tx;
    //assign v_if.m_tsn_axi_agt_if_0.clk=clk;
    //assign v_if.m_tsn_axi_agt_if_1.clk=clk;

    // assign v_if.m_tsn_axi_agt_if_0.tready = v_if.m_tsn_axi_agt_if_1.tready ;
    // assign v_if.m_tsn_axi_agt_if_1.tdata=v_if.m_tsn_axi_agt_if_0.tdata;
    // assign v_if.m_tsn_axi_agt_if_1.tvalid=v_if.m_tsn_axi_agt_if_0.tvalid;
//clock & rst_n
initial begin
    clk = 0;
    rst_n = 1;
    fork
        forever begin
            #4 clk = ~clk;
        end
        begin
           repeat(1)@(posedge clk);
            rst_n = ~rst_n;
            @(posedge clk);
            rst_n = ~rst_n; 
        end
    join_none
end
//configuretion
initial begin
    uvm_config_db#(virtual lin_env_if)::set(uvm_root::get(),"uvm_test_top.env","lin_env_intf",intf);
    run_test("my_case0");
end
initial begin  
    $fsdbDumpfile("lin_tb_top.fsdb");
	$fsdbDumpvars(0,lin_tb_top); 
    $fsdbDumpMDA();
    $vcdplusmemon();
    $vcdpluson;
end
endmodule