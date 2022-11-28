`ifndef LIN_SLV_SV
`define LIN_SLV_SV

typedef class lin_slv;
class lin_slv_callbacks extends uvm_callback;
    // Called at start of observed transaction
    extern virtual function void pre_trans(lin_slv slv,lin_trans trans);
    // Called at end of observed transaction
    extern virtual function void post_trans(lin_slv slv,lin_trans trans);
    // Called before acknowledging a transaction
    extern virtual function void pre_ack(lin_slv slv,lin_trans trans);
    // Callback method post_cb_trans lin be used for coverage
    extern virtual function void post_cb_trans(lin_slv slv,lin_trans trans);

endclass
//call back function define
function void lin_slv_callbacks::pre_trans(lin_slv slv,lin_trans trans);
    if(trans.data.size == 0)
        `uvm_fatal(get_type_name(),"There are no trans at the phase of pre_trans")
    else 
        `uvm_info(get_type_name(),$sformatf("the trans is %s at the phase of pre_trans",trans.convert2string()),UVM_DEBUG)
endfunction:pre_trans

function void lin_slv_callbacks::post_trans(lin_slv slv,lin_trans trans);
    if(trans.data.size == 0)
        `uvm_fatal(get_type_name(),"The trans had change at the phase of post_trans")
    else 
        `uvm_info(get_type_name(),$sformatf("The trans is %s at the phase of post_trans",trans.convert2string()),UVM_DEBUG)
endfunction:post_trans

function void lin_slv_callbacks::pre_ack(lin_slv slv,lin_trans trans);
    if(trans.data.size == 0)
        `uvm_fatal(get_type_name(),"There are no trans at the phase of pre_ack")
    else  
        `uvm_info(get_type_name(),$sformatf("The trans is %s at the phase of pre_ack",trans.convert2string()),UVM_DEBUG)
endfunction:pre_ack

function void lin_slv_callbacks::post_cb_trans(lin_slv slv,lin_trans trans);
    if(trans.data.size == 0)
        `uvm_fatal(get_type_name(),"There are no trans at the phase of post_cb_trans")
    else 
        `uvm_info(get_type_name(),$sformatf("The trans is %s at the phase of post_cb_trans",trans.convert2string()),UVM_DEBUG)
endfunction:post_cb_trans

class lin_slv extends uvm_driver #(lin_trans);
//parameter define    
    virtual lin_agt_if intf;
    lin_trans req,rsp;
    lin_agt_cfg cfg;
    uvm_analysis_port #(lin_trans) mon_analysis_port; //for self test
    int vld_pct = 100;
    int trans_flag = 1;//0-trans failure 1-trans successful


    `uvm_component_utils(lin_slv)
    `uvm_register_cb(lin_slv,lin_slv_callbacks)
    extern function new(string name = "lin_slv",uvm_component parent = null); 
    extern virtual function void build_phase(uvm_phase phase);
    extern virtual function void connect_phase(uvm_phase phase);
    extern virtual function void end_of_elaboration_phase(uvm_phase phase);
    extern virtual function void start_of_simulation_phase(uvm_phase phase);
    extern virtual task reset_phase(uvm_phase phase);
    extern virtual task configure_phase(uvm_phase phase);
    extern virtual task main_phase(uvm_phase phase);
    extern virtual task get_items_driver();
    extern virtual task master_driver();
    extern virtual task slaver_driver();
    extern virtual task data_receive();
    extern virtual task release_bus();
    extern virtual task reset_listener();
    // extern virtual task send(); 
endclass

//driver function define
function lin_slv::new(string name ,uvm_component parent);
    super.new(name,parent);
    mon_analysis_port = new("mon_analysis_port",this);
endfunction:new

