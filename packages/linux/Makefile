#####################################
#
# Copyright 2017-2019 NXP
#
# SPDX-License-Identifier:      BSD-3-Clause
#
######################################

SHELL=/bin/bash
include $(FBDIR)/configs/$(CONFIGLIST)
include $(FBDIR)/include/repo.mk

UEFI_DTB_LIST = freescale/fsl-ls1043a-rdb-sdk.dtb freescale/fsl-ls1046a-rdb-sdk.dtb freescale/fsl-ls2088a-rdb.dtb freescale/fsl-lx2160a-rdb.dtb
PPC32_DTB_LIST = fsl/mpc8548cds_32b.dtb fsl/p1010rdb-pb.dtb fsl/p2020rdb-pc_32b.dtb fsl/p2041rdb.dtb fsl/p3041ds.dtb fsl/p4080ds.dtb fsl/p5040ds.dtb
PPC64_DTB_LIST = fsl/t1023rdb.dtb fsl/t1024rdb.dtb fsl/t1042d4rdb.dtb fsl/t2080rdb.dtb fsl/t4240rdb.dtb


.PHONY: linux
linux: build_kernel cryptodev_linux gpu_module

build_kernel:
ifeq ($(CONFIG_KERL_LINUX), y)
	@$(call fetch-git-tree,linux)
	@curbrch=`cd $(KERNEL_PATH) && git branch | grep ^* | cut -d' ' -f2` && \
	$(call fbprint_n,"Building $(KERNEL_TREE) with $$curbrch") && \
	$(call fbprint_n,"KERNEL_CFG = $(KERNEL_CFG)") && \
	$(call fbprint_n,"Compiler = `$(CROSS_COMPILE)gcc --version | head -1`") && \
	if [ $(DESTARCH) = arm64 -a $(SOCFAMILY) = IMX ]; then \
	    locarch=arm64; dtbstr=freescale/fsl-imx8*k.dtb; dtbdir=dts; \
	elif [ $(DESTARCH) = arm64 -a $(SOCFAMILY) = LS ]; then \
	    locarch=arm64; dtbstr=freescale/*.dtb; dtbdir=dts; extflags="DTC_FLAGS='-@'"; \
	elif [ $(DESTARCH) = arm32 -a $(SOCFAMILY) = LS ]; then \
	    locarch=arm; dtbstr=ls*.dtb; dtbdir=dts; \
	elif [ $(DESTARCH) = arm32 -a $(SOCFAMILY) = IMX ]; then \
	    locarch=arm; dtbstr=imx*.dtb; dtbdir=dts; \
	elif [ $(DESTARCH) = ppc32 -o $(DESTARCH) = ppc64 ]; then \
	    locarch=powerpc; dtbstr=fsl/*.dtb; dtbdir=; \
	fi && \
	opdir=$(KERNEL_OUTPUT_PATH)/$$curbrch && \
	if [ ! -d $$opdir ]; then mkdir -p $$opdir; fi && \
	if [ ! -f $$opdir/.config ]; then $(MAKE) $(KERNEL_CFG) -C $(KERNEL_PATH) O=$$opdir 1>/dev/null; fi && \
	if [ "$(BUILDARG)" = "custom" ]; then \
	    $(MAKE) menuconfig -C $(KERNEL_PATH) O=$$opdir && \
	    $(call fbprint_d,"Custom kernel config: $$opdir/.config") && \
	    $(call fbprint_n,"Run flex-builder -c linux -a $(DESTARCH) to build kernel with the customized .config") && exit; \
	fi; \
	if [ "`echo $(BUILDARG) | cut -d: -f1`" = "fragment" ]; then \
	    mergeconfig=`echo $(BUILDARG) | cut -d: -f2`; \
	    echo -e "\n$(KERNEL_TREE): Total Config List = $(KERNEL_CFG) $$mergeconfig\n" && \
	    $(MAKE) $$mergeconfig -C $(KERNEL_PATH) O=$$opdir; \
	fi && \
	if [ "$(ENDIANTYPE)" = "be" ]; then \
	    sed -i 's/# CONFIG_CPU_BIG_ENDIAN is not set/CONFIG_CPU_BIG_ENDIAN=y/' $$opdir/.config; \
	    echo Big-Endian enabled!; \
	fi && \
	$(MAKE) -j$(JOBS) all -C $(KERNEL_PATH) O=$$opdir && \
        if [ $(DESTARCH) = arm64 -a $(SOCFAMILY) = LS ]; then \
            $(MAKE) $$extflags $(UEFI_DTB_LIST) -C $(KERNEL_PATH) O=$$opdir; \
        fi && \
	if [ $(DESTARCH) = arm32 ]; then \
	    $(MAKE) -j$(JOBS) uImage LOADADDR=80008000 -C $(KERNEL_PATH) O=$$opdir; \
	fi && \
        if [ $(DESTARCH) = ppc32 ]; then \
            $(MAKE) -j$(JOBS) uImage $(PPC32_DTB_LIST) -C $(KERNEL_PATH) O=$$opdir; \
	elif [ $(DESTARCH) = ppc64 ]; then \
	    $(MAKE) -j$(JOBS) uImage $(PPC64_DTB_LIST) -C $(KERNEL_PATH) O=$$opdir; \
	fi && \
	$(MAKE) modules -C $(KERNEL_PATH) O=$$opdir && \
	$(MAKE) INSTALL_MOD_PATH=$(FBDIR)/build/linux/$(KERNEL_TREE)/$(DESTARCH)/$(SOCFAMILY) modules_install -C $(KERNEL_PATH) O=$$opdir && \
	mkdir -p $$opdir/module-headers/include/config && cp -f $$opdir/.config $$opdir/module-headers && \
	cp -f $$opdir/include/config/auto.conf* $$opdir/module-headers/include/config && cp -rf $$opdir/include $$opdir/module-headers && \
	$(MAKE) modules_prepare -C $(KERNEL_PATH) O=$$opdir/module-headers && \
	if [ $(DESTARCH) = arm32 -o $(DESTARCH) = arm64 ]; then \
	    $(MAKE) zinstall \
	    INSTALL_PATH=$(FBDIR)/build/linux/$(KERNEL_TREE)/$(DESTARCH)/$(SOCFAMILY) -C $(KERNEL_PATH) O=$$opdir; \
	fi && \
	if [ $(DESTARCH) = ppc32 -o $(DESTARCH) = ppc64 ]; then \
	    cp $$opdir/arch/$$locarch/boot/uImage $(FBDIR)/build/linux/$(KERNEL_TREE)/$(DESTARCH)/$(SOCFAMILY); \
	    tail -c +65 $$opdir/arch/$$locarch/boot/uImage > $(FBDIR)/build/linux/$(KERNEL_TREE)/$(DESTARCH)/$(SOCFAMILY)/Image.gz; \
	fi && \
	$(MAKE) headers_install -C $(KERNEL_PATH) O=$$opdir && \
	if [ $(DESTARCH) = arm64 ]; then \
	    cp $$opdir/arch/$$locarch/boot/Image* \
	    $(FBDIR)/build/linux/$(KERNEL_TREE)/$(DESTARCH)/$(SOCFAMILY); \
	fi && \
	if [ $(DESTARCH) = arm32 ]; then \
	    cp -f $$opdir/arch/$$locarch/boot/uImage \
	    $(FBDIR)/build/linux/$(KERNEL_TREE)/$(DESTARCH)/$(SOCFAMILY)/uImage; \
	    cp -f $$opdir/arch/$$locarch/boot/zImage $(FBDIR)/build/linux/$(KERNEL_TREE)/$(DESTARCH)/$(SOCFAMILY)/zImage; \
	fi && \
	ls $$opdir/arch/$$locarch/boot/$$dtbdir/$$dtbstr | grep -iE 'rdb|frdm|frwy|twr|qds|ds|imx' | xargs -I {} cp {} \
	$(FBDIR)/build/linux/$(KERNEL_TREE)/$(DESTARCH)/$(SOCFAMILY) && \
	ls -l $(FBDIR)/build/linux/$(KERNEL_TREE)/$(DESTARCH)/$(SOCFAMILY) && \
	$(call fbprint_d,"$(KERNEL_TREE) $$curbrch in $(FBDIR)/build/linux/$(KERNEL_TREE)/$(DESTARCH)/$(SOCFAMILY)")
endif


.PHONY: cryptodev_linux
cryptodev_linux:
ifeq ($(CONFIG_KERL_CRYPTODEV_LINUX), y)
	@[ "$(BUILDARG)" = "custom" ] && exit || \
	 $(call fetch-git-tree,cryptodev_linux) && $(call fetch-git-tree,linux) && \
	 if [ ! -d $(FBDIR)/build/linux/kernel/$(DESTARCH)/$(SOCFAMILY) ]; then \
	     flex-builder -c linux -a $(DESTARCH) -p $(SOCFAMILY) -f $(CONFIGLIST); \
	 fi && \
	 curbrch=`cd $(KERNEL_PATH) && git branch | grep ^* | cut -d' ' -f2` && \
	 opdir=$(KERNEL_OUTPUT_PATH)/$$curbrch && \
	 cd $(FBDIR)/packages/linux/cryptodev_linux && $(call fbprint_b,"CRYPTODEV_LINUX") && export KERNEL_DIR=$$opdir && \
	 export KERNEL_MAKE_OPTS="-lcrypto -L$(RFSDIR)/usr/lib/aarch64-linux-gnu" && $(MAKE) && $(MAKE) install && \
	 ls -l $(FBDIR)/build/linux/$(KERNEL_TREE)/$(DESTARCH)/$(SOCFAMILY)/lib/modules/*/extra/cryptodev.ko && \
	 $(call fbprint_d,"CRYPTODEV_LINUX")
