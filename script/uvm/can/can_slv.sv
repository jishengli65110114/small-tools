`ifndef CAN_SLV_SV
`define CAN_SLV_SV

typedef class can_slv;
class can_slv_callbacks extends uvm_callback;
    // Called at start of observed transaction
    extern virtual function void pre_trans(can_slv slv,can_trans trans);
    // Called at end of observed transaction
    extern virtual function void post_trans(can_slv slv,can_trans trans);
    // Called before acknowledging a transaction
    extern virtual function void pre_ack(can_slv slv,can_trans trans);
    // Callback method post_cb_trans can be used for coverage
    extern virtual function void post_cb_trans(can_slv slv,can_trans trans);

endclass
//call back function define
function void can_slv_callbacks::pre_trans(can_slv slv,can_trans trans);
    // if(trans.data_can.size == 0)
    //     `uvm_fatal(get_type_name(),"There are no trans at the phase of pre_trans")
    // else 
    //     `uvm_info(get_type_name(),$sformatf("the trans is %s at the phase of pre_trans",trans.convert2string()),UVM_DEBUG)
endfunction:pre_trans

function void can_slv_callbacks::post_trans(can_slv slv,can_trans trans);
    // if(trans.data_can.size == 0)
    //     `uvm_fatal(get_type_name(),"The trans had change at the phase of post_trans")
    // else 
    //     `uvm_info(get_type_name(),$sformatf("The trans is %s at the phase of post_trans",trans.convert2string()),UVM_DEBUG)
endfunction:post_trans

function void can_slv_callbacks::pre_ack(can_slv slv,can_trans trans);
    // if(trans.data_can.size == 0)
    //     `uvm_fatal(get_type_name(),"There are no trans at the phase of pre_ack")
    // else  
    //     `uvm_info(get_type_name(),$sformatf("The trans is %s at the phase of pre_ack",trans.convert2string()),UVM_DEBUG)
endfunction:pre_ack

function void can_slv_callbacks::post_cb_trans(can_slv slv,can_trans trans);
    // if(trans.data_can.size == 0)
    //     `uvm_fatal(get_type_name(),"There are no trans at the phase of post_cb_trans")
    // else 
    //     `uvm_info(get_type_name(),$sformatf("The trans is %s at the phase of post_cb_trans",trans.convert2string()),UVM_DEBUG)
endfunction:post_cb_trans

class can_slv extends uvm_driver #(can_trans);
//parameter define    
    virtual can_agt_if intf;
    can_trans req,rsp;
    can_agt_cfg cfg;
    uvm_analysis_port #(can_trans) mon_analysis_port; //for self test
    int vld_pct = 100;
    int trans_flag = 1;//0-trans successful  1-trans failure


    `uvm_component_utils(can_slv)
    `uvm_register_cb(can_slv,can_slv_callbacks)
    extern function new(string name = "can_slv",uvm_component parent = null); 
    extern virtual function void build_phase(uvm_phase phase);
    extern virtual function void connect_phase(uvm_phase phase);
    extern virtual function void end_of_elaboration_phase(uvm_phase phase);
    extern virtual function void start_of_simulation_phase(uvm_phase phase);
    extern virtual task reset_phase(uvm_phase phase);
    extern virtual task configure_phase(uvm_phase phase);
    extern virtual task main_phase(uvm_phase phase);
    extern virtual task get_items_driver();
    extern virtual task can_driver();
    extern virtual task can_fd_driver();
    extern virtual task data_receive();
    extern virtual task release_bus();
    extern virtual task reset_listener();
    // extern virtual task send(); 
endclass

//driver function define
function can_slv::new(string name ,uvm_component parent);
    super.new(name,parent);
    mon_analysis_port = new("mon_analysis_port",this);
endfunction:new

