#Makefile for UVM Testbench
RTL = ../Bridge_rtl/*
INC = +incdir+../AHB_agt +incdir+../APB_agt +incdir+../test +incdir+../tb
work= work #library name
SVTB1 =  ../tb/top.sv
SVTB = ../test/APB_AHB_pkg.sv
COVOP = -coveropt 3 +cover=bcft
VSIMOPT= -vopt -voptargs=+acc
VSIMBATCH= -c -do  " log -r /* ;run -all; exit"

help:
        @echo =================================================================================
        @echo "! USAGE          --  make target                                                         !"
        @echo "! clean          =>  clean the earlier log and intermediate files.               !"
        @echo "! sv_cmp         =>  Create library and compile the code.                        !"
        @echo "! run_sim    =>  run the simulation in batch mode.                       !"
        @echo "! run_test       =>  clean, compile & run the simulation in batch mode.          !"
        @echo =================================================================================
sv_cmp:
        vlib $(work)
        vmap work $(work)
        vlog -work $(work) $(RTL) $(INC) $(SVTB) $(SVTB1) $(COVOP)

run_test:sv_cmp
        #vsim  $(VSIMOPT) $(VSIMCOV) $(VSIMBATCH)  -l test.log  -sv_seed random work.top +UVM_TESTNAME=test_1
         vsim -cvgperinstance $(VSIMOPT) $(VSIMCOV) $(VSIMBATCH) -wlf wave_file1.wlf -l test.log -sv_seed random work.top +UVM_TESTNAME=test_1
         #vcover report -cvg -details -nocompactcrossbins -codeAll -assert -directive -html ahb_cg

view_wave1:
        vsim -view wave_file1.wlf

report:
        vcover report -cvg -details -nocompactcrossbins -codeAll -assert -directive -html ahb_cg

regress: clean run_test
cov:
        firefox covhtmlreport/index.html&

clean:
        rm -rf transcipt* *log* vsim.wlf fcover* covhtml* ahb_cg* *.wlf modelsim.ini
        clear