endif


perf:
ifeq ($(CONFIG_KERL_PERF), y)
	@$(call fetch-git-tree,$(KERNEL_TREE))
	@curbrch=`cd $(KERNEL_PATH) && git branch | grep ^* | cut -d' ' -f2` && \
	 opdir=$(KERNEL_OUTPUT_PATH)/$$curbrch && \
	 $(call fbprint_b,"kernel tools/perf") && \
	 if [ ! -d $$opdir ]; then mkdir -p $$opdir; fi && \
	 if [ ! -f $$opdir/.config ]; then $(MAKE) $(KERNEL_CFG) -C $(KERNEL_PATH) O=$$opdir 1>/dev/null; fi && \
	 $(MAKE) -j$(JOBS) tools/perf -C $(KERNEL_PATH) O=$$opdir && \
	 cp $$opdir/tools/perf/perf $(FBDIR)/build/linux/$(KERNEL_TREE)/$(DESTARCH)/$(SOCFAMILY) && \
	 ls -l $(FBDIR)/build/linux/$(KERNEL_TREE)/$(DESTARCH)/$(SOCFAMILY)/perf && \
	 $(call fbprint_d,"kernel tools/perf")
endif


.PHONY: gpu_module
gpu_module:
ifeq ($(CONFIG_KERL_GPU_MODULE), y)
	@[ "$(BUILDARG)" = "custom" ] && exit || $(call fetch-git-tree,gpu_module)
	@[ "$(BUILDARG)" = "custom" ] && exit || \
	 if [ ! -d $(FBDIR)/packages/linux/gpu_module/hal/kernel ]; then \
             curl -R -k -f $(gpu_module_bin_url) -o gpu_module.bin && chmod +x gpu_module.bin && \
             ./gpu_module.bin --auto-accept && mv gpu-module-* gpu_module && rm -f gpu_module.bin; \
         fi && \
	 $(call fetch-git-tree,$(KERNEL_TREE)) && \
	 curbrch=`cd $(KERNEL_PATH) && git branch | grep ^* | cut -d' ' -f2` && \
	 opdir=$(KERNEL_OUTPUT_PATH)/$$curbrch && mkdir -p $$opdir && \
	 cd $(FBDIR)/packages/linux/gpu_module && $(call fbprint_b,"gpu_module") && \
	 $(MAKE) KERNEL_DIR=$(KERNEL_PATH) O=$$opdir && \
	 $(MAKE) KERNEL_DIR=$(KERNEL_PATH) O=$$opdir install && \
	 $(call fbprint_d,"gpu_module")
