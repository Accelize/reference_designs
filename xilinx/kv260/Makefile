#
# Accelize DRM Reference Design Makefile
#

ROOT_DIR:=$(shell dirname $(realpath $(firstword $(MAKEFILE_LIST))))

VTS_PLATFORM=kv260_vcuDecode_vmixDP

OUTPUT_DIR=xclbin
DRM_XO=${OUTPUT_DIR}/drm.xo
DESIGN_OBJ=${OUTPUT_DIR}/fpgatest.xclbin
VTS_KERNELS = adder input output
VTS_KERNELS_OBJS = $(VTS_KERNELS:%=${OUTPUT_DIR}/%.xo)
VTS_CFG_FILE=connectivity.cfg
VTS_LINK_SCRIPT_PATH=$(ROOT_DIR)/src/drm_hdk/post_syslink.tcl

XOCC_OPTS = -t hw --platform ${VTS_PLATFORM} --config ${VTS_CFG_FILE} --xp param:compiler.userPostSysLinkOverlayTcl=${VTS_LINK_SCRIPT_PATH}

check:
ifndef XILINX_VITIS
	$(error You have to define path to Vitis in XILINX_VITIS variable)
endif
ifndef PLATFORM_REPO_PATHS
	$(error "You have to define path to platforms in PLATFORM_REPO_PATHS variable.\
	    Try: export PLATFORM_REPO_PATHS=/home/ubuntu/Documents/kv260-vitis/platforms/xilinx_kv260_vcuDecode_vmixDP_202110_1")
endif


$(DRM_XO): check
	@echo -e "\n\n===> Generating [$@] Kernel ..."
	@make -C src/drm_hdk/controller/vitis
	@mkdir -p ${OUTPUT_DIR}
	@cp -f src/drm_hdk/controller/vitis/kernel_drm_controller.xo ${DRM_XO}

$(VTS_KERNELS_OBJS): check
	@echo -e "\n\n===> Generating [$@] Kernel ..."
	@mkdir -p ${OUTPUT_DIR}
	@$(eval KRNL=$(basename $(notdir $@)))
	@vivado -mode batch -source scripts/gen_${KRNL}_xo.tcl -tclargs $@ krnl_${KRNL}_stage_rtl hw ${VTS_PLATFORM}

${DESIGN_OBJ}: check $(DRM_XO) $(VTS_KERNELS_OBJS)
	@echo -e "\n\n===> Generating ${DESIGN_OBJ} ..."
	@mkdir -p ${OUTPUT_DIR}
	@v++ -l ${XOCC_OPTS} -s -o ${DESIGN_OBJ} $(DRM_XO) $(VTS_KERNELS_OBJS)

clean:
	@rm -rf tmp* vivado* packaged_kernel *.log _x .Xil .ipcache *.out *.xclbin *.xclbin.*
	@make -C src/drm_hdk/controller/vitis clean

clean_all: clean
	@rm -rf ${OUTPUT_DIR}
	@make -C src/drm_hdk/controller/vitis cleanall

all: ${DESIGN_OBJ}

.PHONY: all clean clean_all

.DEFAULT_GOAL := all
