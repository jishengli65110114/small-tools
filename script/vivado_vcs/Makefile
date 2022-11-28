#-------------------------------------------------------------------------------------------------------
vlogan_opts=-full64  
vhdlan_opts=-full64
vcs_elab_opts=-full64 -debug_all +vcd+vcdpluson  -t ps -licqueue -l elaborate.log -P ${LD_LIBRARY_PATH}/novas.tab ${LD_LIBRARY_PATH}/pli.a 
vcs_sim_opts=-ucli -licqueue -l sim.log
top=top_tb
ref_dir=/home/ICer/fpga/vcs/srcs
#-------------------------------------------------------------------------------------------------------
all:comp elaborate sim
#-------------------------------------------------------------------------------------------------------
comp: 
 # Compile design files
	vlogan  -ntb_opts   uvm
	vlogan -work xilinx_vip ${vlogan_opts} -sverilog +incdir+"/home/ICer/udp_top/udp_top.gen/sources_1/bd/micro/ipshared/25b7/hdl/verilog" +incdir+"/home/ICer/udp_top/udp_top.gen/sources_1/bd/micro/ipshared/896c/hdl/verilog" +incdir+"/home/ICer/udp_top/udp_top.gen/sources_1/bd/micro/ipshared/ec67/hdl" +incdir+"/home/ICer/udp_top/udp_top.ip_user_files/ipstatic/hdl" +incdir+"/home/ICer/udp_top/udp_top.ip_user_files/ipstatic" +incdir+"/home/ICer/udp_top/udp_top.srcs/sources_1/imports/tsn_qbv/ingress" +incdir+"/home/ICer/udp_top/udp_top.srcs/sim_1/imports/tsn_top_1g_v2.1/udp_top.srcs/sources_1/imports/tsn_qbv/ingress" +incdir+"/home/Xilinx/Vivado/2020.2/data/xilinx_vip/include" \
    ${ref_dir}/axi4stream_vip_axi4streampc.sv \
    ${ref_dir}/axi_vip_axi4pc.sv \
    ${ref_dir}/xil_common_vip_pkg.sv \
    ${ref_dir}/axi4stream_vip_pkg.sv \
    ${ref_dir}/axi_vip_pkg.sv \
    ${ref_dir}/axi4stream_vip_if.sv \
    ${ref_dir}/axi_vip_if.sv \
    ${ref_dir}/clk_vip_if.sv \
    ${ref_dir}/rst_vip_if.sv \


	vlogan -work xpm ${vlogan_opts} -sverilog +incdir+"/home/ICer/udp_top/udp_top.gen/sources_1/bd/micro/ipshared/25b7/hdl/verilog" +incdir+"/home/ICer/udp_top/udp_top.gen/sources_1/bd/micro/ipshared/896c/hdl/verilog" +incdir+"/home/ICer/udp_top/udp_top.gen/sources_1/bd/micro/ipshared/ec67/hdl" +incdir+"/home/ICer/udp_top/udp_top.ip_user_files/ipstatic/hdl" +incdir+"/home/ICer/udp_top/udp_top.ip_user_files/ipstatic" +incdir+"/home/ICer/udp_top/udp_top.srcs/sources_1/imports/tsn_qbv/ingress" +incdir+"/home/ICer/udp_top/udp_top.srcs/sim_1/imports/tsn_top_1g_v2.1/udp_top.srcs/sources_1/imports/tsn_qbv/ingress" +incdir+"/home/Xilinx/Vivado/2020.2/data/xilinx_vip/include" \
    ${ref_dir}/xpm_cdc.sv \
    ${ref_dir}/xpm_fifo.sv \
    ${ref_dir}/xpm_memory.sv \


	vhdlan -work xpm ${vhdlan_opts} \
    ${ref_dir}/xpm_VCOMP.vhd \


	vlogan -work blk_mem_gen_v8_4_4 ${vlogan_opts} +v2k +incdir+"/home/ICer/udp_top/udp_top.gen/sources_1/bd/micro/ipshared/25b7/hdl/verilog" +incdir+"/home/ICer/udp_top/udp_top.gen/sources_1/bd/micro/ipshared/896c/hdl/verilog" +incdir+"/home/ICer/udp_top/udp_top.gen/sources_1/bd/micro/ipshared/ec67/hdl" +incdir+"/home/ICer/udp_top/udp_top.ip_user_files/ipstatic/hdl" +incdir+"/home/ICer/udp_top/udp_top.ip_user_files/ipstatic" +incdir+"/home/ICer/udp_top/udp_top.srcs/sources_1/imports/tsn_qbv/ingress" +incdir+"/home/ICer/udp_top/udp_top.srcs/sim_1/imports/tsn_top_1g_v2.1/udp_top.srcs/sources_1/imports/tsn_qbv/ingress" +incdir+"/home/Xilinx/Vivado/2020.2/data/xilinx_vip/include" \
    ${ref_dir}/ip/tcam_ram/blk_mem_gen_v8_4_4/blk_mem_gen_v8_4.v \
 

	vlogan -work xil_defaultlib ${vlogan_opts} +v2k +incdir+"/home/ICer/udp_top/udp_top.gen/sources_1/bd/micro/ipshared/25b7/hdl/verilog" +incdir+"/home/ICer/udp_top/udp_top.gen/sources_1/bd/micro/ipshared/896c/hdl/verilog" +incdir+"/home/ICer/udp_top/udp_top.gen/sources_1/bd/micro/ipshared/ec67/hdl" +incdir+"/home/ICer/udp_top/udp_top.ip_user_files/ipstatic/hdl" +incdir+"/home/ICer/udp_top/udp_top.ip_user_files/ipstatic" +incdir+"/home/ICer/udp_top/udp_top.srcs/sources_1/imports/tsn_qbv/ingress" +incdir+"/home/ICer/udp_top/udp_top.srcs/sim_1/imports/tsn_top_1g_v2.1/udp_top.srcs/sources_1/imports/tsn_qbv/ingress" +incdir+"/home/Xilinx/Vivado/2020.2/data/xilinx_vip/include" \
    ${ref_dir}/ip/tcam_ram/xil_defaultlib/tcam_ram.v \
    ${ref_dir}/ip/pri_ram/xil_defaultlib/pri_ram.v \
    ${ref_dir}/ip/ivdtu_ram/xil_defaultlib/ivdtu_ram.v \
    ${ref_dir}/ip/ps_ram/xil_defaultlib/ps_ram.v \
    ${ref_dir}/ip/squence_ram/xil_defaultlib/squence_ram.v \


	vlogan -work fifo_generator_v13_2_5 ${vlogan_opts} +v2k +incdir+"/home/ICer/udp_top/udp_top.gen/sources_1/bd/micro/ipshared/25b7/hdl/verilog" +incdir+"/home/ICer/udp_top/udp_top.gen/sources_1/bd/micro/ipshared/896c/hdl/verilog" +incdir+"/home/ICer/udp_top/udp_top.gen/sources_1/bd/micro/ipshared/ec67/hdl" +incdir+"/home/ICer/udp_top/udp_top.ip_user_files/ipstatic/hdl" +incdir+"/home/ICer/udp_top/udp_top.ip_user_files/ipstatic" +incdir+"/home/ICer/udp_top/udp_top.srcs/sources_1/imports/tsn_qbv/ingress" +incdir+"/home/ICer/udp_top/udp_top.srcs/sim_1/imports/tsn_top_1g_v2.1/udp_top.srcs/sources_1/imports/tsn_qbv/ingress" +incdir+"/home/Xilinx/Vivado/2020.2/data/xilinx_vip/include" \
    ${ref_dir}/ip/dpv_fifo/fifo_generator_v13_2_5/fifo_generator_vlog_beh.v \

	vhdlan -work fifo_generator_v13_2_5 ${vhdlan_opts} \
    ${ref_dir}/ip/dpv_fifo/fifo_generator_v13_2_5/fifo_generator_v13_2_rfs.vhd \


	vlogan -work fifo_generator_v13_2_5 ${vlogan_opts} +v2k +incdir+"/home/ICer/udp_top/udp_top.gen/sources_1/bd/micro/ipshared/25b7/hdl/verilog" +incdir+"/home/ICer/udp_top/udp_top.gen/sources_1/bd/micro/ipshared/896c/hdl/verilog" +incdir+"/home/ICer/udp_top/udp_top.gen/sources_1/bd/micro/ipshared/ec67/hdl" +incdir+"/home/ICer/udp_top/udp_top.ip_user_files/ipstatic/hdl" +incdir+"/home/ICer/udp_top/udp_top.ip_user_files/ipstatic" +incdir+"/home/ICer/udp_top/udp_top.srcs/sources_1/imports/tsn_qbv/ingress" +incdir+"/home/ICer/udp_top/udp_top.srcs/sim_1/imports/tsn_top_1g_v2.1/udp_top.srcs/sources_1/imports/tsn_qbv/ingress" +incdir+"/home/Xilinx/Vivado/2020.2/data/xilinx_vip/include" \
    ${ref_dir}/ip/dpv_fifo/fifo_generator_v13_2_5/fifo_generator_v13_2_rfs.v \


	vlogan -work xil_defaultlib ${vlogan_opts} +v2k +incdir+"/home/ICer/udp_top/udp_top.gen/sources_1/bd/micro/ipshared/25b7/hdl/verilog" +incdir+"/home/ICer/udp_top/udp_top.gen/sources_1/bd/micro/ipshared/896c/hdl/verilog" +incdir+"/home/ICer/udp_top/udp_top.gen/sources_1/bd/micro/ipshared/ec67/hdl" +incdir+"/home/ICer/udp_top/udp_top.ip_user_files/ipstatic/hdl" +incdir+"/home/ICer/udp_top/udp_top.ip_user_files/ipstatic" +incdir+"/home/ICer/udp_top/udp_top.srcs/sources_1/imports/tsn_qbv/ingress" +incdir+"/home/ICer/udp_top/udp_top.srcs/sim_1/imports/tsn_top_1g_v2.1/udp_top.srcs/sources_1/imports/tsn_qbv/ingress" +incdir+"/home/Xilinx/Vivado/2020.2/data/xilinx_vip/include" \
    ${ref_dir}/ip/dpv_fifo/xil_defaultlib/dpv_fifo.v \
    ${ref_dir}/ip/pri_fifo/xil_defaultlib/pri_fifo.v \
    ${ref_dir}/ip/stu_table/xil_defaultlib/stu_table.v \
    ${ref_dir}/ip/hash_backet/xil_defaultlib/hash_backet.v \
    ${ref_dir}/ip/cam_table/xil_defaultlib/cam_table.v \
    ${ref_dir}/ip/cam_fifo/xil_defaultlib/cam_fifo.v \
    ${ref_dir}/ip/sseh_fifo/xil_defaultlib/sseh_fifo.v \
    ${ref_dir}/ip/ram_data_fifo_w32d16/xil_defaultlib/ram_data_fifo_w32d16.v \
    ${ref_dir}/ip/css_fifo/xil_defaultlib/css_fifo.v \
    ${ref_dir}/ip/vtu_table/xil_defaultlib/vtu_table.v \
    ${ref_dir}/ip/tcam_table/xil_defaultlib/tcam_table.v \
    ${ref_dir}/ip/att_ram_table/xil_defaultlib/att_ram_table.v \
    ${ref_dir}/aging.v \
    ${ref_dir}/att_table.v \
    ${ref_dir}/atu.v \
    ${ref_dir}/cam.v \
    ${ref_dir}/crc_10.v \
    ${ref_dir}/debug.v \
    ${ref_dir}/dpv.v \
    ${ref_dir}/inquire.v \
    ${ref_dir}/ivdtu.v \
    ${ref_dir}/lookup_table_q.v \
    ${ref_dir}/port_dispatch.v \
    ${ref_dir}/port_sch.v \
    ${ref_dir}/prio.v \
    ${ref_dir}/static_cof.v \
    ${ref_dir}/stu.v \
    ${ref_dir}/study.v \
    ${ref_dir}/tcam.v \
    ${ref_dir}/tcam_crc.v \
    ${ref_dir}/vtu.v \


	vlogan -work xil_defaultlib ${vlogan_opts} -sverilog +incdir+"/home/ICer/udp_top/udp_top.gen/sources_1/bd/micro/ipshared/25b7/hdl/verilog" +incdir+"/home/ICer/udp_top/udp_top.gen/sources_1/bd/micro/ipshared/896c/hdl/verilog" +incdir+"/home/ICer/udp_top/udp_top.gen/sources_1/bd/micro/ipshared/ec67/hdl" +incdir+"/home/ICer/udp_top/udp_top.ip_user_files/ipstatic/hdl" +incdir+"/home/ICer/udp_top/udp_top.ip_user_files/ipstatic" +incdir+"/home/ICer/udp_top/udp_top.srcs/sources_1/imports/tsn_qbv/ingress" +incdir+"/home/ICer/udp_top/udp_top.srcs/sim_1/imports/tsn_top_1g_v2.1/udp_top.srcs/sources_1/imports/tsn_qbv/ingress" +incdir+"/home/Xilinx/Vivado/2020.2/data/xilinx_vip/include" \
    ${ref_dir}/my_if.sv \
    ${ref_dir}/top_tb.SV   -ntb_opts   uvm\
  


	vlogan -work xil_defaultlib ${vlogan_opts} +v2k \
    "/home/ICer/fpga/vcs/glbl.v" 
 








  



