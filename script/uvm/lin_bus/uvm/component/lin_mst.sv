`ifndef LIN_MST_SV
`define LIN_MST_SV

typedef class lin_mst;
class lin_mst_callbacks extends uvm_callback;
    // Called at start of observed transaction
    extern virtual function void pre_trans(lin_mst mst,lin_trans trans);
    // Called at end of observed transaction
    extern virtual function void post_trans(lin_mst mst,lin_trans trans);
    // Called before acknowledging a transaction
    extern virtual function void pre_ack(lin_mst mst,lin_trans trans);
    // Callback method post_cb_trans lin be used for coverage
    extern virtual function void post_cb_trans(lin_mst mst,lin_trans trans);

endclass
//call back function define
function void lin_mst_callbacks::pre_trans(lin_mst mst,lin_trans trans);
    if(trans.data.size == 0)
        `uvm_fatal(get_type_name(),"There are no trans at the phase of pre_trans")
    else 
        `uvm_info(get_type_name(),$sformatf("the trans is %s at the phase of pre_trans",trans.convert2string()),UVM_DEBUG)
endfunction:pre_trans

function void lin_mst_callbacks::post_trans(lin_mst mst,lin_trans trans);
    if(trans.data.size == 0)
        `uvm_fatal(get_type_name(),"The trans had change at the phase of post_trans")
    else 
        `uvm_info(get_type_name(),$sformatf("The trans is %s at the phase of post_trans",trans.convert2string()),UVM_DEBUG)
endfunction:post_trans

function void lin_mst_callbacks::pre_ack(lin_mst mst,lin_trans trans);
    if(trans.data.size == 0)
        `uvm_fatal(get_type_name(),"There are no trans at the phase of pre_ack")
    else  
        `uvm_info(get_type_name(),$sformatf("The trans is %s at the phase of pre_ack",trans.convert2string()),UVM_DEBUG)
endfunction:pre_ack

function void lin_mst_callbacks::post_cb_trans(lin_mst mst,lin_trans trans);
    if(trans.data.size == 0)
        `uvm_fatal(get_type_name(),"There are no trans at the phase of post_cb_trans")
    else 
        `uvm_info(get_type_name(),$sformatf("The trans is %s at the phase of post_cb_trans",trans.convert2string()),UVM_DEBUG)
endfunction:post_cb_trans

class lin_mst extends uvm_driver #(lin_trans);
//parameter define    
    virtual lin_agt_if intf;
    lin_trans req,rsp;
    lin_agt_cfg cfg;
    uvm_analysis_port #(lin_trans) mon_analysis_port; //for self test
    int vld_pct = 100;
    int trans_flag = 1;//0-trans failure 1-trans successful


    `uvm_component_utils(lin_mst)
    `uvm_register_cb(lin_mst,lin_mst_callbacks)
    extern function new(string name = "lin_mst",uvm_component parent = null); 
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
function lin_mst::new(string name ,uvm_component parent);
    super.new(name,parent);
    mon_analysis_port = new("mon_analysis_port",this);
endfunction:new

