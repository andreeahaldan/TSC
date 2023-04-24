#---------------------------------------------------------------------------------------
# Script description: compiles the project sources &
#                     starts the simulation
#---------------------------------------------------------------------------------------

# Set transcript file name
## transcript file ../reports/regression_transcript/transcript_$1

# Check if the sources must be re-compiled
# daca exista directorul de work
if {[file isdirectory work]} { 
  # nu mai compilez
  set compile_on 0             
} else {
  # compilez
  set compile_on 1             
}

# In [GUI_mode]: always compile sources / [regress_mode]: compile sources only once
# daca compile_on este 1 si batch_mode = 0 [GUI MODE]
if {$compile_on || [batch_mode] == 0} { 
  # creeza libraria work
  vlib work     
  # vlog = compileaza , -sv = sisteme de tip systemverilog, -timescale  = creaza timescale ul, -work = ia work ul , -f = foloseste sursele din .txt                                                              
  vlog -sv -timescale "1ps/1ps" -work work       -f sources.txt
  #vlog -sv -timescale "1ps/1ps" -cover bcesft -work work       -f sources.txt
}

# Load project
  eval vsim -novopt -quiet -nocoverage +notimingchecks +nowarnTSCALE -sva -g/top/test/NO_OF_TRANS=$1  -g/top/test/TYPE_OF_TRANSACTION=$2 -g/top/test/SEED=$3 top
# eval vsim -novopt -quiet -coverage +code=bcesft +notimingchecks +nowarnTSCALE -sva top

# Run log/wave commands
# Batch_mode = 0 [GUI_mode]; Batch_mode = 1 [regress_mode]
if {[batch_mode] == 0} {
  eval log -r /*
  eval do wave.do
}

# On brake:
onbreak {
  ## save coverage report file (when loading project with coverage)
    #eval coverage save "../reports/regression_coverage/coverage_$1.ucdb"
    
  # if [regress_mode]: continue script excution
  if [batch_mode > 0] {
    resume
  }
}

# Run/exit simulation
run -all
quit -sim
