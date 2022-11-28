#top_module=tb_lookup_table_top
rsfile=/home/eda/Desktop/nLintLog/nrules_li_v1.01.rs
nLint_opts=-gui -verilog -2001 -beauty \
	   -detail -auto_compile on -out output.log
# nLint_opts=-gui -verilog -2001 -beauty -detail -ex_clk -l lint.log -sorts &

all:clean nlit

nlit:
	nLint ${nLint_opts} -rs ${rsfile} -f filelist.f &
#	nLint ${nLint_opts} -top ${top_module} -rs ${rsfile} -f filelist.f
clean:
	rm -rf *.log *Log *DB *++

###---Any error or warning message, please refer to "/home/eda/Desktop/nLintLog/nLintLog/compiler.log"---###
