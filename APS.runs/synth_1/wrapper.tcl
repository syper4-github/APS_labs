# 
# Synthesis run script generated by Vivado
# 

set TIME_start [clock seconds] 
proc create_report { reportName command } {
  set status "."
  append status $reportName ".fail"
  if { [file exists $status] } {
    eval file delete [glob $status]
  }
  send_msg_id runtcl-4 info "Executing : $command"
  set retval [eval catch { $command } msg]
  if { $retval != 0 } {
    set fp [open $status w]
    close $fp
    send_msg_id runtcl-5 warning "$msg"
  }
}
set_param xicom.use_bs_reader 1
create_project -in_memory -part xc7a100tcsg324-1

set_param project.singleFileAddWarning.threshold 0
set_param project.compositeFile.enableAutoGeneration 0
set_param synth.vivado.isSynthRun true
set_property webtalk.parent_dir D:/8200428/APS/APS.cache/wt [current_project]
set_property parent.project_path D:/8200428/APS/APS.xpr [current_project]
set_property default_lib xil_defaultlib [current_project]
set_property target_language Verilog [current_project]
set_property ip_output_repo d:/8200428/APS/APS.cache/ip [current_project]
set_property ip_cache_permissions {read write} [current_project]
read_mem {
  D:/8200428/APS/APS.srcs/sources_1/new/Instructions.txt
  D:/8200428/APS/APS.srcs/sources_1/new/defines_riscv.v
  D:/8200428/APS/APS.srcs/sources_1/new/Data.txt
}
read_verilog -library xil_defaultlib -sv {
  D:/8200428/APS/APS.srcs/sources_1/new/miriscv_top.sv
  D:/8200428/APS/APS.srcs/sources_1/new/miriscv_ram.sv
  D:/8200428/APS/APS.srcs/sources_1/new/IC.sv
  D:/8200428/APS/APS.srcs/sources_1/new/Controller_Switch.sv
  D:/8200428/APS/APS.srcs/sources_1/new/Controller_Led.sv
}
read_verilog -library xil_defaultlib {
  D:/8200428/APS/APS.srcs/sources_1/new/ALU.v
  D:/8200428/APS/APS.srcs/sources_1/new/wrapper.v
  D:/8200428/APS/APS.srcs/sources_1/new/RF.v
  D:/8200428/APS/APS.srcs/sources_1/new/RISC_V_decode.v
  D:/8200428/APS/APS.srcs/sources_1/new/miriscv_core.v
  D:/8200428/APS/APS.srcs/sources_1/new/miriscv_lsu.v
  D:/8200428/APS/APS.srcs/sources_1/new/CSR.v
  D:/8200428/APS/APS.srcs/sources_1/new/AddressDecoder.v
}
# Mark all dcp files as not used in implementation to prevent them from being
# stitched into the results of this synthesis run. Any black boxes in the
# design are intentionally left as such for best results. Dcp files will be
# stitched into the design at a later time, either when this synthesis run is
# opened, or when it is stitched into a dependent implementation run.
foreach dcp [get_files -quiet -all -filter file_type=="Design\ Checkpoint"] {
  set_property used_in_implementation false $dcp
}
read_xdc D:/8200428/APS/APS.srcs/constrs_1/new/constr.xdc
set_property used_in_implementation false [get_files D:/8200428/APS/APS.srcs/constrs_1/new/constr.xdc]

set_param ips.enableIPCacheLiteLoad 1
close [open __synthesis_is_running__ w]

synth_design -top wrapper -part xc7a100tcsg324-1


# disable binary constraint mode for synth run checkpoints
set_param constraints.enableBinaryConstraints false
write_checkpoint -force -noxdef wrapper.dcp
create_report "synth_1_synth_report_utilization_0" "report_utilization -file wrapper_utilization_synth.rpt -pb wrapper_utilization_synth.pb"
file delete __synthesis_is_running__
close [open __synthesis_is_complete__ w]
