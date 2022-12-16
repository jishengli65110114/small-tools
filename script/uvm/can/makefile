all:clean comp run
#############################
# User variables
#############################
TB       = can_tb_top
SEED     = 1
CTEST   ?= 0
DUT_DIR = /home/ICer/jishengli/2022Q4/uvm_q4/can_bus2/dut
CFILES = dpi_ref.c
COMPLIST = complist.f
COVERAGE_DIR = ./coverage
LOG_DIR = ./log
CM_DIR = ./coverage

TIMESCALE = 1ns/1ps
#CM_TYPE = cond+tgl+line+fsm+path
CM_TYPE = cond+tgl+line+fsm
#UVM_LIB
UVM_HOME = /home/synopsys/verdi/Verdi_O-2018.09-SP2/share/vmlib/uvm/uvm-1.2/lib/src
#PATH OF VERDI
NOVAS_HOME = /home/synopsys/verdi/Verdi_O-2018.09-SP2
UVM_VERBOSITY = UVM_DEBUG
UVM_PATH = /mnt/hgfs/jishengli/sda2/ubutun/2022Q4/uvm_q4/gitlab_uvm/common_dv/can

#############################
# Environment variables
#############################
#VCOMP    = vlogan -full64 -ntb_opts uvm-1.2 -sverilog -timescale=1ns/1ps -nc -l log/comp.log +incdir+$(INC_DIR)
#ELAB     = vcs -full64 -ntb_opts uvm-1.2 -debug_all -l log/elab.log -sim_res=1ps -cm line+tgl+branch -cm_hier cm.cfg 

#BASE_VCOMP     = vcs -full64 +acc +vpi -sverilog +v2k -lca $(UVM_HOME)/src/dpi/uvm_dpi.cc -DVCS -l $(LOG_DIR)/comp.log -timescale=$(TIMESCALE) -f $(COMPLIST) +incdir+$(DUT_DIR) -debug_all -cm $(CM_TYPE) -cm_pp -cm_log $(LOG_DIR)/coverage.log -cm_dir $(CM_DIR)

VCOMP_VERDI = -LDFLAGS -rdynamic -fsdb -P ${NOVAS_HOME}/share/PLI/VCS/LINUX64/novas.tab \
              ${NOVAS_HOME}/share/PLI/VCS/LINUX64/pli.a \
              +DUMP_FSDB  



VCOMP     = vcs -full64 -debug_access+r+w+nomemcbk -debug_region+cell +vpi -sverilog +v2k \
            -l $(LOG_DIR)/comp.log -timescale=$(TIMESCALE) +incdir+$(DUT_DIR) \
			+incdir+$(DUT_DIR)+$(UVM_PATH)/uvm+$(UVM_PATH)/tb+$(UVM_PATH)/uvm/component+$(UVM_PATH)/uvm/interface \
			+incdir+$(UVM_PATH)/uvm/obj+$(UVM_PATH)/uvm/test_case+$(UVM_PATH)/uvm/obj/sequence \
            -debug_acc+all -debug_region+cell+encrypt -cm $(CM_TYPE) -lca -cm_log $(LOG_DIR)/coverage.log \
            -cm_dir $(CM_DIR) ${VCOMP_VERDI} -cm_nocasedef -ntb_opts uvm-1.2 \
			+lint=TFIPC-L \
			/mnt/hgfs/jishengli/sda2/ubutun/2022Q4/uvm_q4/gitlab_uvm/common_dv/can/uvm/interface/can_agt_if.sv \
			/mnt/hgfs/jishengli/sda2/ubutun/2022Q4/uvm_q4/gitlab_uvm/common_dv/can/uvm/interface/can_env_if.sv \
			/mnt/hgfs/jishengli/sda2/ubutun/2022Q4/uvm_q4/gitlab_uvm/common_dv/can/uvm/can_agt_pkg.sv \
			/mnt/hgfs/jishengli/sda2/ubutun/2022Q4/uvm_q4/gitlab_uvm/common_dv/can/uvm/can_env_pkg.sv \
			/mnt/hgfs/jishengli/sda2/ubutun/2022Q4/uvm_q4/gitlab_uvm/common_dv/can/uvm/can_tc_pkg.sv \
			/mnt/hgfs/jishengli/sda2/ubutun/2022Q4/uvm_q4/gitlab_uvm/common_dv/can/tb/can_tb_top.sv 
#			-cpp g++-4.8 -cc gcc-4.8 -LDFLAGS -Wl \
#           +v2k $(UVM_HOME)/src/dpi/uvm_dpi.cc -CFLAGS -DVCS \
#			-cpp g++ -cc gcc -LDFLAGS -Wl,--no-as-needed \
#			/mnt/hgfs/jishengli/sda2/ubutun/2022Q4/uvm_q4/can_bus/uvm/cpp/crc_15.cpp \
#			-f $(COMPLIST) 
#			-cm_pp 


#VCOMP_VERDI = $(BASE_VCOMP) -LDFLAGS -rdynamic -fsdb -P ${NOVAS_HOME}/share/PLI/VCS/LINUX64/novas.tab ${NOVAS_HOME}/share/PLI/VCS/LINUX64/pli.a  +DUMP_FSDB  



RUN_CASE0      = ./simv +UVM_VERBOSITY=$(UVM_VERBOSITY) -l log/run.log -sml -cm line+tgl+branch -cm_name $(TB)_$(SEED) +ntb_random_seed=$(SEED) +UVM_TESTNAME=my_case0
RUN_CASE1      = ./simv +UVM_VERBOSITY=$(UVM_VERBOSITY) -l log/run.log -sml -cm line+tgl+branch -cm_name $(TB)_$(SEED) +ntb_random_seed=$(SEED) +UVM_TESTNAME=my_case1
RUN_CASE2      = ./simv +UVM_VERBOSITY=$(UVM_VERBOSITY) -l log/run.log -sml -cm line+tgl+branch -cm_name $(TB)_$(SEED) +ntb_random_seed=$(SEED) +UVM_TESTNAME=my_case2

DVE_COV = dve -covdir *.vdb &
DVE_VPD = dve -vpd vcdplus.vpd
RUN_VERDI = Verdi -elab simv.daidir/kdb -l $(LOG_DIR)/verdi_run.log -ssf $(TB).fsdb

ifeq ($(CTEST),1)
	VCOMP += dpi_ref.c
endif

comp:
	$(VCOMP)

#compv:
#	$(VCOMP_VERDI)

run:
	$(RUN_CASE0)

cov:
	$(DVE_COV)

vpd:
	$(DVE_VPD)


#rung:
#	$(RUN) -gui
#build html report
urg:
	urg -lca -dir *.vdb & 

verdi:
	$(RUN_VERDI)


clean:
	rm -rf AN.DB DVEfiles csrc *.simv *.simv.daidir *.simv.vdb ucli.key *.vdb VerdiLog *.daidir \ 
	rm -rf log/* *.vpd *.h *.fsdb simv *.dat novas.* *.log *.log.sml urgReport/*

	
	
# simv:filelist.f	
# 	vcs -full64 -cpp g++-4.8 -cc gcc-4.8 -LDFLAGS -Wl,--no-as-needed \
#       -f filelist.f \
#       -sverilog \
#       -debug_access+all \
#       -kdb \
#       -timescale=1ns/1ps \
#       -l com.log
 
# #修改vcs -full64 \，添加-cpp g++-4.8 -cc gcc-4.8 -LDFLAGS -Wl,--no-as-needed \