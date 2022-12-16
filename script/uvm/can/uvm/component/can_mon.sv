`ifndef CAN_MON_SV
`define CAN_MON_SV

typedef class can_mon;

class can_mon_callbacks extends uvm_callback;
    // Called at start of observed transaction
    extern virtual function void pre_trans(can_mon mon,can_trans trans);
    // Called before acknowledging a transaction   
    extern virtual function void post_trans(can_mon mon,can_trans trans);
    // Called at end of observed transaction
    extern virtual function void pre_ack (can_mon mon,can_trans trans);
    // Callback method post_cb_trans can be used for coverage
    extern virtual function void post_cb_trans(can_mon mon,can_trans trans);
    //Callback method at the end of receive data
    extern virtual function void post_receive(can_mon mon,can_trans trans);
endclass:can_mon_callbacks

function void can_mon_callbacks::pre_trans(can_mon mon,can_trans trans);

endfunction:pre_trans

function void can_mon_callbacks::post_trans(can_mon mon,can_trans trans);

endfunction:post_trans

function void can_mon_callbacks::pre_ack(can_mon mon,can_trans trans);

endfunction:pre_ack

function void can_mon_callbacks::post_cb_trans(can_mon mon,can_trans trans);

endfunction:post_cb_trans

function void can_mon_callbacks::post_receive(can_mon mon,can_trans trans);

endfunction:post_receive

class can_mon extends uvm_monitor;
    virtual can_agt_if intf;
    uvm_analysis_port#(can_trans) mon_analysis_port_tx;
    uvm_analysis_port#(can_trans) mon_analysis_port_rx;

    can_trans          tx_copy;
    can_trans          rx_copy;
    can_agt_cfg        cfg;
    int                i,j,error_mark = 0;
    `uvm_component_utils(can_mon)
    `uvm_register_cb(can_mon,can_mon_callbacks)
    extern function new (string name ,uvm_component parent);
    extern virtual function  void build_phase(uvm_phase phase);
    extern virtual function  void connect_phase(uvm_phase phase);
    extern virtual function  void end_of_elaboration_phase(uvm_phase phase);
    extern virtual function  void start_of_simulation_phase(uvm_phase phase);
    extern virtual task reset_phase(uvm_phase phase);
    extern virtual task configure_phase(uvm_phase phase);
    extern virtual task main_phase(uvm_phase phase);
    extern virtual task monitor();
    extern virtual task monitor_rx();
    extern virtual task monitor_tx();
endclass

function can_mon::new(string name,uvm_component parent);
    super.new(name,parent);
    mon_analysis_port_tx = new("mon_analysis_port_tx",this);
    mon_analysis_port_rx = new("mon_analysis_port_rx",this);
endfunction:new

