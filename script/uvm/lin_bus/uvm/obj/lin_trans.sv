`ifndef LIN_TRANS_SV
`define LIN_TRANS_SV

typedef enum {unconditional_frame,event_fram,sporadic_fram,diagnostic_fram,user_define_fram,save_fram} trans_type;
typedef enum {master_node,slaver_node} trans_role;
// import "DPI-C"function U16 ComputeCrc15(std::vector<BitState> &bits, U32 num_bits);
// import "DPI-C"function U16 MakeCRC15(std::vector<BitState> &bits, U32 num_bits);
// import "DPI-C"function int lin_crc_next(input bit[15:0] crc,input bit[7:0] data);
// import "DPI-C"function uint16_t lin_crc_next(uint16_t crc, uint8_t data);
class lin_trans extends uvm_sequence_item;
    //  Group: Variables
    rand bit [5-1:0]            lin_break;//used to signal the beginning of a new frame
    rand bit [8-1:0]            sync;// 
    rand bit [8-1:0]            identifier;
    rand int                    response_space;
    rand bit [8-1:0]            data[]; 
    rand bit [8-1:0]            checksum;
    rand bit [8-1:0]            inter_byte_space;//must be non-negative
    //control parameter
    rand bit [4-1:0]            data_lenth;     
    rand bit [3:0]              fram_gap;
    rand trans_type             data_type;
    rand trans_role             data_role;
    //for monitor receive
    rand bit [8-1:0]            data_mon[$]; 
//temperation variable
    lin_trans trans;
    bit cmp;
    string  s;
    `uvm_object_utils_begin(lin_trans)
        `uvm_field_int(lin_break,UVM_ALL_ON)
        `uvm_field_int(sync,UVM_ALL_ON)
        `uvm_field_int(identifier,UVM_ALL_ON)
        `uvm_field_int(response_space,UVM_ALL_ON)
        `uvm_field_array_int(data,UVM_ALL_ON)
        `uvm_field_int(checksum,UVM_ALL_ON)
        `uvm_field_int(inter_byte_space,UVM_ALL_ON)
        `uvm_field_int(data_lenth,UVM_ALL_ON)
        `uvm_field_int(fram_gap,UVM_ALL_ON|UVM_NOCOMPARE)
        `uvm_field_enum(trans_type,data_type,UVM_ALL_ON)
        `uvm_field_enum(trans_role,data_role,UVM_ALL_ON)        
    `uvm_object_utils_end

    //  Group: Constraints
    constraint trans_cstr {
        //at least 13 nominal bit times of dominant value,followed by a break delimiter
        soft lin_break inside{[13:$]};
        soft sync  == 8'h55;
        if(data_type == unconditional_frame)
            soft identifier inside {[0:59]};
        else if(data_type == diagnostic_fram)
            soft identifier inside {[60:61]};
        soft response_space inside {[5:10]};
        soft data.size == data_lenth;
        // soft data.size dist {1:=10,2:=10,4:=10,8:=10};
        soft inter_byte_space inside {[1:2]};
        soft data_lenth dist {1:=10,2:=10,4:=10,8:=10};
        soft fram_gap inside {[0:10]};
        soft data_type inside {unconditional_frame,diagnostic_fram};
    }
    //  Group: Functions

    //  Constructor: new
    extern function new(string name = "lin_trans");
    extern virtual function string convert2string();
    extern virtual function void do_copy(uvm_object rhs);
    extern virtual function bit do_compare(uvm_object rhs,uvm_comparer comparer);
    extern virtual function void do_print(uvm_printer printer);
    extern function void post_randomize();
    extern function bit[14:0]crc_gen(bit[14:0]crc_default,bit[7:0] data);
    //  Function: do_copy
    // extern function void do_copy(uvm_object rhs);
    //  Function: do_compare
    // extern function bit do_compare(uvm_object rhs, uvm_comparer comparer);
    //  Function: convert2string
    // extern function string convert2string();
    //  Function: do_print
    // extern function void do_print(uvm_printer printer);
    //  Function: do_record
    // extern function void do_record(uvm_recorder recorder);
    //  Function: do_pack
    // extern function void do_pack();
    //  Function: do_unpack
    // extern function void do_unpack();
    
endclass:lin_trans

/*----------------------------------------------------------------------------*/
/*  Constraints                                                               */
/*----------------------------------------------------------------------------*/



/*----------------------------------------------------------------------------*/
/*  Functions                                                                 */
/*----------------------------------------------------------------------------*/
function lin_trans::new(string name = "lin_trans");
    super.new(name);
endfunction: new

function string lin_trans::convert2string();
    s = super.convert2string();
    s = {s,$sformatf("sync is :%s ",this.sync)};
    s = {s,$sformatf("identifier is :%s ",this.identifier)};
    s = {s,$sformatf("response_space is :%s ",this.response_space)};
    s = {s,$sformatf("data.size is :%s ",this.data.size)};
    foreach(this.data[i])begin
        s = {s,$sformatf("data[%0d] is :%s ",i,this.data[i])};
    end
    s = {s,$sformatf("checksum is :%s ",this.checksum)};
    s = {s,$sformatf("inter_byte_space is :%s ",this.inter_byte_space)};

    s = {s,$sformatf("fram gap is :%d ",this.fram_gap)};
    s = {s,$sformatf("data_type is :%s ",this.data_type)};
    s = {s,$sformatf("data_role is :%d ",this.data_role)};
    return s;
endfunction:convert2string

function void lin_trans::do_copy(uvm_object rhs);
    super.do_copy(rhs);
    void'($cast(trans,rhs));
    this.lin_break          = trans.lin_break;
    this.sync               = trans.sync;
    this.identifier         = trans.identifier;
    this.response_space     = trans.response_space;
    this.data               = trans.data;
    this.checksum           = trans.checksum;
    this.inter_byte_space   = trans.inter_byte_space;
    this.fram_gap           = trans.fram_gap;
    this.data_type          = trans.data_type;
    this.data_role          = trans.data_role;
endfunction:do_copy

function bit lin_trans::do_compare(uvm_object rhs,uvm_comparer comparer);
    // lin_trans trans;
    bit cmp = 1;
    void'($cast(trans,rhs));
    cmp = (super.do_compare(rhs,comparer) && this.data == trans.data && this.identifier == trans.identifier);
    return cmp;

endfunction:do_compare 

function void lin_trans::do_print(uvm_printer printer);
    super.do_print(printer);
    s = convert2string();
    `uvm_info("get_type_name",{"the printe content is %s\n",s},UVM_HIGH)
    // `uvm_info("get_type_name",{"using uvm_default_printer\n",s.sprint()},UVM_LOW)
    // `uvm_info("get_type_name",{"using uvm_default_table_printer\n",s.sprint(uvm_default_table_printer)},UVM_LOW)
    // `uvm_info("get_type_name",{"using uvm_default_tree_printer\n",s.sprint(uvm_default_tree_printer)},UVM_LOW)
    // `uvm_info("get_type_name",{"using uvm_default_line_printer\n",s.sprint(uvm_default_line_printer)},UVM_LOW)
