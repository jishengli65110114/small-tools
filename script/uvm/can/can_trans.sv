`ifndef CAN_TRANS_SV
`define CAN_TRANS_SV

typedef enum {data_frame,remote_fram,error_fram,overload_fram,gap_fram} fram_type;
typedef enum {can,can_fd} bus_type;
// import "DPI-C"function U16 ComputeCrc15(std::vector<BitState> &bits, U32 num_bits);
// import "DPI-C"function U16 MakeCRC15(std::vector<BitState> &bits, U32 num_bits);
// import "DPI-C"function int can_crc_next(input bit[15:0] crc,input bit[7:0] data);
// import "DPI-C"function uint16_t can_crc_next(uint16_t crc, uint8_t data);
class can_trans extends uvm_sequence_item;
//can bus fram struct    
    //  Group: Variables
    rand bit [11-1:0] identify_can;
    rand bit          rtr_can;
    rand bit          ide_can;
    rand bit          r0_can;
    rand bit [4-1:0]  dlc_can;
    rand bit [8-1:0]  data_can[];
    rand bit [15-1:0] crc_sequence_can;
            
//can_fd fram struct
    //  Group: Variables
    rand bit [11-1:0] identify_can_fd;
    rand bit          r1_can_fd;//
    rand bit          ide_can_fd;
    rand bit          edl_can_fd;
    rand bit          r0_can_fd;
    rand bit          brs_can_fd;
    rand bit          esi_can_fd;
    rand bit [4-1:0]  dlc_can_fd;
    rand bit [8-1:0]  data_can_fd[];
    rand bit [4-1:0]  stuff_count_can_rd;
    rand bit [17-1:0] crc_can_fd1;
    rand bit [21-1:0] crc_can_fd2;
    rand bit [3-1:0]  ifs_can_fd;

//control parameter  
    rand int                    fram_gap;
    rand fram_type              data_type;
    rand bus_type               can_type;
//apply to collect data by monitor
    rand bit [8-1:0] data_collect[$];
