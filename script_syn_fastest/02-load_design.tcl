#################################
# SETUP THE DESIGN
#################################

# Check that the design is free of latches:
set hdlin_check_no_latch true

### DEFINE DESIGN FILES #########################################
#
# Set the name of the top-module:
set TOP_LEVEL_MODULE	"Controller"
#
# List all source files of the design:
set FILE_LIST	{Controller.v Position_check.v Demux_1to2.v FIR_filter.v}
#
#################################################################

#set verilogout_no_tri true

# Create subdirectories for temporary files to keep syn folder clean:
if [file exists results] {
  file delete -force results
}
file mkdir results
set_vsdc results/design.vsdc
set_svf  results/design.svf

if [file exists WORK] {
  file delete -force WORK
}
file mkdir WORK
define_design_lib WORK -path ./WORK