endfunction:do_print
//calculate crc result
function void lin_trans::post_randomize();
    int i;
    bit [8:0] classic_checksum = 0;
    bit [8:0] enhanced_checksum = 0;
//--------------------------generate the parity bit of identifier[7:6]------------------------------------
//    The parity is calculated on the frame identifier bits as shown in equations (1) and (2):
//    P0 = ID0 ⊕ ID1 ⊕ ID2 ⊕ ID4    -----bit6
//    P1 = ¬(ID1 ⊕ ID3 ⊕ ID4 ⊕ ID5) -----bit7
    bit p0 = identifier[0] ^ identifier[1] ^ identifier[2] ^ identifier[4];
    bit p1 = ~(identifier[1] ^ identifier[3] ^ identifier[4] ^ identifier[5]);
    identifier[7:6] = {p1,p0};
//--------------------------generate the checksum------------------------------------
    //------------------------ classic checksum --------------------------------//
    // bit [8:0] classic_checksum = 0;
    for(i=0;i<data.size;i++)begin
        classic_checksum = classic_checksum + data[i];
        if(classic_checksum >= 256) classic_checksum = classic_checksum - 255;
    end
    //------------------------ enhanced checksum -------------------------------// 
    // bit [8:0] enhanced_checksum = 0;
    enhanced_checksum = enhanced_checksum + identifier;
    for(i=0;i<data.size;i++)begin
        enhanced_checksum = enhanced_checksum + data[i];
        if(enhanced_checksum >= 256) enhanced_checksum = enhanced_checksum - 255;
    end
    checksum = ~classic_checksum[8-1:0];
    `uvm_info(get_type_name(),"gengerate checksum",UVM_DEBUG)
endfunction:post_randomize

function bit[14:0] lin_trans::crc_gen(bit[14:0] crc_default,bit[7:0] data);
    int data_temp,crc_temp,i;
    data_temp = data;
    crc_temp  = crc_default;
    crc_temp ^=data_temp <<7;
    for (i = 0; i < 8; i++) begin
        crc_temp <<= 1;
        if (crc_temp & 'h8000) begin
            crc_temp ^= 'hc599;
        end
    end
    return crc_temp & 'h7fff;
endfunction:crc_gen
`endif