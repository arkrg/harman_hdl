set TARGET [lindex $argv 0]
set MODE [lindex $argv 1]
set TOP [lindex $argv 2]

set pkg_files [glob ../../${TARGET}/pkg/*.sv]
set if_files [glob ../../ifs/*.sv]
set src_files [glob ../../${TARGET}/src/*.sv ]
set tb_file [glob ../../${TARGET}/tb/${TOP}.sv]

#exec xvlog -sv {*}$pkg_files {*}$tb_files {*}$src_files 

## elab
#exec xelab tb_${TARGET} -debug typical -log compile.log

if {[string equal $MODE "uvm"]} {
    set tb_files [glob ../../$TARGET/uvm/tb/$TOP.sv]
    exec xvlog -sv {*}$pkg_files {*}$tb_file {*}$src_files {*}$if_files -L uvm
    # elaborate
    exec xelab ${TOP} -debug typical -log compile.log -L uvm
} else {
    set tb_files [glob ../../$TARGET/tb/$TOP.sv]
    exec xvlog -sv {*}$pkg_files {*}$tb_file {*}$src_files {*}$if_files
    # elaborate
    exec xelab ${TOP} -debug typical -log compile.log
}


