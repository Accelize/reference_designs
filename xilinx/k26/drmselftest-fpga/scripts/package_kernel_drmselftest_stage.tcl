#
# Copyright (C) 2020 Xilinx, Inc
#
# Licensed under the Apache License, Version 2.0 (the "License"). You may
# not use this file except in compliance with the License. A copy of the
# License is located at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
# WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
# License for the specific language governing permissions and limitations
# under the License.
#

set path_to_hdl "./src/drmselftest_stage/hdl"
set path_to_packaged "./packaged_kernel/${suffix}"
set path_to_tmp_project "./tmp_project_${suffix}"

create_project -force kernel_pack $path_to_tmp_project

# Accelize #####################################################
set path_to_drm_hdk "./src/drm_hdk"
read_vhdl -library drm_library $path_to_drm_hdk/common/vhdl/xilinx/drm_all_components.vhdl
read_vhdl -library drm_library $path_to_drm_hdk/accelize.com_demo_drmselftest_ip_1.0.0/core/drm_ip_activator_package_0x1003001e00010001.vhdl
read_vhdl -library drm_0x1003001e00010001_library $path_to_drm_hdk/accelize.com_demo_drmselftest_ip_1.0.0/core/drm_ip_activator_0x1003001e00010001.vhdl
read_verilog -sv $path_to_drm_hdk/accelize.com_demo_drmselftest_ip_1.0.0/syn/top_drm_activator_0x1003001e00010001.sv
# Accelize #####################################################

add_files -norecurse [glob $path_to_hdl/*.v $path_to_hdl/*.sv $path_to_hdl/*.vh]
set_property top krnl_drmselftest_stage_rtl [current_fileset]

update_compile_order -fileset sources_1
update_compile_order -fileset sim_1
ipx::package_project -root_dir $path_to_packaged -vendor xilinx.com -library RTLKernel -taxonomy /KernelIP -import_files -set_current false
ipx::unload_core $path_to_packaged/component.xml
ipx::edit_ip_in_project -upgrade true -name tmp_edit_project -directory $path_to_packaged $path_to_packaged/component.xml
set_property core_revision 2 [ipx::current_core]
foreach up [ipx::get_user_parameters] {
  ipx::remove_user_parameter [get_property NAME $up] [ipx::current_core]
}
set_property sdx_kernel true [ipx::current_core]
set_property sdx_kernel_type rtl [ipx::current_core]
ipx::create_xgui_files [ipx::current_core]
ipx::infer_bus_interface ap_clk xilinx.com:signal:clock_rtl:1.0 [ipx::current_core]
ipx::infer_bus_interface ap_rst_n xilinx.com:signal:reset_rtl:1.0 [ipx::current_core]
ipx::associate_bus_interfaces -busif s_axi_control -clock ap_clk [ipx::current_core]
ipx::associate_bus_interfaces -busif p0 -clock ap_clk [ipx::current_core]
ipx::associate_bus_interfaces -busif p1 -clock ap_clk [ipx::current_core]
ipx::associate_bus_interfaces -busif drm_to_uip -clock ap_clk [ipx::current_core]
ipx::associate_bus_interfaces -busif uip_to_drm -clock ap_clk [ipx::current_core]
set_property xpm_libraries {XPM_CDC XPM_MEMORY XPM_FIFO} [ipx::current_core]
set_property supported_families { } [ipx::current_core]
set_property auto_family_support_level level_2 [ipx::current_core]
ipx::update_checksums [ipx::current_core]
ipx::save_core [ipx::current_core]
close_project -delete
