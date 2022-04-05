DRM test application bitstream
==============================

This project contains the sources and scripts to generate the bitstream required by the DRM test application
embedded within the Accelize Yocto meta-layer available at //https://github.com/Accelize/meta-accelize.

## SUPPORTED PLATFORMS
Board | Software Version
------|-----------------
Xilinx Kria Starter Kit KV260|Vitis 2021.1

&#x26a0;&#xfe0f; WARNING: Kria Platform require Vitis 2020.2.2 or later. Any prior version will not work!


Run Synthesis
=============

1. Configure environment for Vitis  2021.1
```bash
source <PATH_TO_VITIS_2021.1_INSTALL>/settings64.sh 
```

2. Build the platform (XSA & XPFM)
```bash
git clone --recursive https://github.com/Xilinx/kv260-vitis
cd kv260-vitis
git checkout remotes/origin/release-2021.1
make platform PFM=kv260_vcuDecode_vmixDP
export PLATFORM_REPO_PATHS=$PWD/platforms/xilinx_kv260_vcuDecode_vmixDP_202110_1
```

3. Install KV260 board and SOM240 Daughterboard in Vivado
Enter the following lines in Vivado TCL console or add them to your Vivado init script (~/.Xilinx/Vivado/Vivado_init.tcl)
```bash
xhub::refresh_catalog [xhub::get_xstores xilinx_board_store]
xhub::install [xhub::get_xitems *kv260*]
xhub::install [xhub::get_xitems *som240*]
set_param board.repoPaths [get_property LOCAL_ROOT_DIR [xhub::get_xstores xilinx_board_store]]
```

4. Synthesize bitstream
```bash
git clone https://github.com/Accelize/reference_designs.git --depth=1
cd reference_designs
make
```
Bitstream will be located in the *xclbin/fpgatest.xclbin* folder


Patches
=======

Please submit any patches/modification via a pull requests on the 
Accelize github

Maintainer: Accelize Support <support@accelize.com>