function void can_slv::build_phase(uvm_phase phase);
    if(!uvm_config_db#(virtual can_agt_if)::get(this,"","intf",intf))begin
        `uvm_fatal(get_type_name(),"No virtual interface specified for this slv instance")
    end
    if(!uvm_config_db#(can_agt_cfg)::get(this,"","cfg",cfg))begin
        cfg = can_agt_cfg::type_id::create("cfg",this);
        `uvm_info(get_type_name(),"No cfg handle be receive,then drive create this object",UVM_LOW)
    end
endfunction:build_phase

function void can_slv::connect_phase(uvm_phase phase);
    super.connect_phase(phase);
endfunction:connect_phase

function void can_slv::end_of_elaboration_phase(uvm_phase phase);
    super.end_of_elaboration_phase(phase);
endfunction:end_of_elaboration_phase

function void can_slv::start_of_simulation_phase(uvm_phase phase);
    super.start_of_simulation_phase(phase);
endfunction:start_of_simulation_phase

task can_slv::reset_phase(uvm_phase phase);
    super.reset_phase(phase);
    phase.raise_objection(this);
    reset_listener();
    phase.drop_objection(this);
endtask:reset_phase

task can_slv::configure_phase(uvm_phase phase);
    super.configure_phase(phase);
endtask:configure_phase

task can_slv::main_phase(uvm_phase phase);
    super.main_phase(phase);
    //phase.raise_objection(this);
    fork
        get_items_driver();
        // data_receive();
        reset_listener();
    join 
    //phase.drop_objection(this);
endtask:main_phase

task can_slv::get_items_driver();
    forever begin
        `uvm_do_callbacks(can_slv,can_slv_callbacks,pre_trans(this,req))
        seq_item_port.get_next_item(req);
        `uvm_info(get_type_name(),req.sprint(),UVM_LOW)
        mon_analysis_port.write(req);
        if(req.can_type == can)begin
            can_driver();
            //retry to translate
            while(trans_flag == 1)begin
                can_driver();
            end
            trans_flag = 1;
        end
        else if(req.can_type == can_fd)
            can_fd_driver();
        else `uvm_info(get_type_name(),"one error is happened at the component of driver ",UVM_DEBUG)
        void'($cast(rsp,req.clone()));
        rsp.set_sequence_id(req.get_sequence_id());
        rsp.set_transaction_id(req.get_transaction_id());
        seq_item_port.item_done(rsp);
        `uvm_info(get_type_name(),"Completed transaction...",UVM_MEDIUM)
        `uvm_do_callbacks(can_slv,can_slv_callbacks,post_trans(this,req))
        `uvm_info(get_type_name(),$sformatf("The req content is %s",req.convert2string()),UVM_HIGH)
    end
endtask:get_items_driver

task can_slv::data_receive();
    // forever begin
        //data_receiver can copy from can_mon.sv
    // end
endtask:data_receive
//typedef enum {data_frame,remote_fram,error_fram,overload_fram,gap_fram} fram_type;
task can_slv::can_driver();
    int i,j;
    case(req.data_type)
        data_frame:begin
            //sof(0)
            @(intf.cb_mst1);
            intf.cb_mst1.tx <= 0;
            //identify
            for(i=0;i<11;i++)begin
                @(intf.cb_mst1);
                intf.cb_mst1.tx <= req.identify_can[10-i];
            end
            //rtr
            @(intf.cb_mst1);
            intf.cb_mst1.tx <= req.rtr_can;
            //ide
            @(intf.cb_mst1);
            intf.cb_mst1.tx <= req.ide_can;
            //r0
            @(intf.cb_mst1);
            intf.cb_mst1.tx <= req.r0_can;
            //dlc
            for(i=0;i<4;i++)begin
                @(intf.cb_mst1);
                intf.cb_mst1.tx <= req.dlc_can[3-i];
            end
            //data
            for(i=0;i<req.dlc_can;i++)begin
                for(j=0;j<8;j++)begin
                    @(intf.cb_mst1);
                    intf.cb_mst1.tx <= req.data_can[i][7-j];
                end
            end
            //crc_sequence
            for(i=0;i<15;i++)begin
                @(intf.cb_mst1);
                intf.cb_mst1.tx <= req.crc_sequence_can[14-i];
            end
            //crc_delimiter
            @(intf.cb_mst1);
            intf.cb_mst1.tx <= 1;
            // ack slot
            @(intf.cb_mst1);
            intf.cb_mst1.tx     <= 0;//comply to actual wavefom
            trans_flag  <= intf.cb_mst1.rx;
            if(trans_flag == 0)begin
                //ack_delimiter
                @(intf.cb_mst1);
                intf.cb_mst1.tx <= 1;
                //eof
                repeat(7)begin
                    @(intf.cb_mst1);
                    intf.cb_mst1.tx <= 1;
                end
                `uvm_info(get_type_name(),"translate the message successful",UVM_DEBUG)
            end    
            else begin
                trans_flag =1;
                `uvm_info(get_type_name(),"no ack response",UVM_DEBUG) 
            end
        end        
        default:begin
            release_bus();
        end
    endcase
endtask:can_driver
task can_slv::can_fd_driver();
    int i,j;
    case(req.data_type)
        data_frame:begin
            //sof(0)
            @(intf.cb_mst1);
            intf.cb_mst1.tx <= 0;
            //identify
            for(i=0;i<11;i++)begin
                @(intf.cb_mst1);
                intf.cb_mst1.tx <= req.identify_can_fd[10-i];
            end
            //r1
            @(intf.cb_mst1);
            intf.cb_mst1.tx <= req.r1_can_fd;
            //ide
            @(intf.cb_mst1);
            intf.cb_mst1.tx <= req.ide_can_fd;
            //edl
            @(intf.cb_mst1);
            intf.cb_mst1.tx <= req.edl_can_fd;
            //r0
            @(intf.cb_mst1);
            intf.cb_mst1.tx <= req.r0_can_fd;
            //brs
            @(intf.cb_mst1);
            intf.cb_mst1.tx <= req.brs_can_fd;
            if(req.brs_can_fd == 0)begin//20MHz
                //esi
                @(intf.cb_mst2);
                intf.cb_mst2.tx <= req.esi_can_fd;
                //dlc
                for(i=0;i<4;i++)begin
                    @(intf.cb_mst2);
                    intf.cb_mst2.tx <= req.dlc_can_fd[3-i];
                end
                //data
                foreach(req.data_can_fd[i])begin
                    for(j=0;j<8;j++)begin
                        @(intf.cb_mst2);
                        intf.cb_mst2.tx <= req.data_can_fd[i][7-j];
                    end
                end
                //stuff_count
                for(i=0;i<4;i++)begin
                    @(intf.cb_mst2);
                    intf.cb_mst2.tx <= req.stuff_count_can_rd;
                end
                //crc_sequence
                if(req.data_can_fd.size<=16)begin
                    for(i=0;i<17;i++)begin
                        @(intf.cb_mst2);
                        intf.cb_mst2.tx <= req.crc_can_fd1[16-i];
                    end
                end
                else begin
                    for(i=0;i<21;i++)begin
                        @(intf.cb_mst2);
                        intf.cb_mst2.tx <= req.crc_can_fd2[20-i];
                    end
                end
                //crc_delimiter
                @(intf.cb_mst2);
                intf.cb_mst2.tx <= 1;
                // ack slot
                @(intf.cb_mst1);
                intf.cb_mst1.tx     <= 1;
                trans_flag  <= intf.cb_mst1.rx;
                if(trans_flag == 0)begin
                    //ack_delimiter
                    @(intf.cb_mst1);
                    intf.cb_mst1.tx <= 1;
                    //eof
                    repeat(7)begin
                        @(intf.cb_mst1);
                        intf.cb_mst1.tx <= 1;
                    end
                    for(i=0;i<3;i++)begin
                        @(intf.cb_mst1);
                        intf.cb_mst1.tx <= req.ifs_can_fd[2-i];
                    end
                    `uvm_info(get_type_name(),"translate the message successful at 20MHz",UVM_DEBUG)
                end    
                else begin
                    trans_flag =1;
                    `uvm_info(get_type_name(),"no ack response",UVM_DEBUG) 
                end
            end
            else begin//500kHz
                //esi
                @(intf.cb_mst1);
                intf.cb_mst1.tx <= req.esi_can_fd;
                //dlc
                for(i=0;i<4;i++)begin
                    @(intf.cb_mst1);
                    intf.cb_mst1.tx <= req.dlc_can_fd[3-i];
                end
                //data
                foreach(req.data_can_fd[i])begin
                    for(j=0;j<8;j++)begin
                        @(intf.cb_mst1);
                        intf.cb_mst1.tx <= req.data_can_fd[i][7-j];
                    end
                end
                //stuff_count
                for(i=0;i<4;i++)begin
                    @(intf.cb_mst1);
                    intf.cb_mst1.tx <= req.stuff_count_can_rd;
                end
                //crc_sequence
                if(req.data_can_fd.size<=16)begin
                    for(i=0;i<17;i++)begin
                        @(intf.cb_mst1);
                        intf.cb_mst1.tx <= req.crc_can_fd1[16-i];
                    end
                end
                else begin
                    for(i=0;i<21;i++)begin
                        @(intf.cb_mst1);
                        intf.cb_mst1.tx <= req.crc_can_fd2[20-i];
                    end
                end
                //crc_delimiter
                @(intf.cb_mst1);
                intf.cb_mst1.tx <= 1;
                // ack slot
                @(intf.cb_mst1);
                intf.cb_mst1.tx     <= 1;
                trans_flag  <= intf.cb_mst1.rx;
                if(trans_flag == 0)begin
                    //ack_delimiter
                    @(intf.cb_mst1);
                    intf.cb_mst1.tx <= 1;
                    //eof
                    repeat(7)begin
                        @(intf.cb_mst1);
                        intf.cb_mst1.tx <= 1;
                    end
                    for(i=0;i<3;i++)begin
                        @(intf.cb_mst1);
                        intf.cb_mst1.tx <= req.ifs_can_fd[2-i];
                    end
                    `uvm_info(get_type_name(),"translate the message successful at 500kHz",UVM_DEBUG)
                end    
                else begin
                    trans_flag =1;
                    `uvm_info(get_type_name(),"no ack response",UVM_DEBUG)
                end
            end
        end        
        default:begin
            release_bus();
        end
    endcase
endtask:can_fd_driver
task can_slv::release_bus;
    `uvm_info(get_type_name(),"release_bus....",UVM_DEBUG)
    @(posedge intf.clk1);
    intf.tx <= 1;
    // intf.rx <= 1; //control by dut
endtask:release_bus

task can_slv::reset_listener();
    `uvm_info(get_type_name(),"reset_listener....",UVM_HIGH)
    fork
        forever begin
            @(negedge intf.rst_n);
            // intf.rx <= 1; //control by dut
            intf.tx <= 1;
        end 
    join_none 
endtask:reset_listener 
`endif