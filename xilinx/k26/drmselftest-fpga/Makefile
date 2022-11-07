#
# Accelize DRM Reference Design Makefile
#

ROOT_DIR:=$(shell dirname $(realpath $(firstword $(MAKEFILE_LIST))))

VTS_PLATFORM := k26_base_starter_kit
VTS_VERSION := 202210_1
VTS_PFM_PATH := $(ROOT_DIR)/platforms_base/xilinx_$(VTS_PLATFORM)_$(VTS_VERSION)
VTS_DTSI_PATH := $(ROOT_DIR)/dt_output

XCLBIN_ARTIFACTS = xclbin
DRM_XO = $(XCLBIN_ARTIFACTS)/drm.xo
DESIGN_OBJ=$(XCLBIN_ARTIFACTS)/drmselftest-fpga.xclbin
VTS_KERNELS = drmselftest input output
VTS_KERNELS_OBJS = $(VTS_KERNELS:%=$(XCLBIN_ARTIFACTS)/%.xo)
VTS_CFG_FILE = drmselftest.ini
VTS_LINK_SCRIPT_PATH=$(ROOT_DIR)/src/drm_hdk/post_syslink.tcl
PTLX_INPUT = ptlx_artifacts

XOCC_OPTS = -t hw --platform $(VTS_PLATFORM) --config $(VTS_CFG_FILE) --xp param:compiler.userPostSysLinkOverlayTcl=$(VTS_LINK_SCRIPT_PATH) --advanced.param "compiler.addOutputTypes=hw_export"


.PHONY: all clean cleanall platform package

all: package

check:
ifndef XILINX_VITIS
	$(error You have to define path to Vitis in XILINX_VITIS variable)
endif

$(VTS_PFM_PATH)/hw/$(VTS_PLATFORM).xsa:
	@echo "\n\n===> Generating base platform (provided by Xilinx)" 
	@make -C platforms_base platform

xsa: $(VTS_PFM_PATH)/hw/$(VTS_PLATFORM).xsa

platform: xsa
	@echo "\n\n===> Platform generated (as provided by Xilinx)" 
	
$(DRM_XO):
	@echo -e "\n\n===> Generating [$@] Kernel ..."
	@make -C src/drm_hdk/controller/vitis
	@mkdir -p $(XCLBIN_ARTIFACTS)
	@cp -f src/drm_hdk/controller/vitis/kernel_drm_controller.xo $(DRM_XO)

$(VTS_KERNELS_OBJS):
	@echo -e "\n\n===> Generating [$@] Kernel ..."
	@mkdir -p $(XCLBIN_ARTIFACTS)
	@$(eval KRNL=$(basename $(notdir $@)))
	@vivado -mode batch -source scripts/gen_$(KRNL)_xo.tcl -tclargs $@ krnl_$(KRNL)_stage_rtl hw $(VTS_PLATFORM)

$(DESIGN_OBJ): platform $(DRM_XO) $(VTS_KERNELS_OBJS)
	@echo -e "\n\n===> Generating $(DESIGN_OBJ) ..."
	@mkdir -p $(XCLBIN_ARTIFACTS)
	@echo PLATFORM_REPO_PATHS=$(VTS_PFM_PATH)
	@export PLATFORM_REPO_PATHS=$(VTS_PFM_PATH); v++ -l $(XOCC_OPTS) -s -o $(DESIGN_OBJ) $(DRM_XO) $(VTS_KERNELS_OBJS)

bitstream: $(DESIGN_OBJ) $(XCLBIN_ARTIFACTS)/drmselftest-fpga.xsa
	@echo "\n\n===> Bitstream generated" 

device-tree-xlnx:
	@echo "\n\n===> Cloning device tree generator (from Xilinx github)" 
	@git clone https://github.com/Xilinx/device-tree-xlnx.git -b xlnx_rel_v2021.1_update1 

dtsi: device-tree-xlnx bitstream
	@echo "\n\n===> Generating device tree based on XSA and device tree generator" 
	@xsct gen_dt.tcl $(XCLBIN_ARTIFACTS)/drmselftest-fpga.xsa $(VTS_DTSI_PATH)

package: check dtsi
	@rm -rf $(PTLX_INPUT)
	@mkdir $(PTLX_INPUT)
	@cp _x/link/int/system.bit $(PTLX_INPUT)/
	@cp $(DESIGN_OBJ) $(PTLX_INPUT)/
	@echo "\n\n===> Petalinux package available in $(PTLX_INPUT)" 

clean:
	@rm -rf tmp* vivado* packaged_kernel *.log _x .Xil .ipcache *.out *.xclbin *.xclbin.* vivado* sample_link.ini
	@make -C src/drm_hdk/controller/vitis clean

cleanall: clean
	@make -C platforms_base clean
	@make -C src/drm_hdk/controller/vitis cleanall
	@rm -rf device-tree-xlnx $(XCLBIN_ARTIFACTS) $(PTLX_INPUT) $(VTS_DTSI_PATH)

.DEFAULT_GOAL := all
