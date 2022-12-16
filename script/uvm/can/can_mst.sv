`ifndef CAN_MST_SV
`define CAN_MST_SV

typedef class can_mst;
class can_mst_callbacks extends uvm_callback;
    // Called at start of observed transaction
    extern virtual function void pre_trans(can_mst mst,can_trans trans);
    // Called at end of observed transaction
    extern virtual function void post_trans(can_mst mst,can_trans trans);
    // Called before acknowledging a transaction
    extern virtual function void pre_ack(can_mst mst,can_trans trans);
    // Callback method post_cb_trans can be used for coverage
    extern virtual function void post_cb_trans(can_mst mst,can_trans trans);

endclass
//call back function define
function void can_mst_callbacks::pre_trans(can_mst mst,can_trans trans);
    // if(trans.data_can.size == 0)
    //     `uvm_fatal(get_type_name(),"There are no trans at the phase of pre_trans")
    // else 
    //     `uvm_info(get_type_name(),$sformatf("the trans is %s at the phase of pre_trans",trans.convert2string()),UVM_DEBUG)
endfunction:pre_trans

function void can_mst_callbacks::post_trans(can_mst mst,can_trans trans);
    // if(trans.data_can.size == 0)
    //     `uvm_fatal(get_type_name(),"The trans had change at the phase of post_trans")
    // else 
    //     `uvm_info(get_type_name(),$sformatf("The trans is %s at the phase of post_trans",trans.convert2string()),UVM_DEBUG)
endfunction:post_trans

function void can_mst_callbacks::pre_ack(can_mst mst,can_trans trans);
    // if(trans.data_can.size == 0)
    //     `uvm_fatal(get_type_name(),"There are no trans at the phase of pre_ack")
    // else  
    //     `uvm_info(get_type_name(),$sformatf("The trans is %s at the phase of pre_ack",trans.convert2string()),UVM_DEBUG)
endfunction:pre_ack

function void can_mst_callbacks::post_cb_trans(can_mst mst,can_trans trans);
    // if(trans.data_can.size == 0)
    //     `uvm_fatal(get_type_name(),"There are no trans at the phase of post_cb_trans")
    // else 
    //     `uvm_info(get_type_name(),$sformatf("The trans is %s at the phase of post_cb_trans",trans.convert2string()),UVM_DEBUG)
endfunction:post_cb_trans

class can_mst extends uvm_driver #(can_trans);
//parameter define    
    virtual can_agt_if intf;
    can_trans req,rsp;
    can_agt_cfg cfg;
    uvm_analysis_port #(can_trans) mon_analysis_port; //for self test
    int vld_pct = 100;
    logic trans_flag = 1;//0-trans successful  1-trans failure
    // bit trans_flag =1; //for simulation
    bit [4:0] stuff_bit_judge_p;//5'b00000-----insert stuff_bit 1
    bit [4:0] stuff_bit_judge_n;//5'b11111-----insert stuff_bit 0
    `uvm_component_utils(can_mst)
    `uvm_register_cb(can_mst,can_mst_callbacks)
    extern function new(string name = "can_mst",uvm_component parent = null); 
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
    extern virtual task stuff_bit_insert_p(bit in_data);//500khz
    extern virtual task stuff_bit_insert_n(bit in_data);//500khz
    extern virtual task stuff_bit_insert(bit in_data);  //500khz
    // extern virtual task send(); 
endclass

//driver function define
function can_mst::new(string name ,uvm_component parent);
    super.new(name,parent);
    mon_analysis_port = new("mon_analysis_port",this);
endfunction:new