function void can_mon::build_phase(uvm_phase phase);
    super.build_phase(phase);
    if(!uvm_config_db#(virtual can_agt_if)::get(this,"","can_agt_if",intf))
        `uvm_fatal(get_type_name(),"can not get the virtual interface handle")
    if(!uvm_config_db#(can_agt_cfg)::get(this,"","can_agt_cfg",cfg))begin
        `uvm_info(get_type_name(),"can not get the cfg through the uvm_config_db",UVM_LOW)
        cfg = can_agt_cfg::type_id::create("cfg");
    end
    else begin
        `uvm_info(get_type_name(),"print cfg",UVM_LOW)
        cfg.print();
    end
endfunction:build_phase

function void can_mon::connect_phase(uvm_phase phase);
    super.connect_phase(phase);
endfunction:connect_phase

function void can_mon::end_of_elaboration_phase(uvm_phase phase);
    super.end_of_elaboration_phase(phase);
endfunction:end_of_elaboration_phase

function void can_mon::start_of_simulation_phase(uvm_phase phase);
    super.start_of_simulation_phase(phase);
endfunction:start_of_simulation_phase

task can_mon::reset_phase(uvm_phase phase);
    super.reset_phase(phase);
endtask:reset_phase

task can_mon::configure_phase(uvm_phase phase);
    super.configure_phase(phase);
endtask:configure_phase

task can_mon::main_phase(uvm_phase phase);
    super.main_phase(phase);
        monitor();
endtask:main_phase

task can_mon::monitor();
    fork
        forever begin
            monitor_tx();
        end
        forever begin
            monitor_rx();
        end
    join
endtask:monitor

task can_mon::monitor_rx();
    can_trans rx_mon;
    bit [7:0]   data_temp;
    bit         ack_slot;
    rx_mon = new("rx_mon");
    //check the rst_n
    `uvm_info(get_type_name(),"monitor the transfer of rx",UVM_HIGH)
    @(posedge intf.rst_n);
    //check the sof exclude ack slot
    @(intf.cb_mon1 iff (intf.rx == 0 && intf.tx ==1))begin
        //collect the identify id 
        `uvm_info(get_type_name(),"Starting collection the bus rx data",UVM_LOW)
        repeat(11)begin 
            @(intf.cb_mon1);
            rx_mon.identify_can[0]      <= intf.cb_mon1.rx;
            rx_mon.identify_can_fd[0]   <= intf.cb_mon1.rx;
            rx_mon.identify_can     = rx_mon.identify_can << 1;
            rx_mon.identify_can_fd  = rx_mon.identify_can_fd << 1;           
        end
        //collect the rtr(can) or r1(can_fd)
        @(intf.cb_mon1);
        rx_mon.rtr_can      <= intf.cb_mon1.rx;
        rx_mon.r1_can_fd    <= intf.cb_mon1.rx;
        //collect the ide
        @(intf.cb_mon1);
        rx_mon.ide_can      <= intf.cb_mon1.rx;
        rx_mon.ide_can_fd   <= intf.cb_mon1.rx; 
        //collect the edl(can_rd) or r0(can)
        @(intf.cb_mon1);
        rx_mon.r0_can       <= intf.cb_mon1.rx;
        rx_mon.edl_can_fd   <= intf.cb_mon1.rx;               
        if(rx_mon.edl_can_fd == 0)begin//can fram
            //collect dlc
            repeat(4)begin
               @(intf.cb_mon1);
               rx_mon.dlc_can[0] <= intf.cb_mon1.rx;
               rx_mon.dlc_can = rx_mon.dlc_can << 1; 
            end
            //collect data
            for(i=0;i<rx_mon.dlc_can;i++)begin
                repeat(8)begin
                    @(intf.cb_mon1);
                    data_temp[0] = intf.cb_mon1.rx;
                    data_temp = data_temp <<1;
                end
                rx_mon.data_collect.push_back(data_temp);
            end
            //collect crc_sequence
            repeat(15)begin
                @(intf.cb_mon1);
                rx_mon.crc_sequence_can[0]  <= intf.cb_mon1.rx;
                rx_mon.crc_sequence_can     = rx_mon.crc_sequence_can << 1;
            end
            //delay crc_delimiter
            @(intf.cb_mon1);
            //detect the ack slot
            @(intf.cb_mon1);
            ack_slot = intf.cb_mon1.rx;
            if(ack_slot == 0)begin
                `uvm_info(get_type_name(),"monior the rx successful",UVM_HIGH)
                rx_mon.sprint();
            end
            else begin
                `uvm_error(get_type_name(),"monior the rx failure")
            end
        end
        else begin//can_fd fram
            //collect r0;
            @(intf.cb_mon1);
            rx_mon.r0_can_fd <= intf.cb_mon1.rx;
            //collect brs
            @(intf.cb_mon1);
            rx_mon.brs_can_fd <= intf.cb_mon1.rx;
            if(rx_mon.brs_can_fd == 0)begin//20MHz
                //collect esi
                @(intf.cb_mon2);
                rx_mon.esi_can_fd <= intf.cb_mon2.rx;
                //collect dlc
                repeat(4)begin
                   @(intf.cb_mon2);
                   rx_mon.dlc_can[0] <= intf.cb_mon2.rx;
                   rx_mon.dlc_can = rx_mon.dlc_can << 1; 
                end
                //collect data
                for(i=0;i<rx_mon.dlc_can;i++)begin
                    repeat(8)begin
                        @(intf.cb_mon2);
                        data_temp[0] = intf.cb_mon2.rx;
                        data_temp = data_temp <<1;
                    end
                    rx_mon.data_collect.push_back(data_temp);
                end
                //collect stuff_count
                repeat(4)begin
                   @(intf.cb_mon2);
                   rx_mon.stuff_count_can_rd[0] <= intf.cb_mon2.rx;
                   rx_mon.stuff_count_can_rd = rx_mon.stuff_count_can_rd << 1;
                end
                //collect crc_sequence
                if(rx_mon.data_collect.size <= 16)begin
                    repeat(17)begin
                        @(intf.cb_mon2);
                        rx_mon.crc_can_fd1[0]  <= intf.cb_mon2.rx;
                        rx_mon.crc_can_fd1     = rx_mon.crc_can_fd1 << 1;
                    end
                end
                else begin
                    repeat(21)begin
                        @(intf.cb_mon2);
                        rx_mon.crc_can_fd2[0]  <= intf.cb_mon2.rx;
                        rx_mon.crc_can_fd2     = rx_mon.crc_can_fd2 << 1;
                    end
                end
                //delay crc_delimiter
                @(intf.cb_mon2);
                //detect the ack slot
                @(intf.cb_mon1);
                ack_slot = intf.cb_mon1.rx;
                if(ack_slot == 0)begin
                    `uvm_info(get_type_name(),"monior the rx successful",UVM_HIGH)
                    rx_mon.sprint();
                end
                else begin
                    `uvm_info(get_type_name(),"monior the rx failure",UVM_HIGH)
                end
                //delay 8 cycle of ack delimiter,eof
                repeat(8)@(intf.cb_mon1);
                //collect ifs
                repeat(3)begin
                    @(intf.cb_mon1);
                    rx_mon.ifs_can_fd[0] <= intf.cb_mon1.rx;
                    rx_mon.ifs_can_fd = rx_mon.ifs_can_fd << 1;
                end
            end
            else begin//500KHz
                //collect esi
                @(intf.cb_mon1);
                rx_mon.esi_can_fd <= intf.cb_mon1.rx;
                //collect dlc
                repeat(4)begin
                    @(intf.cb_mon1);
                    rx_mon.dlc_can[0] <= intf.cb_mon1.rx;
                    rx_mon.dlc_can = rx_mon.dlc_can << 1; 
                 end
                 //collect data
                 for(i=0;i<rx_mon.dlc_can;i++)begin
                     repeat(8)begin
                         @(intf.cb_mon1);
                         data_temp[0] = intf.cb_mon1.rx;
                         data_temp = data_temp <<1;
                     end
                     rx_mon.data_collect.push_back(data_temp);
                 end
                 //collect stuff_count
                 repeat(4)begin
                    @(intf.cb_mon1);
                    rx_mon.stuff_count_can_rd[0] <= intf.cb_mon1.rx;
                    rx_mon.stuff_count_can_rd = rx_mon.stuff_count_can_rd << 1;
                 end
                 //collect crc_sequence
                 if(rx_mon.data_collect.size <= 16)begin
                    repeat(17)begin
                        @(intf.cb_mon1);
                        rx_mon.crc_can_fd1[0]  <= intf.cb_mon1.rx;
                        rx_mon.crc_can_fd1     = rx_mon.crc_can_fd1 << 1;
                    end
                end
                else begin
                    repeat(21)begin
                        @(intf.cb_mon1);
                        rx_mon.crc_can_fd2[0]  <= intf.cb_mon1.rx;
                        rx_mon.crc_can_fd2     = rx_mon.crc_can_fd2 << 1;
                    end
                end
                //delay crc_delimiter
                @(intf.cb_mon1);
                //detect the ack slot
                @(intf.cb_mon1);
                ack_slot = intf.cb_mon1.rx;
                if(ack_slot == 0)begin
                    `uvm_info(get_type_name(),"monior the rx successful",UVM_HIGH)
                    rx_mon.sprint();
                end
                else begin
                    `uvm_info(get_type_name(),"monior the rx failure",UVM_HIGH)
                end
                //delay 8 cycle of ack delimiter,eof
                repeat(8)@(intf.cb_mon1);
                //collect ifs
                repeat(3)begin
                    @(intf.cb_mon1);
                    rx_mon.ifs_can_fd[0] <= intf.cb_mon1.rx;
                    rx_mon.ifs_can_fd = rx_mon.ifs_can_fd << 1;
                end
            end
        end
    end
    `uvm_do_callbacks(can_mon,can_mon_callbacks,post_receive(this,rx_mon))
    `uvm_info(get_type_name(),"Collected the data from the can rx bus",UVM_HIGH)
    void'($cast(rx_copy,rx_mon.clone()));
    `uvm_info(get_type_name(),rx_copy.sprint(),UVM_HIGH)
    mon_analysis_port_rx.write(rx_copy);
endtask:monitor_rx

task can_mon::monitor_tx();
    can_trans tx_mon;
    bit [7:0] data_temp;
    bit ack_slot;
    tx_mon = new("tx_mon");
    //check the rst_n
    `uvm_info(get_type_name(),"monitor the transfer of rx",UVM_HIGH)
    @(posedge intf.rst_n);
    //check the sof exclude ack slot
    @(intf.cb_mon1 iff (intf.tx == 0 && intf.rx ==1))begin
        //collect the identify id 
        `uvm_info(get_type_name(),"Starting collection the bus tx data",UVM_LOW)
        repeat(11)begin 
            @(intf.cb_mon1);
            tx_mon.identify_can[0]      <= intf.cb_mon1.tx;
            tx_mon.identify_can_fd[0]   <= intf.cb_mon1.tx;
            tx_mon.identify_can     = tx_mon.identify_can << 1;
            tx_mon.identify_can_fd  = tx_mon.identify_can_fd << 1;           
        end
        //collect the rtr(can) or r1(can_fd)
        @(intf.cb_mon1);
        tx_mon.rtr_can      <= intf.cb_mon1.tx;
        tx_mon.r1_can_fd    <= intf.cb_mon1.tx;
        //collect the ide
        @(intf.cb_mon1);
        tx_mon.ide_can      <= intf.cb_mon1.tx;
        tx_mon.ide_can_fd   <= intf.cb_mon1.tx; 
        //collect the edl(can_rd) or r0(can)
        @(intf.cb_mon1);
        tx_mon.r0_can       <= intf.cb_mon1.tx;
        tx_mon.edl_can_fd   <= intf.cb_mon1.tx;               
        if(tx_mon.edl_can_fd == 0)begin//can fram
            //collect dlc
            repeat(4)begin
               @(intf.cb_mon1);
               tx_mon.dlc_can[0] <= intf.cb_mon1.tx;
               tx_mon.dlc_can = tx_mon.dlc_can << 1; 
            end
            //collect data
            for(i=0;i<tx_mon.dlc_can;i++)begin
                repeat(8)begin
                    @(intf.cb_mon1);
                    data_temp[0] = intf.cb_mon1.tx;
                    data_temp = data_temp <<1;
                end
                tx_mon.data_collect.push_back(data_temp);
            end
            //collect crc_sequence
            repeat(15)begin
                @(intf.cb_mon1);
                tx_mon.crc_sequence_can[0]  <= intf.cb_mon1.tx;
                tx_mon.crc_sequence_can     = tx_mon.crc_sequence_can << 1;
            end
            //delay crc_delimiter
            @(intf.cb_mon1);
            //detect the ack slot
            @(intf.cb_mon1);
            ack_slot = intf.cb_mon1.tx;
            if(ack_slot == 0)begin
                `uvm_info(get_type_name(),"monior the tx successful",UVM_HIGH)
                tx_mon.sprint();
            end
            else begin
                `uvm_error(get_type_name(),"monior the tx failure")
            end
        end
        else begin//can_fd fram
            //collect r0;
            @(intf.cb_mon1);
            tx_mon.r0_can_fd <= intf.cb_mon1.tx;
            //collect brs
            @(intf.cb_mon1);
            tx_mon.brs_can_fd <= intf.cb_mon1.tx;
            if(tx_mon.brs_can_fd == 0)begin//20MHz
                //collect esi
                @(intf.cb_mon2);
                tx_mon.esi_can_fd <= intf.cb_mon2.tx;
                //collect dlc
                repeat(4)begin
                   @(intf.cb_mon2);
                   tx_mon.dlc_can[0] <= intf.cb_mon2.tx;
                   tx_mon.dlc_can = tx_mon.dlc_can << 1; 
                end
                //collect data
                for(i=0;i<tx_mon.dlc_can;i++)begin
                    repeat(8)begin
                        @(intf.cb_mon2);
                        data_temp[0] = intf.cb_mon2.tx;
                        data_temp = data_temp <<1;
                    end
                    tx_mon.data_collect.push_back(data_temp);
                end
                //collect stuff_count
                repeat(4)begin
                   @(intf.cb_mon2);
                   tx_mon.stuff_count_can_rd[0] <= intf.cb_mon2.tx;
                   tx_mon.stuff_count_can_rd = tx_mon.stuff_count_can_rd << 1;
                end
                //collect crc_sequence
                if(tx_mon.data_collect.size <= 16)begin
                    repeat(17)begin
                        @(intf.cb_mon2);
                        tx_mon.crc_can_fd1[0]  <= intf.cb_mon2.tx;
                        tx_mon.crc_can_fd1     = tx_mon.crc_can_fd1 << 1;
                    end
                end
                else begin
                    repeat(21)begin
                        @(intf.cb_mon2);
                        tx_mon.crc_can_fd2[0]  <= intf.cb_mon2.tx;
                        tx_mon.crc_can_fd2     = tx_mon.crc_can_fd2 << 1;
                    end
                end
                //delay crc_delimiter
                @(intf.cb_mon2);
                //detect the ack slot
                @(intf.cb_mon1);
                ack_slot = intf.cb_mon1.tx;
                if(ack_slot == 0)begin
                    `uvm_info(get_type_name(),"monior the rx successful",UVM_HIGH)
                    tx_mon.sprint();
                end
                else begin
                    `uvm_info(get_type_name(),"monior the rx failure",UVM_HIGH)
                end
                //delay 8 cycle of ack delimiter,eof
                repeat(8)@(intf.cb_mon1);
                //collect ifs
                repeat(3)begin
                    @(intf.cb_mon1);
                    tx_mon.ifs_can_fd[0] <= intf.cb_mon1.tx;
                    tx_mon.ifs_can_fd = tx_mon.ifs_can_fd << 1;
                end
            end
            else begin//500KHz
                //collect esi
                @(intf.cb_mon1);
                tx_mon.esi_can_fd <= intf.cb_mon1.tx;
                //collect dlc
                repeat(4)begin
                    @(intf.cb_mon1);
                    tx_mon.dlc_can[0] <= intf.cb_mon1.tx;
                    tx_mon.dlc_can = tx_mon.dlc_can << 1; 
                 end
                 //collect data
                 for(i=0;i<tx_mon.dlc_can;i++)begin
                     repeat(8)begin
                         @(intf.cb_mon1);
                         data_temp[0] = intf.cb_mon1.tx;
                         data_temp = data_temp <<1;
                     end
                     tx_mon.data_collect.push_back(data_temp);
                 end
                 //collect stuff_count
                 repeat(4)begin
                    @(intf.cb_mon1);
                    tx_mon.stuff_count_can_rd[0] <= intf.cb_mon1.tx;
                    tx_mon.stuff_count_can_rd = tx_mon.stuff_count_can_rd << 1;
                 end
                 //collect crc_sequence
                 if(tx_mon.data_collect.size <= 16)begin
                    repeat(17)begin
                        @(intf.cb_mon1);
                        tx_mon.crc_can_fd1[0]  <= intf.cb_mon1.tx;
                        tx_mon.crc_can_fd1     = tx_mon.crc_can_fd1 << 1;
                    end
                end
                else begin
                    repeat(21)begin
                        @(intf.cb_mon1);
                        tx_mon.crc_can_fd2[0]  <= intf.cb_mon1.tx;
                        tx_mon.crc_can_fd2     = tx_mon.crc_can_fd2 << 1;
                    end
                end
                //delay crc_delimiter
                @(intf.cb_mon1);
                //detect the ack slot
                @(intf.cb_mon1);
                ack_slot = intf.cb_mon1.tx;
                if(ack_slot == 0)begin
                    `uvm_info(get_type_name(),"monior the rx successful",UVM_HIGH)
                    tx_mon.sprint();
                end
                else begin
                    `uvm_info(get_type_name(),"monior the rx failure",UVM_HIGH)
                end
                //delay 8 cycle of ack delimiter,eof
                repeat(8)@(intf.cb_mon1);
                //collect ifs
                repeat(3)begin
                    @(intf.cb_mon1);
                    tx_mon.ifs_can_fd[0] <= intf.cb_mon1.tx;
                    tx_mon.ifs_can_fd = tx_mon.ifs_can_fd << 1;
                end
            end
        end
    end
    `uvm_do_callbacks(can_mon,can_mon_callbacks,pre_ack(this,tx_mon))
    `uvm_info(get_type_name(),"Collected the data from the can tx bus",UVM_DEBUG)
    void'($cast(tx_copy,tx_mon.clone()));
    `uvm_info(get_type_name(),tx_copy.convert2string(),UVM_DEBUG)
    mon_analysis_port_tx.write(tx_copy);
endtask:monitor_tx
`endif