//temperation variable
    can_trans trans;
    bit cmp;
    string  s;
    `uvm_object_utils_begin(can_trans)
        `uvm_field_int(identify_can,UVM_ALL_ON)
        `uvm_field_int(rtr_can,UVM_ALL_ON)
        `uvm_field_int(ide_can,UVM_ALL_ON)
        `uvm_field_int(r0_can,UVM_ALL_ON)
        `uvm_field_int(dlc_can,UVM_ALL_ON)
        `uvm_field_array_int(data_can,UVM_ALL_ON)
        `uvm_field_int(crc_sequence_can,UVM_ALL_ON)

        `uvm_field_int(identify_can_fd,UVM_ALL_ON)
        `uvm_field_int(r1_can_fd,UVM_ALL_ON)
        `uvm_field_int(ide_can_fd,UVM_ALL_ON)
        `uvm_field_int(edl_can_fd,UVM_ALL_ON)
        `uvm_field_int(r0_can_fd,UVM_ALL_ON)
        `uvm_field_int(brs_can_fd,UVM_ALL_ON)
        `uvm_field_int(esi_can_fd,UVM_ALL_ON)
        `uvm_field_int(dlc_can_fd,UVM_ALL_ON)    
        `uvm_field_array_int(data_can_fd,UVM_ALL_ON)
        `uvm_field_int(stuff_count_can_rd,UVM_ALL_ON)
        `uvm_field_int(crc_can_fd1,UVM_ALL_ON)
        `uvm_field_int(crc_can_fd2,UVM_ALL_ON)

        `uvm_field_int(fram_gap,UVM_ALL_ON)
        `uvm_field_enum(fram_type,data_type,UVM_ALL_ON|UVM_NOCOMPARE)
        `uvm_field_enum(bus_type,can_type,UVM_ALL_ON|UVM_NOCOMPARE) 
        `uvm_field_int(ifs_can_fd,UVM_ALL_ON)       
    `uvm_object_utils_end

    //  Group: Constraints
    constraint trans_cstr {
        if(dlc_can <= 8)
            soft data_can.size == dlc_can;
        else 
            soft data_can.size == 8;
        if(dlc_can_fd <= 8)
            soft data_can_fd.size == dlc_can_fd;
        else if(dlc_can_fd <= 12)
            soft data_can_fd.size == (dlc_can_fd-8)*4 + 8;
        else if(dlc_can_fd <= 13)
            soft data_can_fd.size == 32;
        else 
            soft data_can_fd.size == 32 + (dlc_can_fd-13)*16;
        // soft data.size dist {1:=10,2:=10,4:=10,8:=10};
        soft fram_gap inside {[0:100]};
        soft data_type inside {data_frame};
        soft rtr_can    == 0;
        soft ide_can    == 0;
        soft r0_can     == 0;
        soft r1_can_fd  == 0;
        soft ide_can_fd == 0;
        soft edl_can_fd dist {0:=90,1:=10};//1-can_fd fram 0-can fram 
        soft r0_can_fd  == 0;
        soft brs_can_fd dist {[0:1]:/50};//1-trans rate is 20Mhz 0-trans rate is 500KHz
        soft dlc_can inside {[1:8]};
    }
    //  Group: Functions

    //  Constructor: new
    extern function new(string name = "can_trans");
    extern virtual function string convert2string();
    extern virtual function void do_copy(uvm_object rhs);
    extern virtual function bit do_compare(uvm_object rhs,uvm_comparer comparer);
    extern virtual function void do_print(uvm_printer printer);
    extern function void post_randomize();
//crc_15 ---- 0xc599 ; crc_17 ---- 0x3685b ; crc_21 ---- 0x302899
    extern function bit[14:0]crc15_gen(bit[14:0]crc_default,bit data);
    extern function bit[16:0]crc17_gen(bit[16:0]crc_default,bit data);
    extern function bit[20:0]crc21_gen(bit[20:0]crc_default,bit data);
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
    
endclass:can_trans

/*----------------------------------------------------------------------------*/
/*  Constraints                                                               */
/*----------------------------------------------------------------------------*/



/*----------------------------------------------------------------------------*/
/*  Functions                                                                 */
/*----------------------------------------------------------------------------*/
function can_trans::new(string name = "can_trans");
    super.new(name);
endfunction: new

function string can_trans::convert2string();
    s = super.convert2string();
    // s = {s,$sformatf("sync is :%s ",this.sync)};
    // s = {s,$sformatf("identifier is :%s ",this.identifier)};
    // s = {s,$sformatf("r0ponse_space is :%s ",this.r0ponse_space)};
    // s = {s,$sformatf("data.size is :%s ",this.data.size)};
    // s = {s,$sformatf("data is :%s ",this.data )};
    // s = {s,$sformatf("checksum is :%s ",this.checksum)};
    // s = {s,$sformatf("inter_byte_space is :%s ",this.inter_byte_space)};

    // s = {s,$sformatf("fram gap is :%d ",this.fram_gap)};
    // s = {s,$sformatf("data_type is :%s ",this.data_type)};
    // s = {s,$sformatf("data_role is :%d ",this.data_role)};
    return s;
endfunction:convert2string

function void can_trans::do_copy(uvm_object rhs);
    super.do_copy(rhs);
    // void'($cast(trans,rhs));
    // this.can_break          = trans.can_break;
    // this.sync               = trans.sync;
    // this.identifier         = trans.identifier;
    // this.r0ponse_space     = trans.r0ponse_space;
    // this.data               = trans.data;
    // this.checksum           = trans.checksum;
    // this.inter_byte_space   = trans.inter_byte_space;
    // this.fram_gap           = trans.fram_gap;
    // this.data_type          = trans.data_type;
    // this.data_role          = trans.data_role;
endfunction:do_copy

function bit can_trans::do_compare(uvm_object rhs,uvm_comparer comparer);
    // can_trans trans;
    // bit cmp = 1;
    // void'($cast(trans,rhs));
    // cmp = (super.do_compare(rhs,comparer) && this.data == trans.data && this.identifier == trans.identifier);
    // return cmp;

endfunction:do_compare 

function void can_trans::do_print(uvm_printer printer);
    super.do_print(printer);
    s = convert2string();
    `uvm_info("get_type_name",{"the printe content is %s\n",s},UVM_LOW)
    // `uvm_info("get_type_name",{"using uvm_default_printer\n",s.sprint()},UVM_LOW)
    // `uvm_info("get_type_name",{"using uvm_default_table_printer\n",s.sprint(uvm_default_table_printer)},UVM_LOW)
    // `uvm_info("get_type_name",{"using uvm_default_tree_printer\n",s.sprint(uvm_default_tree_printer)},UVM_LOW)
    // `uvm_info("get_type_name",{"using uvm_default_cane_printer\n",s.sprint(uvm_default_cane_printer)},UVM_LOW)