function void lin_slv::build_phase(uvm_phase phase);
    if(!uvm_config_db#(virtual lin_agt_if)::get(this,"","intf",intf))begin
        `uvm_fatal(get_type_name(),"No virtual interface specified for this slv instance")
    end
    if(!uvm_config_db#(lin_agt_cfg)::get(this,"","cfg",cfg))begin
        cfg = lin_agt_cfg::type_id::create("cfg",this);
        `uvm_info(get_type_name(),"No cfg handle be receive,then drive create this object",UVM_LOW)
    end
endfunction:build_phase

function void lin_slv::connect_phase(uvm_phase phase);
    super.connect_phase(phase);
endfunction:connect_phase

function void lin_slv::end_of_elaboration_phase(uvm_phase phase);
    super.end_of_elaboration_phase(phase);
endfunction:end_of_elaboration_phase

function void lin_slv::start_of_simulation_phase(uvm_phase phase);
    super.start_of_simulation_phase(phase);
endfunction:start_of_simulation_phase

task lin_slv::reset_phase(uvm_phase phase);
    super.reset_phase(phase);
endtask:reset_phase

task lin_slv::configure_phase(uvm_phase phase);
    super.configure_phase(phase);
endtask:configure_phase

task lin_slv::main_phase(uvm_phase phase);
    super.main_phase(phase);
    //phase.raise_objection(this);
    fork
        get_items_driver();
        // data_receive();
        reset_listener();
    join 
    //phase.drop_objection(this);
endtask:main_phase

task lin_slv::get_items_driver();
    forever begin
        `uvm_do_callbacks(lin_slv,lin_slv_callbacks,pre_trans(this,req))
        seq_item_port.get_next_item(req);
        `uvm_info(get_type_name(),req.sprint(),UVM_LOW)
        mon_analysis_port.write(req);
        // if(cfg.agt_type == MASTER)
        //     master_driver();
        // else if(cfg.agt_type == SLVAER)
        //     slaver_driver();
        // else `uvm_info(get_type_name(),"one error is happened at the component of driver ",UVM_DEBUG)
        if(req.data_role == master_node)
            master_driver();
        else if(req.data_role == slaver_node)
            slaver_driver();
        else `uvm_info(get_type_name(),"one error is happened at the component of driver ",UVM_DEBUG)
        void'($cast(rsp,req.clone()));
        rsp.set_sequence_id(req.get_sequence_id());
        rsp.set_transaction_id(req.get_transaction_id());
        seq_item_port.item_done(rsp);
        `uvm_info(get_type_name(),"Completed transaction...",UVM_DEBUG)
        `uvm_do_callbacks(lin_slv,lin_slv_callbacks,post_trans(this,req))
        `uvm_info(get_type_name(),$sformatf("The req content is %s",req.convert2string()),UVM_HIGH)
    end
endtask:get_items_driver

task lin_slv::data_receive();
    forever begin
        //data_receiver lin copy from lin_mon.sv
    end
endtask:data_receive
//typedef enum {unconditional_frame,event_fram,sporadic_fram,diagnostic_fram,user_define_fram,save_fram} trans_type;
task lin_slv::master_driver();
    case(req.data_type)
        unconditional_frame:begin
            //break
                repeat(req.lin_break)begin
                    @(intf.cb_slv);
                    intf.tx <= 0;
                end
                //break delimiter
                @(intf.cb_slv);
                intf.tx <= 1;
            //sync 
                //trans start bit
                @(intf.cb_slv);
                intf.tx <= 0;
                //trans sync data
                repeat(8)begin
                    @(intf.cb_slv);
                    intf.tx <= req.sync[0];
                    req.sync = req.sync >>1;
                end
                //trans stop bit
                @(intf.cb_slv);
                intf.tx <= 1;
            //inter_byte space
                repeat(req.inter_byte_space)begin
                    @(intf.cb_slv);
                    intf.tx <= 1;
                end
            //protected identifier
                //trans start bit
                @(intf.cb_slv);
                intf.tx <= 0;
                //trans identifier data
                repeat(8)begin
                    @(intf.cb_slv);
                    intf.tx <= req.identifier[0];
                    req.identifier = req.identifier >>1; 
                end
                //trans stop bit
                @(intf.cb_slv);
                intf.tx <= 1;
            if(req.identifier == 10)begin//user define according to the schedule table of lin protcol
            //response space
                repeat(req.response_space)begin
                    @(intf.cb_slv);
                    intf.tx <= 1;
                end
            //trans data
                foreach(req.data[i])begin
                        //trans start bit
                        @(intf.cb_slv);
                        intf.tx <= 0;
                        //trans data
                        repeat(8)begin
                            @(intf.cb_slv);
                            intf.tx <= req.data[i][0];
                            req.data[i] = req.data[i] >>1;
                        end
                        //trans stop bit
                        @(intf.cb_slv);
                        intf.tx <= 1;
                        //inter_byte space
                        repeat(req.inter_byte_space)begin
                            @(intf.cb_slv);
                            intf.tx <= 1;
                        end
                end
            //checksum
                //trans start bit
                @(intf.cb_slv);
                intf.tx <= 0;
                //trans data
                repeat(8)begin
                    @(intf.cb_slv);
                    intf.tx <= req.checksum[0];
                    req.checksum = req.checksum >>1;
                end
                //trans stop bit
                @(intf.cb_slv);
                intf.tx <= 1;
                `uvm_info(get_type_name(),"master node trans the header and response successful",UVM_DEBUG)
            end
            else 
                `uvm_info(get_type_name(),"master node trans the header successful",UVM_DEBUG) 
        end        
        diagnostic_fram:begin
            //association with dce develop group
            release_bus();
        end
        default:begin
            release_bus();
        end
    endcase
endtask:master_driver
task lin_slv::slaver_driver();
    lin_trans temp_trans = new("temp_trans");
    temp_trans.lin_break      = 0;
    temp_trans.response_space = 0;
    //detect break field
    @(negedge intf.rx);
    //count the break cycle
    while(intf.rx == 0)begin
        @(intf.cb_slv);
         temp_trans.lin_break = temp_trans.lin_break + 1'b1;
    end
    if(temp_trans.lin_break > 13)begin
        //detect sync field(start_bit)
        @(negedge intf.rx);
            //receive the data of sync
            repeat(8)begin 
                @(intf.cb_slv);
                temp_trans.sync[0] <= intf.rx;
                temp_trans.sync = temp_trans.sync <<1;
            end
        //detect protected identifier field(strat_bit)
        @(negedge intf.rx);
            //receive the data of identifier field
            repeat(8)begin
                @(intf.cb_slv);
                temp_trans.identifier[0] <= intf.rx;
                temp_trans.identifier = temp_trans.identifier <<1;
            end
        if(temp_trans.identifier == 20)begin //user define according to the schedule table of lin protocal
            //detect the response space
            @(posedge intf.rx);
            //count the response space cycle
            while(intf.rx == 1)begin
                @(intf.cb_slv);
                temp_trans.response_space = temp_trans.response_space + 1;
            end
            if(temp_trans.response_space > 5)begin
                //trans the data
                foreach(req.data[i])begin
                    //trans start bit
                    @(intf.cb_slv);
                    intf.tx <= 0;
                    //trans data
                    repeat(8)begin
                        @(intf.cb_slv);
                        intf.tx <= req.data[i][0];
                        req.data[i] = req.data[i] >>1;
                    end
                    //trans stop bit
                    @(intf.cb_slv);
                    intf.tx <= 1;
                    //inter_byte space
                    repeat(req.inter_byte_space)begin
                        @(intf.cb_slv);
                        intf.tx <= 1;
                    end
                end
                //checksum
                    //trans start bit
                    @(intf.cb_slv);
                    intf.tx <= 0;
                    //trans data
                    repeat(8)begin
                        @(intf.cb_slv);
                        intf.tx <= req.checksum[0];
                        req.checksum = req.checksum >>1;
                    end
                    //trans stop bit
                    @(intf.cb_slv);
                    intf.tx <= 1;
                    `uvm_info(get_type_name(),"slaver node trans the response successful",UVM_DEBUG)
            end
            else begin
                `uvm_error(get_type_name(),"The response field is shorter than 5 cycles")
            end
        end
        else begin
            `uvm_info(get_type_name(),"This identifier is not mine",UVM_DEBUG)
        end
    end
    else begin
        `uvm_error(get_type_name(),"The break field is shorter than 13 cycles")
    end
endtask:slaver_driver
task lin_slv::release_bus;
    `uvm_info(get_type_name(),"release_bus....",UVM_DEBUG)
    @(posedge intf.clk);
    intf.tx <= 1;
    // intf.rx <= 1; //control by dut
endtask:release_bus

task lin_slv::reset_listener();
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




