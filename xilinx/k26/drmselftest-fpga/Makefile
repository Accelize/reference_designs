#
# Accelize DRM Reference Design Makefile
#

ROOT_DIR:=$(shell dirname $(realpath $(firstword $(MAKEFILE_LIST))))

VTS_PLATFORM=kv260_vcuDecode_vmixDP

OUTPUT_DIR=xclbin
DRM_XO=$(OUTPUT_DIR)/drm.xo
DESIGN_OBJ=$(OUTPUT_DIR)/accelize-drmselftest-firmware.xclbin
VTS_KERNELS = drmselftest input output
VTS_KERNELS_OBJS = $(VTS_KERNELS:%=$(OUTPUT_DIR)/%.xo)
VTS_CFG_FILE=drmselftest.ini
VTS_LINK_SCRIPT_PATH=$(ROOT_DIR)/src/drm_hdk/post_syslink.tcl

XOCC_OPTS = -t hw --platform $(VTS_PLATFORM) --config $(VTS_CFG_FILE) --xp param:compiler.userPostSysLinkOverlayTcl=$(VTS_LINK_SCRIPT_PATH)

check:
ifndef XILINX_VITIS
	$(error You have to define path to Vitis in XILINX_VITIS variable)
endif
ifndef PLATFORM_REPO_PATHS
	$(info Try: export PLATFORM_REPO_PATHS=/home/ubuntu/Documents/kria-vitis-platforms/kv260/platforms/xilinx_kv260_vcuDecode_vmixDP_202210_1)
	$(info Or:  export PLATFORM_REPO_PATHS=/home/ubuntu/Documents/kria-vitis-platforms/kr260/platforms/xilinx_kr260_tsn_rs485pmod_202210_1)
	$(error You have to define path to platforms in PLATFORM_REPO_PATHS variable)
endif


$(DRM_XO): check
	@echo -e "\n\n===> Generating [$@] Kernel ..."
	@make -C src/drm_hdk/controller/vitis
	@mkdir -p $(OUTPUT_DIR)
	@cp -f src/drm_hdk/controller/vitis/kernel_drm_controller.xo $(DRM_XO)

$(VTS_KERNELS_OBJS): check
	@echo -e "\n\n===> Generating [$@] Kernel ..."
	@mkdir -p $(OUTPUT_DIR)
	@$(eval KRNL=$(basename $(notdir $@)))
	@vivado -mode batch -source scripts/gen_$(KRNL)_xo.tcl -tclargs $@ krnl_$(KRNL)_stage_rtl hw $(VTS_PLATFORM)

$(DESIGN_OBJ): check $(DRM_XO) $(VTS_KERNELS_OBJS)
	@echo -e "\n\n===> Generating $(DESIGN_OBJ) ..."
	@mkdir -p $(OUTPUT_DIR)
	@v++ -l $(XOCC_OPTS) -s -o $(DESIGN_OBJ) $(DRM_XO) $(VTS_KERNELS_OBJS)

clean:
	@rm -rf tmp* vivado* packaged_kernel *.log _x .Xil .ipcache *.out *.xclbin *.xclbin.*
	@make -C src/drm_hdk/controller/vitis clean

cleanall: clean
	@rm -rf $(OUTPUT_DIR) sample_link.ini
	@make -C src/drm_hdk/controller/vitis cleanall

all: $(DESIGN_OBJ)

.PHONY: all clean cleanall

.DEFAULT_GOAL := all
