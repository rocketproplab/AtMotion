TOP=sim_top

# TOP=compile_tb
SOURCES+= sim_top.sv

TB=sim_main.cpp

NO_WARNINGS=-Wno-WIDTH -Wno-REALCVT -Wno-PINMISSING -Wno-STMTDLY -Wno-UNOPTFLAT -Wno-UNSIGNED
NO_WARNINGS+=-Wno-SELRANGE -Wno-MULTIDRIVEN -Wno-COMBDLY -Wno-LITENDIAN -Wno-INITIALDLY -Wno-CASEINCOMPLETE

slow: obj_dir/${TOP}

run: obj_dir/${TOP}
	./obj_dir/V${TOP}

obj_dir/make_dir:
	mkdir -p obj_dir
	touch obj_dir/make_dir

obj_dir/${TOP}: obj_dir/V${TOP}.mk ${TB}
	cd obj_dir; make -j8 -f V${TOP}.mk


obj_dir/V${TOP}.mk: ${SOURCES} $(shell ls | grep sv)
	verilator ${NO_WARNINGS} -Wno-fatal -sv --cc ${SOURCES}  --exe ${TB} --top-module ${TOP}

# obj_dir/V${FAST_TOP}.mk: ${SOURCES_FAST} ${FAST_TB} obj_dir/altera_mf.sv
# 	verilator -Wno-fatal -sv --cc -y mips_core obj_dir/altera_mf.sv ${SOURCES_FAST}  --exe ${FAST_TB} --top-module ${FAST_TOP}

# obj_dir/V${DEBUG_TOP}.mk: ${SOURCES_DEBUG} ${DEBUG_TB} obj_dir/altera_mf.sv
# 	verilator -Wno-fatal -sv --cc -y mips_core obj_dir/altera_mf.sv ${SOURCES_DEBUG}  --exe ${DEBUG_TB} --top-module ${DEBUG_TOP}

# obj_dir/V${L2_TOP}.mk: ${SOURCES_L2} ${L2_TB}
# 	verilator -Wno-fatal -sv --cc -y mips_core ${SOURCES_L2}  --exe ${L2_TB} --top-module ${L2_TOP}

clean:
	rm -r obj_dir
