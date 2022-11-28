`ifndef LIN_SCB_SV
`define LIN_SCB_SV

//uvm_subscriber
class lin_scb extends uvm_scoreboard;
    `uvm_component_utils(lin_scb)
//uvm_blocking_get_port是一个TLM事务级端口，用于接收由uvm_analysis_port发送的信息，
//uvm_analysis_port是发送信息的端口，其发送的消息会被前面的端口所接收。
//uvm验证平台可以使用uvm_tlm_analysis_fifo把uvm_blocking_get_port和uvm_analysis_port连接；
    uvm_blocking_get_port#(lin_trans) monitor2scoboard_tx_port;
    uvm_blocking_get_port#(lin_trans) monitor2scoboard_rx_port;
    uvm_blocking_get_port#(lin_trans) refmodel2scoboard_tx_port;
    uvm_blocking_get_port#(lin_trans) refmodel2scoboard_rx_port;

//for coverage_group establish
    uvm_subscriber m_mon_sub;
//variable define
    lin_trans       actual_rx_data; 
    lin_trans       expect_rx_data;
    lin_trans       actual_tx_data;
    lin_trans       expect_tx_data;
    extern function new (string name , uvm_component parent);
    extern virtual function void build_phase(uvm_phase phase);
    extern virtual function void connect_phase(uvm_phase phase);
    extern virtual function void end_of_elaboration_phase(uvm_phase phase);
    extern virtual function void start_of_simulation_phase(uvm_phase phase);
    extern virtual task reset_phase(uvm_phase phase);
    extern virtual task configure_phase(uvm_phase phase);
    extern virtual task main_phase(uvm_phase phase);
    extern virtual task data_comparer(); 
endclass:lin_scb

function lin_scb::new(string name,uvm_component parent);
    super.new(name,parent);
    monitor2scoboard_tx_port = new("monitor2scoboard_tx_port",this);
    monitor2scoboard_rx_port = new("monitor2scoboard_rx_port",this);
    refmodel2scoboard_tx_port = new("refmodel2scoboard_tx_port",this);
    refmodel2scoboard_rx_port = new("refmodel2scoboard_rx_port",this);
endfunction:new

function void lin_scb::build_phase(uvm_phase phase);
    super.build_phase(phase);
endfunction:build_phase

function void lin_scb::connect_phase(uvm_phase phase);
    super.connect_phase(phase);
endfunction:connect_phase

function void lin_scb::end_of_elaboration_phase(uvm_phase phase);
    super.end_of_elaboration_phase(phase);
endfunction:end_of_elaboration_phase

function void lin_scb::start_of_simulation_phase(uvm_phase phase);
    super.start_of_simulation_phase(phase);
endfunction:start_of_simulation_phase

task lin_scb::reset_phase(uvm_phase phase);
    super.reset_phase(phase);
endtask:reset_phase

task lin_scb::configure_phase(uvm_phase phase);
    super.configure_phase(phase);
endtask:configure_phase

task lin_scb::main_phase(uvm_phase phase);
    //no reference model
//        data_comparer();
endtask:main_phase

task lin_scb::data_comparer();
    fork
        forever begin
            `uvm_info(get_type_name(),"Begin to compare the actual rx data to expect rx data",UVM_LOW)
            //get_data
                monitor2scoboard_rx_port.get(actual_rx_data);
                refmodel2scoboard_rx_port.get(expect_rx_data);
            `uvm_info("rx_check","Begin to check the actual rx data to expect rx data",UVM_LOW)
            if(expect_rx_data.compare(actual_rx_data))
                `uvm_info("rx_check_success","The expect rx data is equal to actual rx data",UVM_LOW)
            else begin
                `uvm_info("rx_check_error","The expect rx data is not equal to actual rx data",UVM_LOW)
                actual_rx_data.sprint();
                expect_rx_data.sprint();
            end
        end
        forever begin
            `uvm_info(get_type_name(),"Begin to compare the actual tx data to expect tx data",UVM_LOW)
                monitor2scoboard_tx_port.peek(actual_tx_data);
                refmodel2scoboard_tx_port.get(expect_tx_data);
            `uvm_info("tx_check","Begin to check the actual tx data to expect tc data",UVM_LOW)
            if(expect_tx_data.compare(actual_tx_data))
                `uvm_info("tx_check_success","The expect rx data is equal to actual rx data",UVM_LOW)
            else begin
                `uvm_info("tx_check_error","The expect rx data is not equal to actual rx data",UVM_LOW)
                actual_tx_data.sprint();
                expect_tx_data.sprint();
            end
        end
    join
endtask:data_comparer
`endif