#-------------------------------------------------------------------------------------------------------

	
#-------------------------------------------------------------------------------------------------------
elaborate:
	vcs   ${vcs_elab_opts} xil_defaultlib.${top} xil_defaultlib.glbl -ntb_opts   uvm  -o ${top}_simv \
	-cm line+branch+tgl \
	-cm_name ${top} \
	-cm_dir ./${top}.vdb \ 
        -timesacle=1ns/1ps\
#-------------------------------------------------------------------------------------------------------
sim:
	./${top}_simv $(vcs_sim_opts)  -do simulate.do \
	-cm line+cond+fsm+branch+tgl \
	-cm_name ${top} \
	-cm_dir ./${top}.vdb\
#-------------------------------------------------------------------------------------------------------
coverage:
	dve -full64 -covdir *.vdb 
#-------------------------------------------------------------------------------------------------------
urg:
	urg -full64 -dir ${top}.vdb -report coverage_report &
#-------------------------------------------------------------------------------------------------------
verdi:
	verdi +v2k   -uvm -f filelist.f   -ssf *.fsdb  -nologo &
#-------------------------------------------------------------------------------------------------------
dve:
	dve -vpd *.vpd  
#---------------------------------------------------------------------------------------------------------
debug:
	./${top}_simv -gui
	
#-------------------------------------------------------------------------------------------------------
clean:
	 rm  -rf  *~  core  csrc  *simv  vc_hdrs.h  ucli.key  urg* *.log  novas.* \
	*.fsdb* verdiLog  64* DVEfiles *.vpd *_report *.vdb *.daidir
#-------------------------------------------------------------------------------------------------------