endfunction:do_print
//calculate crc sequence
function void can_trans::post_randomize();
    int i,j;
    if(can_type == can)begin
        crc_sequence_can = 0;
        //crc15
        //calculate sof(0)
        crc_sequence_can = crc15_gen(crc_sequence_can,0);
        //calculate identifier
        for(i=0;i<11;i++)begin
            crc_sequence_can = crc15_gen(crc_sequence_can,identify_can[10-i]);
        end
        //calculate rtr
        crc_sequence_can = crc15_gen(crc_sequence_can,rtr_can);
        //calculate ide
        crc_sequence_can = crc15_gen(crc_sequence_can,ide_can);
        //calculate r0
        crc_sequence_can = crc15_gen(crc_sequence_can,r0_can);
        //calculate dlc
        for(i=0;i<4;i++)begin
            crc_sequence_can = crc15_gen(crc_sequence_can,dlc_can[3-i]);
        end
        //calculate data
        for(i=0;i<dlc_can;i++)begin
            for(j=0;j<8;j++)begin
                crc_sequence_can = crc15_gen(crc_sequence_can,data_can[i][7-j]);
            end
        end
    end
    else if(can_type == can_fd)begin
        if(dlc_can_fd<= 16)begin
            crc_can_fd1 = 0;
            //crc17
            //calculate sof(0)
            crc_can_fd1 = crc17_gen(crc_can_fd1,0);
            //calculate identifier
            for(i=0;i<11;i++)begin
                crc_can_fd1 = crc17_gen(crc_can_fd1,identify_can_fd[10-i]);
            end
            //calculate r1
            crc_can_fd1 = crc17_gen(crc_can_fd1,r1_can_fd);
            //calculate ide
            crc_can_fd1 = crc17_gen(crc_can_fd1,ide_can_fd);
            //calculate edl
            crc_can_fd1 = crc17_gen(crc_can_fd1,edl_can_fd);
            //calculate r0
            crc_can_fd1 = crc17_gen(crc_can_fd1,r0_can_fd);
            //calculate brs
            crc_can_fd1 = crc17_gen(crc_can_fd1,brs_can_fd);
            //calculate esi
            crc_can_fd1 = crc17_gen(crc_can_fd1,esi_can_fd);
            //calculate dlc
            for(i=0;i<4;i++)begin
                crc_can_fd1 = crc17_gen(crc_can_fd1,dlc_can_fd[3-i]);
            end
            //calculate data
            for(i=0;i<dlc_can_fd;i++)begin
               for(j=0;j<8;j++)begin
                    crc_can_fd1 = crc17_gen(crc_can_fd1,data_can_fd[i][7-j]);  
               end 
            end
            //calculate stuff_count
            for(i=0;i<4;i++)begin
                crc_can_fd1 = crc17_gen(crc_can_fd1,stuff_count_can_rd[3-i]);
            end
        end
        else begin
            crc_can_fd2 = 0;
            //crc21
            //calculate sof(0)
            crc_can_fd2 = crc21_gen(crc_can_fd2,0);
            //calculate identifier
            for(i=0;i<11;i++)begin
                crc_can_fd2 = crc21_gen(crc_can_fd2,identify_can_fd[10-i]);
            end
            //calculate r1
            crc_can_fd2 = crc21_gen(crc_can_fd2,r1_can_fd);
            //calculate ide
            crc_can_fd2 = crc21_gen(crc_can_fd2,ide_can_fd);
            //calculate edl
            crc_can_fd2 = crc21_gen(crc_can_fd2,edl_can_fd);
            //calculate r0
            crc_can_fd2 = crc21_gen(crc_can_fd2,r0_can_fd);
            //calculate brs
            crc_can_fd2 = crc21_gen(crc_can_fd2,brs_can_fd);
            //calculate esi
            crc_can_fd2 = crc21_gen(crc_can_fd2,esi_can_fd);
            //calculate dlc
            for(i=0;i<4;i++)begin
                crc_can_fd2 = crc21_gen(crc_can_fd2,dlc_can_fd[3-i]);
            end
            //calculate data
            for(i=0;i<dlc_can_fd;i++)begin
               for(j=0;j<8;j++)begin
                    crc_can_fd2 = crc21_gen(crc_can_fd2,data_can_fd[i][7-j]);  
               end 
            end
            //calculate stuff_count
            for(i=0;i<4;i++)begin
                crc_can_fd2 = crc21_gen(crc_can_fd1,stuff_count_can_rd[3-i]);
            end
        end
    end
    else `uvm_error(get_type_name(),"gengerate crc sequence error")
endfunction:post_randomize

function bit[14:0] can_trans::crc15_gen(bit[14:0] crc_default,bit data);
    int crc_rg;
    bit nxtbit,crc_nxt;
    nxtbit = data;
    crc_rg = crc_default; 
    crc_nxt = nxtbit ^ crc_rg[14]; 
    crc_rg = {crc_rg[13:0],1'b0};  
    if (crc_nxt) begin
        crc_rg ^= 'hc599;
    end
    return crc_rg & 'h7fff;
endfunction:crc15_gen

function bit[16:0] can_trans::crc17_gen(bit[16:0] crc_default,bit data);
    int crc_rg;
    bit nxtbit,crc_nxt;
    nxtbit = data;
    crc_rg = crc_default; 
    crc_nxt = nxtbit ^ crc_rg[16];  
    crc_rg = {crc_rg[15:0],1'b0}; 
    if (crc_nxt) begin
        crc_rg ^= 'h3685b;
    end
    return crc_rg & 'h1ffff;
endfunction:crc17_gen

function bit[20:0] can_trans::crc21_gen(bit[20:0] crc_default,bit data);
    int crc_rg;
    bit nxtbit,crc_nxt;
    nxtbit = data;
    crc_rg = crc_default; 
    crc_nxt = nxtbit ^ crc_rg[20];  
    crc_rg = {crc_rg[19:0],1'b0}; 
    if (crc_nxt) begin
        crc_rg ^= 'h302899;
    end
    return crc_rg & 'h1fffff;
endfunction:crc21_gen
`endif