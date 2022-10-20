set kernel_name [get_bd_cells -hier -filter {VLNV=~accelize.com:*:kernel_drm_controller:*}]
set kernel_ctrl_if [get_bd_addr_segs -addressables -of [get_bd_intf_pins -of_objects [get_bd_pins $kernel_name/*araddr]]]
assign_bd_address -offset 0xA0010000 -range 0x00010000 -target_address_space [get_bd_addr_spaces PS_0/Data] [get_bd_addr_segs $kernel_ctrl_if] -force

