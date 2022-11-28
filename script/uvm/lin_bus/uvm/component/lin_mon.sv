`ifndef LIN_MON_SV
`define LIN_MON_SV

typedef class lin_mon;

class lin_mon_callbacks extends uvm_callback;
    // Called at start of observed transaction
    extern virtual function void pre_trans(lin_mon mon,lin_trans trans);
    // Called before acknowledging a transaction   
    extern virtual function void post_trans(lin_mon mon,lin_trans trans);
    // Called at end of observed transaction
    extern virtual function void pre_ack (lin_mon mon,lin_trans trans);
    // Callback method post_cb_trans lin be used for coverage
    extern virtual function void post_cb_trans(lin_mon mon,lin_trans trans);
    //Callback method at the end of receive data
    extern virtual function void post_receive(lin_mon mon,lin_trans trans);
endclass:lin_mon_callbacks

function void lin_mon_callbacks::pre_trans(lin_mon mon,lin_trans trans);

endfunction:pre_trans

function void lin_mon_callbacks::post_trans(lin_mon mon,lin_trans trans);

endfunction:post_trans

function void lin_mon_callbacks::pre_ack(lin_mon mon,lin_trans trans);

endfunction:pre_ack

function void lin_mon_callbacks::post_cb_trans(lin_mon mon,lin_trans trans);

endfunction:post_cb_trans

function void lin_mon_callbacks::post_receive(lin_mon mon,lin_trans trans);

endfunction:post_receive

class lin_mon extends uvm_monitor;
    virtual lin_agt_if intf;
    uvm_analysis_port#(lin_trans) mon_analysis_port_tx;
    uvm_analysis_port#(lin_trans) mon_analysis_port_rx;

    lin_trans          tx_copy;
    lin_trans          rx_copy;
    lin_agt_cfg        cfg;
    int                error_mark = 0;
    `uvm_component_utils(lin_mon)
    `uvm_register_cb(lin_mon,lin_mon_callbacks)
    extern function new (string name ,uvm_component parent);
    extern virtual function  void build_phase(uvm_phase phase);
    extern virtual function  void connect_phase(uvm_phase phase);
    extern virtual function  void end_of_elaboration_phase(uvm_phase phase);
    extern virtual function  void start_of_simulation_phase(uvm_phase phase);
    extern virtual task reset_phase(uvm_phase phase);
    extern virtual task configure_phase(uvm_phase phase);
    extern virtual task main_phase(uvm_phase phase);
    extern virtual task monitor();

endclass

function lin_mon::new(string name,uvm_component parent);
    super.new(name,parent);
    mon_analysis_port_tx = new("mon_analysis_port_tx",this);
    mon_analysis_port_rx = new("mon_analysis_port_rx",this);
endfunction:new