function void can_mst::build_phase(uvm_phase phase);
    if(!uvm_config_db#(virtual can_agt_if)::get(this,"","intf",intf))begin
        `uvm_fatal(get_type_name(),"No virtual interface specified for this mst instance")
    end
    if(!uvm_config_db#(can_agt_cfg)::get(this,"","cfg",cfg))begin
        cfg = can_agt_cfg::type_id::create("cfg",this);
        `uvm_info(get_type_name(),"No cfg handle be receive,then drive create this object",UVM_LOW)
    end
endfunction:build_phase

function void can_mst::connect_phase(uvm_phase phase);
    super.connect_phase(phase);
endfunction:connect_phase

function void can_mst::end_of_elaboration_phase(uvm_phase phase);
    super.end_of_elaboration_phase(phase);
endfunction:end_of_elaboration_phase

function void can_mst::start_of_simulation_phase(uvm_phase phase);
    super.start_of_simulation_phase(phase);
endfunction:start_of_simulation_phase

task can_mst::reset_phase(uvm_phase phase);
    super.reset_phase(phase);
    phase.raise_objection(this);
    // reset_listener();
    intf.tx <= 1;
    // intf.rx <= 1;
    phase.drop_objection(this);
endtask:reset_phase

task can_mst::configure_phase(uvm_phase phase);
    super.configure_phase(phase);
endtask:configure_phase

task can_mst::main_phase(uvm_phase phase);
    super.main_phase(phase);
    //phase.raise_objection(this);
    fork
        get_items_driver();
        // data_receive();
        forever begin
            reset_listener();
        end
    join 
    //phase.drop_objection(this);
endtask:main_phase

task can_mst::get_items_driver();
    forever begin
        `uvm_do_callbacks(can_mst,can_mst_callbacks,pre_trans(this,req))
        seq_item_port.get_next_item(req);
        `uvm_info(get_type_name(),req.sprint(),UVM_LOW)
        mon_analysis_port.write(req);
        if(req.can_type == can)begin
            `uvm_info(get_type_name(),"can translate begin",UVM_LOW)
            can_driver();
//retry to translate
            while(trans_flag == 1)begin
                `uvm_info(get_type_name(),"can translate retry begin",UVM_LOW)
                can_driver();
            end
            trans_flag = 1;
        end
        else if(req.can_type == can_fd)begin
            `uvm_info(get_type_name(),"can_fd translate begin",UVM_LOW)
            can_fd_driver();
//retry to translate
            while(trans_flag == 1)begin
                `uvm_info(get_type_name(),"can fd translate retry begin",UVM_LOW)
                can_fd_driver();
            end 
        end
        else `uvm_info(get_type_name(),"one error is happened at the component of driver ",UVM_DEBUG)
        void'($cast(rsp,req.clone()));
        rsp.set_sequence_id(req.get_sequence_id());
        rsp.set_transaction_id(req.get_transaction_id());
        seq_item_port.item_done(rsp);
        `uvm_info(get_type_name(),"Completed transaction...",UVM_DEBUG)
        `uvm_do_callbacks(can_mst,can_mst_callbacks,post_trans(this,req))
        `uvm_info(get_type_name(),$sformatf("The req content is %s",req.convert2string()),UVM_DEBUG)
    end
endtask:get_items_driver

task can_mst::data_receive();
    // forever begin
        //data_receiver can copy from can_mon.sv
    // end
endtask:data_receive
//typedef enum {data_frame,remote_fram,error_fram,overload_fram,gap_fram} fram_type;
task can_mst::can_driver();
    int i,j;
    stuff_bit_judge_p = 5'b11111;
    stuff_bit_judge_n = 5'b00000;
    case(req.data_type)
        data_frame:begin
            //sof(0)
            @(intf.cb_mst1);
            intf.cb_mst1.tx <= 0;
            stuff_bit_insert(1'b0);
            //identify
            for(i=0;i<11;i++)begin
                @(intf.cb_mst1);
                intf.cb_mst1.tx <= req.identify_can[10-i];
                stuff_bit_insert(req.identify_can[10-i]);
            end
            //rtr
            @(intf.cb_mst1);
            intf.cb_mst1.tx <= req.rtr_can;
            stuff_bit_insert(req.rtr_can);
            //ide
            @(intf.cb_mst1);
            intf.cb_mst1.tx <= req.ide_can;
            stuff_bit_insert(req.ide_can);
            //r0
            @(intf.cb_mst1);
            intf.cb_mst1.tx <= req.r0_can;
            stuff_bit_insert(req.r0_can);
            //dlc
            for(i=0;i<4;i++)begin
                @(intf.cb_mst1);
                intf.cb_mst1.tx <= req.dlc_can[3-i];
                stuff_bit_insert(req.dlc_can[3-i]);
            end
            //data
           foreach(req.data_can[i])begin
                for(j=0;j<8;j++)begin
                    @(intf.cb_mst1);
                    intf.cb_mst1.tx <= req.data_can[i][7-j];
                    stuff_bit_insert(req.data_can[i][7-j]);
                end
            end
            //crc_sequence
            for(i=0;i<15;i++)begin
                @(intf.cb_mst1);
                `uvm_info(get_type_name(),$sformatf("the crc_sequence_can_value is %h",req.crc_sequence_can),UVM_DEBUG)
                intf.cb_mst1.tx <= req.crc_sequence_can[14-i];
                stuff_bit_insert(req.crc_sequence_can[14-i]);
            end
            //crc_delimiter
            @(intf.cb_mst1);
            intf.cb_mst1.tx <= 1;
            // ack slot
            @(intf.cb_mst1);
            intf.cb_mst1.tx     <= 1;//comply to actual wavefom
            trans_flag  = intf.cb_mst1.rx;
            `uvm_info(get_type_name(),$sformatf("the trans_flag value is %d",trans_flag),UVM_DEBUG)
            if(trans_flag == 0)begin
                //ack_delimiter
                @(intf.cb_mst1);
                intf.cb_mst1.tx <= 1;
                //eof
                repeat(7)begin
                    @(intf.cb_mst1);
                    intf.cb_mst1.tx <= 1;
                end
                `uvm_info(get_type_name(),"translate the message successful",UVM_LOW)
                repeat(req.fram_gap)begin
                    release_bus();
                    `uvm_info(get_type_name(),"release bus by process of can",UVM_HIGH)    
                end
            end    
            else begin
                trans_flag =1;
                `uvm_info(get_type_name(),"no ack response",UVM_LOW) 
            end
        end        
        default:begin
            release_bus();
        end
    endcase
endtask:can_driver
task can_mst::can_fd_driver();
    int i,j;
    stuff_bit_judge_p = 5'b11111;
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
                    `uvm_info(get_type_name(),"translate the message successful at 20MHz",UVM_LOW)
                    repeat(req.fram_gap)begin
                        release_bus();
                        `uvm_info(get_type_name(),"release bus by can fd(20mhz)",UVM_HIGH)
                    end
                end    
                else begin
                    trans_flag =1;
                    `uvm_info(get_type_name(),"no ack response",UVM_LOW) 
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
                    `uvm_info(get_type_name(),"translate the message successful at 500kHz",UVM_LOW)
                    repeat(req.fram_gap)begin
                        release_bus();
                        `uvm_info(get_type_name(),"release bus by can fd(500khz)",UVM_HIGH)
                    end
                end    
                else begin
                    trans_flag =1;
                    `uvm_info(get_type_name(),"no ack response",UVM_LOW)
                end
            end
        end        
        default:begin
            release_bus();
        end
    endcase
endtask:can_fd_driver
task can_mst::release_bus;
    `uvm_info(get_type_name(),"release_bus....",UVM_DEBUG)
    @(posedge intf.clk1);
    intf.tx <= 1;
    // intf.rx <= 1; //control by dut
endtask:release_bus

task can_mst::reset_listener();  
    @(negedge intf.rst_n);
    // intf.rx <= 1; //control by dut
    intf.tx <= 1;
    `uvm_info(get_type_name(),"reset_listener....",UVM_HIGH)  
endtask:reset_listener 

task can_mst::stuff_bit_insert_p(bit in_data); 
    stuff_bit_judge_p = {stuff_bit_judge_p[3:0],in_data};
    `uvm_info(get_type_name(),$sformatf("the stuff_bit_judge_p value is %h",stuff_bit_judge_p),UVM_MEDIUM)
    if(stuff_bit_judge_p == 5'b00000)begin
        @(intf.cb_mst1);
        intf.cb_mst1.tx <= 'b1;
        stuff_bit_judge_p = 5'b11111;
        `uvm_info(get_type_name(),"insert the stuff bit 1",UVM_DEBUG)
    end
    // return stuff_bit_judge_p;
endtask:stuff_bit_insert_p

task can_mst::stuff_bit_insert_n(bit in_data); 
    stuff_bit_judge_n = {stuff_bit_judge_n[3:0],in_data};
    `uvm_info(get_type_name(),$sformatf("the stuff_bit_judge_n value is %h",stuff_bit_judge_n),UVM_MEDIUM)
    if(stuff_bit_judge_n == 5'b11111)begin
        @(intf.cb_mst1);
        intf.cb_mst1.tx <= 'b0;
        stuff_bit_judge_n = 5'b00000;
        `uvm_info(get_type_name(),"insert the stuff bit 0",UVM_DEBUG)
    end
    // return stuff_bit_judge_n;
endtask:stuff_bit_insert_n

task can_mst::stuff_bit_insert(bit in_data);
fork
    begin
        stuff_bit_insert_p(in_data);
    end
    begin
        stuff_bit_insert_n(in_data);
    end  
join 
endtask:stuff_bit_insert
`endif




