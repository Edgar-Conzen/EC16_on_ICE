if {[catch {

# define run engine funtion
source [file join {C:/lscc/radiant/2023.1} scripts tcl flow run_engine.tcl]
# define global variables
global para
set para(gui_mode) 1
set para(prj_dir) "C:/Git/ec16_on_ice/Radiant/ec16_on_ice"
# synthesize IPs
# synthesize VMs
# propgate constraints
file delete -force -- ec16_on_ice_impl_1_cpe.ldc
run_engine_newmsg cpe -f "ec16_on_ice_impl_1.cprj" "pll_25_20.cprj" -a "iCE40UP"  -o ec16_on_ice_impl_1_cpe.ldc
# synthesize top design
file delete -force -- ec16_on_ice_impl_1.vm ec16_on_ice_impl_1.ldc
run_engine_newmsg synthesis -f "ec16_on_ice_impl_1_lattice.synproj"
run_postsyn [list -a iCE40UP -p iCE40UP5K -t SG48 -sp High-Performance_1.2V -oc Industrial -top -w -o ec16_on_ice_impl_1_syn.udb ec16_on_ice_impl_1.vm] "C:/Git/ec16_on_ice/Radiant/ec16_on_ice/impl_1/ec16_on_ice_impl_1.ldc"

} out]} {
   runtime_log $out
   exit 1
}