endif


.PHONY: lttng_modules
lttng_modules:
ifeq ($(CONFIG_KERL_LTTNG_MODULES), y)
	@$(call fetch-git-tree,lttng-modules)
	@$(call fetch-git-tree,$(KERNEL_TREE))
	@curbrch=`cd $(KERNEL_PATH) && git branch | grep ^* | cut -d' ' -f2` && \
	 opdir=$(KERNEL_OUTPUT_PATH)/$$curbrch && \
	 mkdir -p $$opdir && \
	 if ! grep CONFIG_STACKTRACE=y $$opdir/.config 1>/dev/null 2>&1; then cd $(FBDIR) && \
	 flex-builder -c linux -B fragment:lttng.config -a $(DESTARCH) -p $(SOCFAMILY) -f $(CONFIGLIST) && cd -; fi && \
	 cd lttng-modules && $(call fbprint_b,"LTTng modules") && \
	 $(MAKE) KERNELDIR=$(KERNEL_PATH) O=$$opdir && \
	 $(MAKE) KERNELDIR=$(KERNEL_PATH) O=$$opdir modules_install && \
	 $(call fbprint_d,"LTTng modules")
else
	@$(call fbprint_w,INFO: CONFIG_KERL_LTTNG_MODULES is not enabled by default in configs/$(CONFIGLIST))
endif


repo_fetch:
	@echo -e "\nfetch linux repositories ..."
	@$(call repo-update,fetch,$(LINUX_REPO_LIST))

repo_update_branch:
	@echo -e "\nlinux repositories update for branch ..."
	@$(call repo-update,branch,$(LINUX_REPO_LIST))

repo_update_tag:
	@echo -e "\nlinux repositories update for tag ..."
	@$(call repo-update,tag,$(LINUX_REPO_LIST))

repo_update_latest:
	@echo -e "\nlinux repositories update to latest HEAD commit ..."
	@$(call repo-update,update,$(LINUX_REPO_LIST))

repo_update_commit:
	@echo -e "\nlinux repositories update to specified commit ID ..."
	@$(call repo-update,commit,$(LINUX_REPO_LIST))