function void lin_mst::build_phase(uvm_phase phase);
    if(!uvm_config_db#(virtual lin_agt_if)::get(this,"","intf",intf))begin
        `uvm_fatal(get_type_name(),"No virtual interface specified for this mst instance")
    end
    if(!uvm_config_db#(lin_agt_cfg)::get(this,"","cfg",cfg))begin
        cfg = lin_agt_cfg::type_id::create("cfg",this);
        `uvm_info(get_type_name(),"No cfg handle be receive,then drive create this object",UVM_LOW)
    end
endfunction:build_phase

function void lin_mst::connect_phase(uvm_phase phase);
    super.connect_phase(phase);
endfunction:connect_phase

function void lin_mst::end_of_elaboration_phase(uvm_phase phase);
    super.end_of_elaboration_phase(phase);
endfunction:end_of_elaboration_phase

function void lin_mst::start_of_simulation_phase(uvm_phase phase);
    super.start_of_simulation_phase(phase);
endfunction:start_of_simulation_phase

task lin_mst::reset_phase(uvm_phase phase);
    super.reset_phase(phase);
    phase.raise_objection(this);
    reset_listener();
    phase.drop_objection(this);
endtask:reset_phase

task lin_mst::configure_phase(uvm_phase phase);
    super.configure_phase(phase);
endtask:configure_phase

task lin_mst::main_phase(uvm_phase phase);
    super.main_phase(phase);
    //phase.raise_objection(this);
    fork
        get_items_driver();
        // data_receive();
        // reset_listener();
    join 
    //phase.drop_objection(this);
endtask:main_phase

task lin_mst::get_items_driver();
    forever begin
        `uvm_do_callbacks(lin_mst,lin_mst_callbacks,pre_trans(this,req))
        seq_item_port.get_next_item(req);
        `uvm_info(get_type_name(),req.sprint(),UVM_LOW)
        mon_analysis_port.write(req);
        // if(cfg.agt_type == MASTER)
        //     master_driver();
        // else if(cfg.agt_type == SLVAER)
        //     slaver_driver();
        // else `uvm_info(get_type_name(),"one error is happened at the component of driver ",UVM_DEBUG)
        if(req.data_role == master_node)begin
            `uvm_info(get_type_name(),"master_driver begin",UVM_MEDIUM)
            master_driver();
        end
        else if(req.data_role == slaver_node)begin
            `uvm_info(get_type_name(),"slaver_driver begin",UVM_DEBUG)
            slaver_driver();
        end
        else `uvm_info(get_type_name(),"one error is happened at the component of driver ",UVM_DEBUG)
        void'($cast(rsp,req.clone()));
        rsp.set_sequence_id(req.get_sequence_id());
        rsp.set_transaction_id(req.get_transaction_id());
        seq_item_port.item_done(rsp);
        `uvm_info(get_type_name(),"Completed transaction...",UVM_DEBUG)
        `uvm_do_callbacks(lin_mst,lin_mst_callbacks,post_trans(this,req))
        `uvm_info(get_type_name(),$sformatf("The req content is %s",req.convert2string()),UVM_DEBUG)
    end
endtask:get_items_driver

task lin_mst::data_receive();
    forever begin
        //data_receiver lin copy from lin_mon.sv
    end
endtask:data_receive
//typedef enum {unconditional_frame,event_fram,sporadic_fram,diagnostic_fram,user_define_fram,save_fram} trans_type;
task lin_mst::master_driver();
    bit[7:0] identifier_temp;
    bit[7:0] sync_remp;
    bit[7:0] data_temp;
    bit[7:0] checksum_temp;
    case(req.data_type)
        unconditional_frame:begin
            //break
                repeat(req.lin_break)begin   
                    @(intf.cb_mst);
                    intf.cb_mst.tx <= 0;
                end
                //break delimiter
                @(intf.cb_mst);
                intf.cb_mst.tx <= 1;
            //sync 
                sync_remp = req.sync;
                //trans start bit
                @(intf.cb_mst);
                intf.cb_mst.tx <= 0;
                //trans sync data
                repeat(8)begin
                    @(intf.cb_mst);
                    intf.cb_mst.tx <= sync_remp[0];
                    sync_remp = sync_remp >>1;
                end
                //trans stop bit
                @(intf.cb_mst);
                intf.cb_mst.tx <= 1;
            //inter_byte space
                repeat(req.inter_byte_space)begin
                    @(intf.cb_mst);
                    intf.cb_mst.tx <= 1;
                end
            //protected identifier
                //trans start bit
                @(intf.cb_mst);
                intf.cb_mst.tx <= 0;
                //trans identifier data
                identifier_temp = req.identifier;
                repeat(8)begin
                    @(intf.cb_mst);
                    // intf.cb_mst.tx <= req.identifier[0];
                    // req.identifier = req.identifier >>1; 
                    intf.cb_mst.tx <= identifier_temp[0];
                    identifier_temp = identifier_temp >>1;
                end
                //trans stop bit
                @(intf.cb_mst);
                intf.cb_mst.tx <= 1;
                `uvm_info(get_type_name(),$sformatf("The identifier value is %d",req.identifier[5:0]),UVM_LOW)
            if(req.identifier[5:0] == 10)begin//user define according to the schedule table of lin protcol
            //response space
                repeat(req.response_space)begin
                    @(intf.cb_mst);
                    intf.cb_mst.tx <= 1;
                end
            //trans data
                foreach(req.data[i])begin
                        data_temp = req.data[i];
                        //trans start bit
                        @(intf.cb_mst);
                        intf.cb_mst.tx <= 0;
                        //trans data
                        repeat(8)begin
                            @(intf.cb_mst);
                            intf.cb_mst.tx <= data_temp[0];
                            data_temp = data_temp >>1;
                        end
                        //trans stop bit
                        @(intf.cb_mst);
                        intf.cb_mst.tx <= 1;
                        //inter_byte space
                        repeat(req.inter_byte_space)begin
                            @(intf.cb_mst);
                            intf.cb_mst.tx <= 1;
                        end
                end
            //checksum
                // repeat(8)begin
                //     @(intf.cb_mst);
                //     intf.cb_mst.tx <= 1;
                //     @(intf.cb_mst);
                //     intf.cb_mst.tx <= 0;
                // end
                checksum_temp = req.checksum;
                `uvm_info(get_type_name(),$sformatf("The checksum_temp is %d",checksum_temp),UVM_MEDIUM)
                //trans start bit
                @(intf.cb_mst);
                intf.cb_mst.tx <= 0;
                //trans data
                repeat(8)begin
                    @(intf.cb_mst);
                    intf.cb_mst.tx <= checksum_temp[0];
                    checksum_temp = checksum_temp >>1;
                end
                //trans stop bit
                `uvm_info(get_type_name(),"trans stop bit of checksum successful",UVM_MEDIUM)
                @(intf.cb_mst);
                intf.cb_mst.tx <= 1;
                `uvm_info(get_type_name(),"master node trans the header and response successful",UVM_DEBUG)
                `uvm_info(get_type_name(),$sformatf("The fram_gap is %d",req.fram_gap),UVM_MEDIUM)
                repeat(req.fram_gap)release_bus();
            end
            else begin 
                `uvm_info(get_type_name(),"master node trans the header successful",UVM_MEDIUM) 
                repeat(req.fram_gap)release_bus();
            end
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
task lin_mst::slaver_driver();
    bit [7:0] data_temp;
    bit [7:0] checksum_temp;
    lin_trans temp_trans = new("temp_trans");
    temp_trans.lin_break      = 0;
    // temp_trans.response_space = 0;
    //detect break field
    @(negedge intf.rx);
    //count the break cycle
    while(intf.rx == 0)begin
        temp_trans.lin_break = temp_trans.lin_break + 1'b1;
        @(intf.cb_mst);
    end
    if(temp_trans.lin_break > 13)begin
        //detect sync field(start_bit)
        @(negedge intf.rx);
            //receive the data of sync
            repeat(8)begin 
                @(intf.cb_mst);
                temp_trans.sync[7] <= intf.rx;
                temp_trans.sync = temp_trans.sync >>1;
            end
        //detect protected identifier field(strat_bit)
        @(negedge intf.rx);
            //receive the data of identifier field
            repeat(8)begin
                @(intf.cb_mst);
                temp_trans.identifier[7] <= intf.rx;
                temp_trans.identifier = temp_trans.identifier >>1;
            end
        if(temp_trans.identifier == 20)begin //user define according to the schedule table of lin protocal
            //delay the response space
            repeat(req.response_space)begin
                release_bus();
            end
            //trans the data
            foreach(req.data[i])begin
                data_temp = req.data[i];
                //trans start bit
                @(intf.cb_mst);
                intf.cb_mst.tx <= 0;
                //trans data
                repeat(8)begin
                    @(intf.cb_mst);
                    intf.cb_mst.tx <= data_temp[0];
                    data_temp = data_temp >>1;
                end
                //trans stop bit
                @(intf.cb_mst);
                intf.cb_mst.tx <= 1;
                //inter_byte space
                repeat(req.inter_byte_space)begin
                    @(intf.cb_mst);
                    intf.cb_mst.tx <= 1;
                end
            end
            //checksum
                checksum_temp = req.checksum;
                //trans start bit
                @(intf.cb_mst);
                intf.cb_mst.tx <= 0;
                //trans data
                repeat(8)begin
                    @(intf.cb_mst);
                    intf.cb_mst.tx <= checksum_temp[0];
                    checksum_temp = checksum_temp >>1;
                end
                //trans stop bit
                @(intf.cb_mst);
                intf.cb_mst.tx <= 1;
                //fram_gap //slaver need the fram_gap ??
                // repeat(req.fram_gap)begin
                //     release_bus();
                // end
                `uvm_info(get_type_name(),"slaver node trans the response successful",UVM_DEBUG)
        end
        else begin
            `uvm_info(get_type_name(),"This identifier is not mine",UVM_DEBUG)
        end
    end
    else begin
        `uvm_error(get_type_name(),"The break field is shorter than 13 cycles")
    end
endtask:slaver_driver
task lin_mst::release_bus;
    `uvm_info(get_type_name(),"release_bus....",UVM_MEDIUM)
    @(intf.cb_mst);
    intf.cb_mst.tx <= 1;
    // intf.rx <= 1; //control by dut
endtask:release_bus

task lin_mst::reset_listener();
    `uvm_info(get_type_name(),"reset_listener....",UVM_HIGH)
        begin
            @(negedge intf.rst_n);
            // intf.rx <= 1; //control by dut
            intf.tx <= 1;
        end 
endtask:reset_listener 
`endif