function void lin_mon::build_phase(uvm_phase phase);
    super.build_phase(phase);
    if(!uvm_config_db#(virtual lin_agt_if)::get(this,"","lin_agt_if",intf))
        `uvm_fatal(get_type_name(),"lin not get the virtual interface handle")
    if(!uvm_config_db#(lin_agt_cfg)::get(this,"","lin_agt_cfg",cfg))begin
        `uvm_info(get_type_name(),"lin not get the cfg through the uvm_config_db",UVM_LOW)
        cfg = lin_agt_cfg::type_id::create("cfg");
    end
    else begin
        `uvm_info(get_type_name(),"print cfg",UVM_LOW)
        cfg.print();
    end
endfunction:build_phase

function void lin_mon::connect_phase(uvm_phase phase);
    super.connect_phase(phase);
endfunction:connect_phase

function void lin_mon::end_of_elaboration_phase(uvm_phase phase);
    super.end_of_elaboration_phase(phase);
endfunction:end_of_elaboration_phase

function void lin_mon::start_of_simulation_phase(uvm_phase phase);
    super.start_of_simulation_phase(phase);
endfunction:start_of_simulation_phase

task lin_mon::reset_phase(uvm_phase phase);
    super.reset_phase(phase);
endtask:reset_phase

task lin_mon::configure_phase(uvm_phase phase);
    super.configure_phase(phase);
endtask:configure_phase

task lin_mon::main_phase(uvm_phase phase);
    super.main_phase(phase);
        monitor();
endtask:main_phase

task lin_mon::monitor();
    fork
        //monitor tx 
        forever begin
            lin_trans tx_tr;
            bit [7:0] temp_data;
            bit [7:0] temp_identifier;
            tx_tr = new(); 
            tx_tr.lin_break        = 0;
            tx_tr.response_space   = 0;
            `uvm_do_callbacks(lin_mon,lin_mon_callbacks,pre_trans(this,tx_tr))
            `uvm_info(get_type_name(),"monitor the transfer of tx",UVM_DEBUG)
            //check the break field && receive the data of lin_break 
            while(intf.tx ==0)begin
                @(intf.cb_mon);
                tx_tr.lin_break = tx_tr.lin_break + 1;
            end
            //check the sync field
            @(negedge intf.tx)//detect the start bit
            //receive the data of sync 
            repeat(8)begin
                @(intf.cb_mon);
                tx_tr.sync[7] = intf.tx;
                tx_tr.sync = tx_tr.sync >> 1;     
            end
            //check the protected identifier field
            @(negedge intf.tx)//detect the start bit
            //receive the data of identifier
            repeat(8)begin
                @(intf.cb_mon);
                tx_tr.identifier[7] = intf.tx;
                tx_tr.identifier = tx_tr.identifier >> 1;
            end
            //check the data_lenth by identifier according to the user_define 
            if(tx_tr.identifier == 10)begin
                @(negedge intf.tx)//detect the start bit
                //check the data lenth
                temp_identifier = tx_tr.identifier;
                for(int i=0;i<cfg.identifier_list[temp_identifier];i=i+1)begin
                    repeat(8)begin
                        @(intf.cb_mon);
                        temp_data[7] = intf.tx;
                        temp_data = temp_data >> 1;
                    end
                    tx_tr.data_mon.push_back(temp_data);
                end
                //check the checksum field
                @(negedge intf.tx)//detect the start bit
                repeat(8)begin
                    @(intf.cb_mon);
                    tx_tr.checksum[7] = intf.tx;
                    tx_tr.checksum = tx_tr.checksum >> 1;
                end
                `uvm_info(get_type_name(),"monitor the tx bus with the HEADER and RESPONSE",UVM_DEBUG)
            end
            else begin
                `uvm_info(get_type_name(),"monitor the tx bus with the HEADER only",UVM_DEBUG)
            end
            `uvm_do_callbacks(lin_mon,lin_mon_callbacks,pre_ack(this,tx_tr))
            `uvm_info(get_type_name(),"Collected the data from the lin tx bus successful",UVM_DEBUG)
            void'($cast(tx_copy,tx_tr.clone()));
            // `uvm_info(get_type_name(),tx_copy.convert2string(),UVM_DEBUG)
            tx_copy.sprint();
            mon_analysis_port_tx.write(tx_copy);
        end
        //monitor rx
        forever begin
            bit [7:0] temp_data;
            bit [7:0] temp_identifier;
            lin_trans rx_tr;
            rx_tr = new();  
            rx_tr.lin_break        = 0;
            rx_tr.response_space   = 0;
            `uvm_do_callbacks(lin_mon,lin_mon_callbacks,pre_trans(this,rx_tr))
            `uvm_info(get_type_name(),"monitor the transfer of tx",UVM_DEBUG)
            //check the break field && receive the data of lin_break 
            while(intf.rx ==0)begin
                @(intf.cb_mon);
                rx_tr.lin_break = rx_tr.lin_break + 1;
            end
            //check the sync field
            @(negedge intf.rx)//detect the start bit
            //receive the data of sync 
            repeat(8)begin
                @(intf.cb_mon);
                rx_tr.sync[7] = intf.rx;
                rx_tr.sync = rx_tr.sync >> 1;     
            end
            //check the protected identifier field
            @(negedge intf.rx)//detect the start bit
            //receive the data of identifier
            repeat(8)begin
                @(intf.cb_mon);
                rx_tr.identifier[7] = intf.rx;
                rx_tr.identifier = rx_tr.identifier >> 1;
            end
            //check the data_lenth by identifier according to the user_define 
            //if(rx_tr.identifier == 10)begin
                @(negedge intf.rx)//detect the start bit
                //check the data lenth
                temp_identifier = rx_tr.identifier;
                for(int i=0;i<cfg.identifier_list[temp_identifier];i=i+1)begin
                    repeat(8)begin
                        @(intf.cb_mon);
                        temp_data[7] = intf.rx;
                        temp_data = temp_data >> 1;
                    end
                    rx_tr.data_mon.push_back(temp_data);
                end
                //check the checksum field
                @(negedge intf.rx)//detect the start bit
                repeat(8)begin
                    @(intf.cb_mon);
                    rx_tr.checksum[7] = intf.rx;
                    rx_tr.checksum    = rx_tr.checksum >> 1;
                end
                `uvm_info(get_type_name(),"monitor the rx bus with the HEADER and RESPONSE",UVM_DEBUG)
            // end
            // else begin
            //     `uvm_info(get_type_name(),"monitor the rx bus with the HEADER only",UVM_DEBUG)
            // end
            `uvm_do_callbacks(lin_mon,lin_mon_callbacks,post_receive(this,rx_tr))
            `uvm_info(get_type_name(),"Collected the data from the lin rx bus",UVM_DEBUG)
            void'($cast(rx_copy,rx_tr.clone()));
            rx_copy.sprint();
            mon_analysis_port_rx.write(rx_copy);
        end
    join   
endtask:monitor

`endif