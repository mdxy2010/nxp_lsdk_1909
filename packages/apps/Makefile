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


.PHONY: all

all: $(APPS_REPO_LIST) misc
	@$(call fbprint_d,"apps components")


.PHONY: restool
restool:
ifeq ($(CONFIG_APP_RESTOOL), y)
ifeq ($(DESTARCH),arm64)
	@$(call fbprint_b,"restool") && $(call fetch-git-tree,restool) && \
	 $(MAKE) -C restool && $(MAKE) -C restool install && \
	 $(call fbprint_d,"restool")
endif
endif


.PHONY: dpdk
dpdk:
ifeq ($(CONFIG_APP_DPDK), y)
ifeq ($(DESTARCH),arm64)
	@[ $(DISTROTYPE) != ubuntu -a $(DISTROTYPE) != yocto -o  $(DISTROSCALE) = mate -o $(DISTROSCALE) = lite -o $(DISTROSCALE) = tiny ] &&  exit || \
	 $(call fbprint_b,"dpdk") && $(call fetch-git-tree,dpdk) && \
	 if [ ! -d $(RFSDIR)/usr/lib ]; then $(call build_dependent_rfs); fi && \
	 if [ ! -f $(DESTDIR)/usr/local/lib/libcrypto.so ]; then \
	     flex-builder -c openssl -r $(DISTROTYPE):$(DISTROSCALE) -a $(DESTARCH) -f $(CONFIGLIST); \
	 fi && \
	 curbrch=`cd $(KERNEL_PATH) && git branch | grep ^* | cut -d' ' -f2` && kerneloutdir=$(KERNEL_OUTPUT_PATH)/$$curbrch && \
	 if [ ! -f $$kerneloutdir/include/generated/utsrelease.h ]; then $(call build_dependent_linux); fi && \
	 libmodules=`ls -t $(FBDIR)/build/linux/kernel/arm64/LS/lib/modules` && modversion=`echo $$libmodules | cut -d' ' -f1` && \
	 cd $(FBDIR)/packages/apps/dpdk && export CROSS=$(CROSS_COMPILE) && export RTE_KERNELDIR=$$kerneloutdir && \
	 export LDFLAGS="-L$(DESTDIR)/usr/local/lib -L$(RFSDIR)/lib/aarch64-linux-gnu -L$(RFSDIR)/usr/lib" && \
	 export RTE_SDK=$(PWD) && export RTE_TARGET=arm64-dpaa-linuxapp-gcc && \
	 export MODULES_VERSION=$$modversion && export OPENSSL_PATH=$(RFSDIR)/usr && \
	 $(MAKE) install T=arm64-dpaa-linuxapp-gcc DESTDIR=$(DESTDIR)/usr/local CONFIG_RTE_EAL_IGB_UIO=n CONFIG_RTE_KNI_KMOD=y \
		 CONFIG_RTE_LIBRTE_PMD_OPENSSL=y EXTRA_CFLAGS="-I$(DESTDIR)/usr/local/include -I$(RFSDIR)/usr/include/aarch64-linux-gnu" \
		 EXTRA_LDFLAGS="-L$(DESTDIR)/usr/local/lib -L$(RFSDIR)/lib/aarch64-linux-gnu" && \
	 if [ $(CONFIG_APP_VPP) = y ]; then \
	     $(MAKE) install T=arm64-dpaa-linuxapp-gcc DESTDIR=$(DESTDIR)/usr/local/dpdk4vpp CONFIG_RTE_EAL_IGB_UIO=n CONFIG_RTE_KNI_KMOD=y \
	     CONFIG_RTE_LIBRTE_PMD_OPENSSL=y EXTRA_CFLAGS="-I$(DESTDIR)/usr/local/include -I$(RFSDIR)/usr/include/aarch64-linux-gnu -Ofast -fPIC -ftls-model=local-dynamic" \
	     EXTRA_LDFLAGS="-L$(DESTDIR)/usr/local/lib -L$(DESTDIR)/usr/local/lib -L$(RFSDIR)/lib/aarch64-linux-gnu"; \
	 fi && \
	 if [ $(DISTROTYPE) != ubuntu -a $(DISTROTYPE) != yocto ]; then echo pktgen_dpdk is not supported on $(DISTROTYPE) yet; exit; fi && \
	 echo -e "\nBuilding DPDK Examples ..." && cd $(FBDIR)/packages/apps/dpdk/examples && \
	 export CROSS=$(CROSS_COMPILE) && export RTE_SDK=$(FBDIR)/packages/apps/dpdk && export RTE_TARGET=arm64-dpaa-linuxapp-gcc && \
	 export OPENSSL_PATH=$(RFSDIR)/usr && export RTE_SDK_BIN=$(DESTDIR)/usr/local && \
	 $(MAKE) -j$(JOBS) -C l2fwd && $(MAKE) -j$(JOBS) -C l3fwd && $(MAKE) -j$(JOBS) -C cmdif && $(MAKE) -j$(JOBS) -C l2fwd-qdma && \
	 $(MAKE) -j$(JOBS) -C l2fwd-crypto CONFIG_RTE_LIBRTE_PMD_OPENSSL=y EXTRA_CFLAGS="-I$(RFSDIR)/usr/include/aarch64-linux-gnu" \
		 EXTRA_LDFLAGS="-L$(DESTDIR)/usr/local/lib -L$(RFSDIR)/lib/aarch64-linux-gnu" && $(MAKE) -j$(JOBS) -C vhost && \
	 $(MAKE) -j$(JOBS) -C ipsec-secgw CONFIG_RTE_LIBRTE_PMD_OPENSSL=y EXTRA_CFLAGS="-I$(DESTDIR)/usr/local/include" \
		 EXTRA_LDFLAGS="-L$(DESTDIR)/usr/local/lib -L$(RFSDIR)/lib/aarch64-linux-gnu"  && \
	 $(MAKE) -j$(JOBS) -C ip_fragmentation && $(MAKE) -j$(JOBS) -C ip_reassembly  && \
	 $(MAKE) -j$(JOBS) -C kni && find . -perm -111 -a -type f | xargs -I {} cp {} $(DESTDIR)/usr/local/bin && \
	 mkdir -p $(DESTDIR)/usr/local/dpdk/cmdif/include && mkdir -p $(DESTDIR)/usr/local/dpdk/cmdif/lib && \
	 cp cmdif/lib/client/fsl_cmdif_client.h cmdif/lib/server/fsl_cmdif_server.h cmdif/lib/shbp/fsl_shbp.h $(DESTDIR)/usr/local/dpdk/cmdif/include/ && \
	 cp cmdif/lib/arm64-dpaa-linuxapp-gcc/librte_cmdif.a ${DESTDIR}/usr/local/dpdk/cmdif/lib/ && \
	 mkdir -p $(DESTDIR)/usr/local/dpdk/examples/ipsec_secgw && cp -f ipsec-secgw/*.cfg ${DESTDIR}/usr/local/dpdk/examples/ipsec_secgw && \
	 echo -e "\nInstalling dpdk-extras ...$(DESTDIR) " && cp -rf $(FBDIR)/packages/apps/dpdk/nxp/* $(DESTDIR)/usr/local/dpdk && \
	 rm -rf $(DESTDIR)/usr/local/share/dpdk/examples && cd $(DESTDIR)/usr/local/bin && rm -f dpdk-pdump && rm -f dpdk-pmdinfo && \
	 rm -f dpdk-procinfo && rm -f dpdk-test-crypto-perf && \
	 $(call fbprint_d,"dpdk")
endif
endif


.PHONY: vpp
vpp:
ifeq ($(CONFIG_APP_VPP), y)
ifeq ($(DESTARCH),arm64)
	@[ $(DISTROTYPE) != ubuntu -o $(DISTROSCALE) = mate -o $(DISTROSCALE) = lite ] && exit || \
	 $(call fbprint_b,"vpp") && $(call fetch-git-tree,vpp) && \
	 if [ ! -d $(RFSDIR)/lib/aarch64-linux-gnu ]; then $(call build_dependent_rfs); fi && \
	 test -d $(DESTDIR)/usr/local/dpdk4vpp || flex-builder -c dpdk -f $(CONFIGLIST); \
	 export CROSS_PREFIX=aarch64-linux-gnu && export CROSS_TOOLCHAIN=/usr && \
	 export CROSS_SYSROOT=$(RFSDIR) && export ARCH=arm64 && export OPENSSL_PATH=$(RFSDIR)/usr && \
	 export EXTRA_INC=$(RFSDIR)/usr/include/aarch64-linux-gnu && export EXTRA_LIBS=$(RFSDIR)/lib/aarch64-linux-gnu && \
	 export DPDK_PATH=$(DESTDIR)/usr/local/dpdk4vpp && \
	 export LD_LIBRARY_PATH=$(DESTDIR)/usr/local/dpdk4vpp/lib:$(RFSDIR)/lib/aarch64-linux-gnu && \
	 sudo cp -f $(DESTDIR)/usr/local/dpdk4vpp/lib/librte* $(RFSDIR)/usr/local/lib/ && \
	 cd $(FBDIR)/packages/apps/vpp && $(MAKE) install-dep && \
	 cd $(FBDIR)/packages/apps/vpp/build-root && $(MAKE) distclean && \
	 $(MAKE) V=0 PLATFORM=dpaa TAG=dpaa install-deb && \
	 mkdir -p $(DESTDIR)/usr/local/vpp && cp -vf *.deb $(DESTDIR)/usr/local/vpp && \
	 sudo cp -f $(DESTDIR)/usr/local/lib/librte* $(RFSDIR)/usr/local/lib/ && \
	 $(call fbprint_d,"vpp")
endif
else
	@$(call fbprint_w,INFO: CONFIG_APP_VPP is not enabled by default in configs/$(CONFIGLIST))
endif


.PHONY: pktgen_dpdk
pktgen_dpdk:
ifeq ($(CONFIG_APP_PKTGEN_DPDK), y)
ifeq ($(DESTARCH),arm64)
	@[ $(DISTROTYPE) != ubuntu -o $(DISTROSCALE) = mate -o $(DISTROSCALE) = lite ] && exit || \
	 $(call fbprint_b,"pktgen_dpdk") && $(call fetch-git-tree,pktgen_dpdk) && \
	 cd $(FBDIR)/packages/apps/pktgen_dpdk && export CROSS=$(CROSS_COMPILE) && \
	 export RTE_SDK=$(FBDIR)/packages/apps/dpdk && export RTE_TARGET=arm64-dpaa-linuxapp-gcc && \
	 $(MAKE) EXTRA_CFLAGS="-L$(RFSDIR)/usr/lib -L$(RFSDIR)/lib/aarch64-linux-gnu -Wl,-rpath=$(RFSDIR)/usr/lib \
	 -I$(RFSDIR)/usr/include/lua5.3 -I$(RFSDIR)/usr/include/aarch64-linux-gnu" && \
	 cp -f Pktgen.lua ${DESTDIR}/usr/bin && cp -f app/arm64-dpaa-linuxapp-gcc/pktgen ${DESTDIR}/usr/bin && \
	 $(call fbprint_d,"pktgen_dpdk")
endif
endif


.PHONY: ovs_dpdk
ovs_dpdk:
ifeq ($(CONFIG_APP_OVS_DPDK), y)
ifeq ($(DESTARCH),arm64)
	@[ $(DISTROTYPE) != ubuntu -a $(DISTROTYPE) != yocto -o $(DISTROSCALE) = mate -o $(DISTROSCALE) = lite -o $(DISTROSCALE) = tiny ] && exit || \
	 $(call fbprint_b,"ovs_dpdk") && $(call fetch-git-tree,ovs_dpdk) && \
	 if [ ! -d $(RFSDIR)/usr/lib ]; then $(call build_dependent_rfs); fi && \
	 if [ ! -d $(DESTDIR)/usr/local/dpdk ]; then \
	     echo building dependent DPDK ... && \
	     flex-builder -c dpdk -r $(DISTROTYPE):$(DISTROSCALE) -f $(CONFIGLIST); \
	 fi && \
	 cd $(FBDIR)/packages/apps/ovs_dpdk && export CROSS=$(CROSS_COMPILE) && export RTE_SDK=$(FBDIR)/packages/apps/dpdk && \
	 export RTE_TARGET=arm64-dpaa-linuxapp-gcc && ./boot.sh && export LDFLAGS="-L$(RFSDIR)/lib/aarch64-linux-gnu -L$(RFSDIR)/lib -L$(RFSDIR)/usr/lib" && \
	 export LIBS="-ldl -lssl" && ./configure --prefix=/usr/local --host=aarch64-linux-gnu \
	 --with-dpdk=$(DESTDIR)/usr/local --with-openssl=$(RFSDIR)/usr CFLAGS="-g -Wno-cast-align -Ofast \
	 -I$(DESTDIR)/usr/local/include/dpdk -I$(RFSDIR)/usr/include -I$(RFSDIR)/usr/include/aarch64-linux-gnu -lpthread -lssl" && \
	 $(MAKE) -j$(JOBS) install && $(call fbprint_d,"ovs_dpdk")
endif
endif


.PHONY: flib
flib:
ifeq ($(CONFIG_APP_FLIB), y)
ifeq ($(DESTARCH),arm64)
	@$(call fbprint_b,"flib") && $(call fetch-git-tree,flib) && \
	 $(MAKE) -C flib install && $(call fbprint_d,"flib")
endif
endif


.PHONY: fmlib
fmlib:
ifeq ($(CONFIG_APP_FMLIB), y)
ifeq ($(DESTARCH),arm64)
	@$(call fbprint_b,"fmlib") && $(call fetch-git-tree,fmlib) && \
	 if [ ! -d $(KERNEL_PATH)/include/uapi/linux/fmd ]; then $(call build_dependent_linux); fi && \
	 cd $(FBDIR)/packages/apps/fmlib && export KERNEL_SRC=$(KERNEL_PATH) && \
	 $(MAKE) clean && $(MAKE) && $(MAKE) install-libfm-arm && \
	 $(call fbprint_d,"fmlib")
endif
endif


.PHONY: fmc
fmc:
ifeq ($(CONFIG_APP_FMC), y)
ifeq ($(DESTARCH),arm64)
	@[ $(DISTROSCALE) = mate -o $(DISTROTYPE) = centos -o $(DISTROSCALE) = tiny ] && exit || \
	 $(call fbprint_b,"fmc") && $(call fetch-git-tree,fmc) && \
	 if [ $(DISTROTYPE) = ubuntu -o $(DISTROTYPE) = yocto -o $(DISTROTYPE) = debian ]; then xmlhdr=$(RFSDIR)/usr/include/libxml2; \
	 elif [ $(DISTROTYPE) = buildroot ]; then xmlhdr=$(RFSDIR)/../host/include/libxml2; fi && \
	 if [ $(DESTARCH) = arm64 ]; then host=aarch64-linux-gnu; elif [ $(DESTARCH) = arm32 ]; then host=arm-linux-gnueabihf; fi; \
	 if [ ! -d $(FBDIR)/packages/apps/fmlib/include/fmd/Peripherals ] || [ ! -f $(DESTDIR)/lib/libfm-arm.a ]; then \
	     echo building dependent fmlib ...; \
	     flex-builder -c fmlib -a $(DESTARCH) -f $(CONFIGLIST); \
	 fi && \
	 if [ ! -f $$xmlhdr/libxml/parser.h ]; then $(call build_dependent_rfs); fi && \
	 if [ ! -d $(KERNEL_PATH)/include/uapi/linux/fmd ]; then $(call build_dependent_linux); fi && \
	 export LDFLAGS="-L$(DESTDIR)/lib -L$(RFSDIR)/lib -L$(RFSDIR)/lib/$$host -L$(RFSDIR)/usr/lib \
	 -Wl,-rpath=$(RFSDIR)/lib:$(RFSDIR)/lib/$$host:$(RFSDIR)/usr/lib:$(RFSDIR)/usr/lib/$$host" && \
	 export CFLAGS="-I$(RFSDIR)/usr/include/$$host -I$(FBDIR)/packages/apps/fmlib/include/fmd \
		-I$(FBDIR)/packages/apps/fmlib/include/fmd/Peripherals \
		-I$(FBDIR)/packages/apps/fmlib/include/fmd/integrations" && \
	 $(MAKE) clean -C fmc/source && \
	 $(MAKE) FMD_USPACE_HEADER_PATH=$(KERNEL_PATH)/include/uapi/linux/fmd \
		 FMLIB_HEADER_PATH=$(FBDIR)/packages/apps/fmlib/include \
		 LIBXML2_HEADER_PATH=$$xmlhdr \
		 FMD_USPACE_LIB_PATH=$(DESTDIR)/lib TCLAP_HEADER_PATH=$(RFSDIR)/usr/include \
		 CXX=$(CROSS_COMPILE)g++ CC=$(CROSS_COMPILE)gcc -C fmc/source && \
	 install -d $(DESTDIR)/usr/local/bin && \
	 install -m 755 fmc/source/fmc $(DESTDIR)/usr/local/bin/fmc && \
	 install -d $(DESTDIR)/etc/fmc/config && \
	 install -m 644 fmc/etc/fmc/config/hxs_pdl_v3.xml $(DESTDIR)/etc/fmc/config && \
	 install -m 644 fmc/etc/fmc/config/netpcd.xsd $(DESTDIR)/etc/fmc/config && \
	 install -d $(DESTDIR)/usr/local/include/fmc && \
	 install fmc/source/fmc.h $(DESTDIR)/usr/local/include/fmc && \
	 install -d $(DESTDIR)/usr/local/lib/$$host && \
	 install fmc/source/libfmc.a $(DESTDIR)/usr/local/lib/$$host && \
	 install -d $(DESTDIR)/usr/local/fmc/ && \
	 install -m 755 $(FBDIR)/packages/rfs/misc/fmc/init-ls104xa $(DESTDIR)/usr/local/fmc && \
	 install -d $(DESTDIR)/lib/systemd/system/ && \
	 install -d $(DESTDIR)/etc/systemd/system/multi-user.target.wants/ && \
	 install $(FBDIR)/packages/rfs/misc/fmc/fmc.service $(DESTDIR)/lib/systemd/system/ && \
	 ln -sf /lib/systemd/system/fmc.service $(DESTDIR)/etc/systemd/system/multi-user.target.wants/fmc.service && \
	 $(call fbprint_d,"fmc")
endif
endif


.PHONY: spc
spc:
ifeq ($(CONFIG_APP_SPC), y)
ifeq ($(DESTARCH),arm64)
	@[ $(DISTROSCALE) = mate -o $(DISTROSCALE) = lite -o $(DISTROTYPE) = centos -o $(DISTROSCALE) = tiny ] && exit || \
	 $(call fbprint_b,"SPC") && $(call fetch-git-tree,spc) && \
	 if [ $(DISTROTYPE) = ubuntu -o $(DISTROTYPE) = yocto -o $(DISTROTYPE) = debian ]; then xmlhdr=$(RFSDIR)/usr/include/libxml2; \
	 elif [ $(DISTROTYPE) = buildroot ]; then xmlhdr=$(RFSDIR)/../host/include/libxml2; fi && \
	 if [ ! -f $$xmlhdr/libxml/parser.h ]; then $(call build_dependent_rfs); fi && \
	 export LDFLAGS="-L$(RFSDIR)/lib -L$(RFSDIR)/lib/aarch64-linux-gnu -L$(RFSDIR)/usr/lib \
	 -Wl,-rpath=$(RFSDIR)/lib:$(RFSDIR)/lib/aarch64-linux-gnu:$(RFSDIR)/usr/lib/aarch64-linux-gnu:$(RFSDIR)/usr/lib" && \
	 $(MAKE) LIBXML2_HEADER_PATH=$$xmlhdr TCLAP_HEADER_PATH=$(RFSDIR)/usr/include \
	         NET_USPACE_HEADER_PATH=$(FBDIR)/packages/apps/spc/source/include/net \
	         CXX=$(CROSS_COMPILE)g++ CC=$(CROSS_COMPILE)gcc -C $(FBDIR)/packages/apps/spc/source && \
	 cp -f $(FBDIR)/packages/apps/spc/source/spc $(DESTDIR)/usr/local/bin && \
	 cp -rf $(FBDIR)/packages/apps/spc/etc $(DESTDIR) && \
	 $(call fbprint_d,"SPC")
endif
endif


.PHONY: cst
cst:
ifeq ($(CONFIG_APP_CST), y)
	@[ $(DISTROTYPE) != ubuntu -a $(DISTROTYPE) != yocto -o $(DISTROSCALE) = tiny ] && exit || \
	 $(call fbprint_b,"CST") && $(call fetch-git-tree,cst) && \
	 cd $(FBDIR)/packages/apps/cst && $(MAKE) -j$(JOBS) && \
	 if [ -n "$(SECURE_PRI_KEY)" ]; then \
	     echo Using specified $(SECURE_PRI_KEY) and $(SECURE_PUB_KEY) ... ; \
	     cp -f $(SECURE_PRI_KEY) $(FBDIR)/packages/apps/cst/srk.pri; \
	     cp -f $(SECURE_PUB_KEY) $(FBDIR)/packages/apps/cst/srk.pub; \
	 elif [ ! -f cst/srk.pri -o ! -f cst/srk.pub ]; then \
	     cd $(FBDIR)/packages/apps/cst && ./gen_keys 1024 && \
	     echo "Generated new keys !"; else echo "Using default keys srk.pri and srk.pub"; \
	 fi && $(call fbprint_d,"CST")
endif


.PHONY: aiopsl
aiopsl:
ifeq ($(CONFIG_APP_AIOPSL), y)
ifeq ($(DESTARCH),arm64)
	@[ $(DISTROTYPE) != ubuntu -a $(DISTROTYPE) != yocto -o $(DISTROSCALE) = tiny ] && exit || \
	 $(call fbprint_b,"AIOPSL") && $(call fetch-git-tree,aiopsl) && \
	 cd $(FBDIR)/packages/apps/aiopsl && \
	 if [ ! -d $(DESTDIR)/usr/local/aiop/bin ]; then mkdir -p $(DESTDIR)/usr/local/aiop/bin; fi && \
	 cp -rf misc/setup/scripts $(DESTDIR)/usr/local/aiop  && \
	 cp -rf misc/setup/traffic_files $(DESTDIR)/usr/local/aiop && \
	 cp -rf demos/images/* $(DESTDIR)/usr/local/aiop/bin && \
	 $(call fbprint_d,"AIOPSL")
endif
endif


.PHONY: gpp_aioptool
gpp_aioptool:
ifeq ($(CONFIG_APP_GPP_AIOPTOOL), y)
ifeq ($(DESTARCH),arm64)
	@$(call fbprint_b,"gpp_aioptool") && $(call fetch-git-tree,gpp_aioptool) && \
	 cd $(FBDIR)/packages/apps/gpp_aioptool && $(MAKE) clean && $(MAKE) && $(MAKE) install && \
	 $(call fbprint_d,"gpp_aioptool")
endif
endif


.PHONY: ceetm
ceetm:
ifeq ($(CONFIG_APP_CEETM), y)
	@[ $(DISTROTYPE) != ubuntu -o $(DISTROSCALE) = mate -o $(DISTROSCALE) = lite ] && exit || \
	 $(call fbprint_b,"CEETM") && $(call fetch-git-tree,ceetm) && \
	 if [ ! -f $(FBDIR)/packages/apps/iproute2-4.15.0/tc/tc_util.h ]; then \
	     wget $(iproute2_src_url) && tar xzf iproute2-4.15.0.tar.gz; \
	 fi && \
	 export IPROUTE2_DIR=$(FBDIR)/packages/apps/iproute2-4.15.0 && \
	 cd $(FBDIR)/packages/apps/ceetm && $(MAKE) clean && $(MAKE) && $(MAKE) install && \
	 $(call fbprint_d,"CEETM")
endif


.PHONY: dce
dce:
ifeq ($(CONFIG_APP_DCE), y)
ifeq ($(DESTARCH),arm64)
	@[ $(DISTROTYPE) != ubuntu -a $(DISTROTYPE) != yocto -o $(DISTROSCALE) = tiny ] && exit || \
	 $(call fbprint_b,"dce") && $(call fetch-git-tree,dce) && \
	 cd $(FBDIR)/packages/apps/dce && \
	 if [ ! -f lib/qbman_userspace/Makefile ]; then git submodule update; fi && \
	 $(MAKE) ARCH=aarch64 && $(MAKE) install && $(call fbprint_d,"dce")
endif
endif


optee: optee_os optee_client optee_test

.PHONY: optee_os
optee_os:
ifeq ($(CONFIG_APP_OPTEE), y)
ifeq ($(DESTARCH),arm64)
	@[ $(DISTROTYPE) != ubuntu -o $(DISTROSCALE) = mate -o $(DISTROSCALE) = lite ] && exit || \
	 $(call fbprint_b,"optee_os") && $(call fetch-git-tree,optee_os) && \
	 if [ $(MACHINE) = all ]; then \
	     for brd in $(LS_MACHINE_LIST); do \
		 if [ $$brd = ls1021atwr -o $$brd = ls1028ardb ]; then continue; fi; \
		 flex-builder -c optee_os -m $$brd -a $(DESTARCH) -f $(CONFIGLIST); \
	     done; \
	 else \
             if [ $(MACHINE) = ls1088ardb_pb ]; then brd=ls1088ardb; \
	     elif [ $(MACHINE) = ls1046afrwy ]; then brd=ls1046ardb; else brd=$(MACHINE); fi && \
	     cd $(FBDIR)/packages/apps/optee_os && $(MAKE) CFG_ARM64_core=y PLATFORM=ls-$$brd ARCH=arm;\
		$(CROSS_COMPILE)\objcopy -v -O binary out/arm-plat-ls/core/tee.elf out/arm-plat-ls/core/tee_$(MACHINE).bin;\
	     if [ $(MACHINE) = ls1012afrwy ]; then \
		mv out/arm-plat-ls/core/tee_$(MACHINE).bin out/arm-plat-ls/core/tee_$(MACHINE)_512mb.bin && \
		$(MAKE) -j$(JOBS) CFG_ARM64_core=y PLATFORM=ls-ls1012afrwy ARCH=arm CFG_DRAM0_SIZE=0x40000000 && \
		$(CROSS_COMPILE)\objcopy -v -O binary out/arm-plat-ls/core/tee.elf out/arm-plat-ls/core/tee_$(MACHINE).bin; \
             fi; \
	fi && rm -f out/arm-plat-ls/core/tee.bin && $(call fbprint_d,"optee_os")
endif
else
	@$(call fbprint_w,INFO: CONFIG_APP_OPTEE is not enabled by default in configs/$(CONFIGLIST))
endif


.PHONY: optee_client
optee_client:
ifeq ($(CONFIG_APP_OPTEE), y)
ifeq ($(DESTARCH),arm64)
	@[ $(DISTROTYPE) != ubuntu -o $(DISTROSCALE) = mate -o $(DISTROSCALE) = lite ] && exit || \
	 $(call fbprint_b,"optee_client") && $(call fetch-git-tree,optee_client) && \
	 cd $(FBDIR)/packages/apps/optee_client && $(MAKE) -j$(JOBS) ARCH=arm64 && mkdir -p $(DESTDIR)/usr/local/lib && \
	 ln -sf $(DESTDIR)/lib/libteec.so $(DESTDIR)/usr/local/lib/libteec.so && \
	 $(call fbprint_d,"optee_client")
endif
else
	@$(call fbprint_w,INFO: CONFIG_APP_OPTEE is not enabled by default in configs/$(CONFIGLIST))
endif


.PHONY: optee_test
optee_test:
ifeq ($(CONFIG_APP_OPTEE), y)
ifeq ($(DESTARCH),arm64)
	@[ $(DISTROTYPE) != ubuntu -o $(DISTROSCALE) = mate -o $(DISTROSCALE) = lite ] && exit || \
	 $(call fbprint_b,"optee_test") && $(call fetch-git-tree,optee_test) && \
	 if [ ! -f $(DESTDIR)/lib/libteec.so.1.0 ]; then flex-builder -c optee_client -m $(MACHINE); fi && \
	 cd $(FBDIR)/packages/apps/optee_test && $(MAKE) CFG_ARM64=y OPTEE_CLIENT_EXPORT=$(DESTDIR) \
	 TA_DEV_KIT_DIR=$(FBDIR)/packages/apps/optee_os/out/arm-plat-ls/export-ta_arm64 && \
	 mkdir -p $(DESTDIR)/lib/optee_armtz && \
	 cp $(FBDIR)/packages/apps/optee_test/out/ta/*/*.ta $(DESTDIR)/lib/optee_armtz && \
	 cp $(FBDIR)/packages/apps/optee_test/out/xtest/xtest $(DESTDIR)/bin && \
	 $(call fbprint_d,"optee_test")
endif
else
	@$(call fbprint_w,INFO: CONFIG_APP_OPTEE is not enabled by default in configs/$(CONFIGLIST))
endif


.PHONY: libpkcs11
libpkcs11:
ifeq ($(CONFIG_APP_LIBPKCS11), y)
ifeq ($(DESTARCH),arm64)
	@[ $(DISTROTYPE) != ubuntu -o $(DISTROSCALE) = mate -o $(DISTROSCALE) = lite ] && exit || \
	 $(call fbprint_b,"libpkcs11") && $(call fetch-git-tree,libpkcs11) && \
	 if [ ! -d $(FBDIR)/packages/apps/openssl ]; then \
	     echo building dependent openssl ... && \
	     flex-builder -c openssl -a $(DESTARCH) -f $(CONFIGLIST); \
	 fi && \
	 if [ ! -d $(FBDIR)/packages/apps/secure_obj/securekey_lib/include ]; then \
	     echo building dependent secure_obj ... && \
	     flex-builder -c secure_obj -a $(DESTARCH) -f $(CONFIGLIST); \
	 fi && \
	 cd $(FBDIR)/packages/apps/libpkcs11 && $(MAKE) clean && $(MAKE) all OPENSSL_PATH=$(FBDIR)/packages/apps/openssl \
	 EXPORT_DIR=$(DESTDIR)/usr/local CURDIR=$(FBDIR)/packages/apps/libpkcs11 \
	 SECURE_OBJ_PATH=$(FBDIR)/packages/apps/secure_obj/securekey_lib && \
	 mkdir -p $(DESTDIR)/usr/local/bin && \
	 mv $(DESTDIR)/usr/local/app/pkcs11_app $(DESTDIR)/usr/local/bin && \
	 cp -f images/thread_test $(DESTDIR)/usr/bin && $(call fbprint_d,"libpkcs11")
endif
else
	@$(call fbprint_w,INFO: CONFIG_APP_LIBPKCS11 is not enabled by default in configs/$(CONFIGLIST)) && exit 1
endif


.PHONY: secure_obj
secure_obj:
ifeq ($(CONFIG_APP_SECURE_OBJ), y)
ifeq ($(DESTARCH),arm64)
	@[ $(DISTROTYPE) != ubuntu -o $(DISTROSCALE) = mate -o $(DISTROSCALE) = lite ] && exit || \
	 $(call fbprint_b,"secure_obj") && $(call fetch-git-tree,secure_obj) && \
	 if [ ! -d $(FBDIR)/packages/apps/openssl ]; then \
	    echo building dependent openssl ... && \
	    flex-builder -c openssl -f $(CONFIGLIST); \
	 fi && \
	 if [ $(CONFIG_APP_OPTEE) != y ]; then \
	     $(call fbprint_e,"Please enable CONFIG_APP_OPTEE to y in configs/$(CONFIGLIST)"); exit 1; \
	 fi && \
	 if [ ! -d $(FBDIR)/packages/apps/optee_os/out/arm-plat-ls ]; then flex-builder -c optee_os -f $(CONFIGLIST); fi && \
	 if [ ! -f $(DESTDIR)/lib/libteec.so ]; then flex-builder -c optee_client -f $(CONFIGLIST); fi && \
	 curbrch=`cd $(KERNEL_PATH) && git branch | grep ^* | cut -d' ' -f2` && \
         kerneloutdir=$(KERNEL_OUTPUT_PATH)/$$curbrch && \
	 if [ ! -f $$kerneloutdir/.config ]; then $(call build_dependent_linux); fi && \
	 kernelrelease=`cat $$kerneloutdir/include/config/kernel.release` && \
	 cd $(FBDIR)/packages/apps/secure_obj && export DESTDIR=${DESTDIR}/usr/local && \
	 export TA_DEV_KIT_DIR=$(FBDIR)/packages/apps/optee_os/out/arm-plat-ls/export-ta_arm64 && \
	 export OPTEE_CLIENT_EXPORT=$(DESTDIR) && export KERNEL_SRC=$(KERNEL_PATH) && \
	 export KERNEL_BUILD=$$kerneloutdir && $(call fbprint_n,"Using KERNEL_BUILD $$kerneloutdir") && \
	 export SECURE_STORAGE_PATH=$(FBDIR)/packages/apps/secure_obj/secure_storage_ta/ta && mkdir -p $(DESTDIR)/usr/lib && \
	 export OPENSSL_PATH=$(FBDIR)/packages/apps/openssl && mkdir -p $(DESTDIR)/usr/local/secure_obj/$$curbrch && \
	 mkdir -p $(DESTDIR)/usr/lib/aarch64-linux-gnu/openssl-1.0.0/engines && mkdir -p $(DESTDIR)/lib/optee_armtz && \
	 ./compile.sh && cp images/libeng_secure_obj.so $(DESTDIR)/usr/lib/aarch64-linux-gnu/openssl-1.0.0/engines && \
	 mkdir -p $(FBDIR)/build/linux/kernel/$(DESTARCH)/$(SOCFAMILY)/lib/modules/$$kernelrelease/extra && \
	 cp images/securekeydev.ko $(FBDIR)/build/linux/kernel/$(DESTARCH)/$(SOCFAMILY)/lib/modules/$$kernelrelease/extra/ && \
	 cp images/*.ta $(DESTDIR)/lib/optee_armtz && cp images/*.so $(DESTDIR)/usr/local/lib && \
	 cp images/{*_app,mp_verify} $(DESTDIR)/usr/local/bin && cp -rf securekey_lib/include/* $(DESTDIR)/usr/local/include && \
	 $(call fbprint_d,"secure_obj")
endif
else
	@$(call fbprint_w,INFO: CONFIG_APP_SECURE_OBJ is not enabled by default in configs/$(CONFIGLIST)) && exit 1
endif


.PHONY: openssl
openssl:
ifeq ($(CONFIG_APP_OPENSSL), y)
	@[ $(DISTROTYPE) != ubuntu -a $(DISTROTYPE) != yocto -o $(DISTROSCALE) = mate -o $(DISTROSCALE) = lite -o $(DISTROSCALE) = tiny ] && exit || \
	 $(call fbprint_b,"OpenSSL") && $(call fetch-git-tree,openssl) && \
	 if [ ! -d $(DESTDIR)/usr/local/include/crypto ]; then \
	     echo building dependent cryptodev_linux ... ; \
	     flex-builder -c cryptodev_linux -a $(DESTARCH) -f $(CONFIGLIST); \
	 fi && \
	 if [ $(DESTARCH) = arm64 ]; then \
	     archopt=linux-aarch64; \
	 elif [ $(DESTARCH) = arm32 ]; then \
	     archopt=linux-armv4; \
	 else \
	     $(call fbprint_e,"$(DESTARCH) is not supported"); exit 1; \
	 fi && \
	 cd $(FBDIR)/packages/apps/openssl && ./Configure -DHAVE_CRYPTODEV -I$(DESTDIR)/usr/local/include \
	 $$archopt shared --prefix=/usr/local --openssldir=lib/ssl && \
	 $(MAKE) clean && $(MAKE) depend && $(MAKE) && \
         $(MAKE) DESTDIR=$(DESTDIR) install && \
         rm -fr $(DESTDIR)/usr/local/lib/ssl/{certs,openssl.cnf,private} && \
         ln -s /etc/ssl/certs/ $(DESTDIR)/usr/local/lib/ssl/ && \
         ln -s /etc/ssl/private/ $(DESTDIR)/usr/local/lib/ssl/ && \
         ln -s /etc/ssl/openssl.cnf $(DESTDIR)/usr/local/lib/ssl/ && \
         $(call fbprint_d,"OpenSSL")
endif


.PHONY: openstack_nova
openstack_nova:
ifeq ($(CONFIG_APP_OPENSTACK_NOVA), y)
ifeq ($(DESTARCH),arm64)
	@[ $(DISTROTYPE) != ubuntu -o $(DISTROSCALE) = mate -o $(DISTROSCALE) = lite ] && exit || \
	 $(call fbprint_b,"openstack_nova") && $(call fetch-git-tree,openstack_nova) && \
	 if [ ! -f $(FBDIR)/packages/apps/openstack_nova/nova/.patched ]; then \
	    cd $(FBDIR)/packages/apps/openstack_nova/nova && sed -zi 's/\,\n\s*retry_on_request\=True//g' db/sqlalchemy/api.py && \
	    sed -i '/from os_brick.initiator import connector/i\from os_brick import initiator' virt/libvirt/volume/drbd.py && \
	    sed -i 's/connector.DRBD/initiator.DRBD/' virt/libvirt/volume/drbd.py && touch .patched; \
	 fi && \
	 cd $(FBDIR)/packages/apps/openstack_nova && sudo python setup.py install \
	    --install-lib=$(RFSDIR)/usr/lib/python2.7/dist-packages --install-scripts=$(RFSDIR)/usr/local/bin && \
	 $(call fbprint_d,"openstack_nova")
endif
else
	@$(call fbprint_w,INFO: CONFIG_APP_OPENSTACK_NOVA is not enabled by default in configs/$(CONFIGLIST))
endif


.PHONY: qbman_userspace
qbman_userspace:
ifeq ($(CONFIG_APP_QBMAN_USERSPACE), y)
ifeq ($(DESTARCH),arm64)
	@[ $(DISTROTYPE) != ubuntu -o $(DISTROSCALE) = mate -o $(DISTROSCALE) = lite ] && exit || \
	 $(call fbprint_b,"qbman_userspace") && $(call fetch-git-tree,qbman_userspace) && \
	 cd $(FBDIR)/packages/apps/qbman_userspace && export PREFIX=/usr/local && export ARCH=aarch64 && $(MAKE) && \
	 cp -f lib_aarch64_static/libqbman.a $(DESTDIR)/usr/local/lib/ && \
	 cp -f include/*.h $(DESTDIR)/usr/local/include/ && $(call fbprint_d,"qbman_userspace")
endif
endif


.PHONY: eth_config
eth_config:
ifeq ($(CONFIG_APP_ETH_CONFIG), y)
ifeq ($(DESTARCH),arm64)
	@[ $(DISTROSCALE) = mate -o $(DISTROSCALE) = lite ] && exit || \
	 $(call fbprint_b,"eth_config") && $(call fetch-git-tree,eth_config) && \
	 mkdir -p $(DESTDIR)/etc/fmc/config && cd $(FBDIR)/packages/apps/eth_config && \
	 cp -rf private $(DESTDIR)/etc/fmc/config && cp -rf shared_mac $(DESTDIR)/etc/fmc/config && \
	 $(call fbprint_d,"eth_config")
endif
endif


.PHONY: crconf
crconf:
ifeq ($(CONFIG_APP_CRCONF), y)
ifeq ($(DESTARCH),arm64)
	@[ $(DISTROTYPE) != ubuntu -a $(DISTROTYPE) != yocto -o $(DISTROSCALE) = mate -o $(DISTROSCALE) = lite ] && exit || \
	 $(call fbprint_b,"crconf") && $(call fetch-git-tree,crconf) && \
	 sed -i -e 's/CC =/CC ?=/' -e 's/DESTDIR=/DESTDIR?=/' crconf/Makefile && \
	 cd $(FBDIR)/packages/apps/crconf && export CC=$(CROSS_COMPILE)gcc && export DESTDIR=${DESTDIR}/usr/local && \
	 $(MAKE) clean && $(MAKE) && $(MAKE) install && $(call fbprint_d,"crconf")
endif
endif


.PHONY: iperf
iperf:
ifeq ($(CONFIG_APP_IPERF), y)
ifeq ($(DESTARCH),arm64)
	@[ $(DISTROTYPE) != ubuntu -o $(DISTROSCALE) = mate -o $(DISTROSCALE) = lite ] && exit || \
	 $(call fbprint_b,"IPERF") && $(call fetch-git-tree,iperf) && \
	 cd $(FBDIR)/packages/apps/iperf && export CC=aarch64-linux-gnu-gcc && \
         export CXX=aarch64-linux-gnu-g++ && ./configure --host=aarch64 && \
         make && sudo make install DESTDIR=$(DESTDIR) && $(call fbprint_d,"IPERF")
endif
endif


edgescale: edgescale_eds eds_kubelet eds_bootstrap selinux

.PHONY: edgescale_eds
edgescale_eds:
ifeq ($(CONFIG_APP_EDGESCALE), y)
	@[ $(DISTROTYPE) != ubuntu -o $(DISTROSCALE) = mate -o $(DISTROSCALE) = lite ] && exit || \
	 $(call fbprint_b,"edgescale_eds") && $(call fetch-git-tree,edgescale_eds) && \
	 if [ $(DESTARCH) = arm32 ]; then arch=arm; \
         elif [ $(DESTARCH) = arm64 ]; then arch=arm64; \
         else echo $(DESTARCH) is unsupported in edgescale_eds; exit 0; \
         fi && \
	 if [ $(CONFIG_EDGESCALE_SECURE_MODE) = y ]; then \
	     $(call fbprint_n,"Edgescale secure mode enabled") && \
	     if [ $(DESTARCH) != arm64 ]; then \
	         echo $(DESTARCH) is not supported yet for EdgeScale secure mode; exit 0; \
	     fi && \
	     if [ $(CONFIG_APP_OPTEE) = n ]; then \
		 $(call fbprint_e,"Please enable CONFIG_APP_OPTEE to y in configs/$(CONFIGLIST)"); exit 1; \
	     fi && \
	     if [ ! -f $(DESTDIR)/lib/libteec.so ]; then \
		 echo dependent libteec.so not exist, building it ... && flex-builder -c secure_obj -f $(CONFIGLIST); \
	     fi && \
	     if [ ! -d $(DESTDIR)/usr/local/include/openssl ]; then \
		 echo dependent openssl not exist, building it ... && flex-builder -c openssl -f $(CONFIGLIST); \
	     fi && \
	     cd $(FBDIR)/packages/apps/edgescale_eds && $(MAKE) -j$(JOBS) ARCH=$$arch OPENSSL_PATH=$(DESTDIR)/usr/local \
	     SECURE_OBJ_PATH=$(DESTDIR)/usr/local OPTEE_CLIENT_EXPORT=$(DESTDIR)/lib GOBUILDTAGS=secure; \
	 else \
	     $(call fbprint_w,"$(DESTARCH) Edgescale: secure mode not enabled") && \
	     cd $(FBDIR)/packages/apps/edgescale_eds && $(MAKE) -j$(JOBS) ARCH=$$arch OPENSSL_PATH=$(DESTDIR)/usr/local \
	     SECURE_OBJ_PATH=$(DESTDIR)/usr/local OPTEE_CLIENT_EXPORT=$(DESTDIR)/lib; \
         fi && \
         $(MAKE) install INSTALL_DIR=$(DESTDIR) ARCH=$$arch && $(call fbprint_d,"edgescale_eds")
else
	@$(call fbprint_w,INFO: CONFIG_APP_EDGESCALE is not enabled by default in configs/$(CONFIGLIST))
endif


.PHONY: eds_kubelet
eds_kubelet:
ifeq ($(CONFIG_APP_EDGESCALE), y)
	@[ $(DISTROTYPE) != ubuntu -o $(DISTROSCALE) = mate -o $(DISTROSCALE) = lite ] && exit || \
	 $(call fbprint_b,"eds_kubelet") && $(call fetch-git-tree,eds_kubelet) && \
	 if [ $(DESTARCH) = arm32 ]; then arch=arm; elif [ $(DESTARCH) = arm64 ]; then arch=arm64; else \
	 echo $(DESTARCH) is unsupported in eds-kubelet; exit 0; fi && \
	 cd $(FBDIR)/packages/apps/eds_kubelet && $(MAKE) ARCH=$$arch && $(MAKE) install INSTALL_DIR=$(DESTDIR) ARCH=$$arch && \
	 $(call fbprint_d,"eds_kubelet")
endif


.PHONY: eds_bootstrap
eds_bootstrap:
ifeq ($(CONFIG_APP_EDGESCALE), y)
	@[ $(DISTROTYPE) != ubuntu -o $(DISTROSCALE) = mate -o $(DISTROSCALE) = lite ] && exit || \
	 $(call fbprint_b,"eds_bootstrap") && $(call fetch-git-tree,eds_bootstrap) && \
	 if [ $(DESTARCH) = arm32 ]; then arch=arm; elif [ $(DESTARCH) = arm64 ]; then \
	 arch=arm64; else echo $(DESTARCH) is unsupported in eds-bootstrap; exit 0; fi && \
	 cd $(FBDIR)/packages/apps/eds_bootstrap && $(MAKE) install INSTALL_DIR=$(DESTDIR) ARCH=$$arch && \
	 $(call fbprint_d,"eds_bootstrap")
endif


.PHONY: eiq
eiq:
ifeq ($(CONFIG_APP_EIQ), y)
ifeq ($(DESTARCH),arm64)
	@[ $(DISTROTYPE) != ubuntu -o $(DISTROSCALE) = lite ] && exit || \
	 $(call fbprint_b,"eIQ") && $(call fetch-git-tree,eiq) && mkdir -p $(DESTDIR)/opt && \
	 cp -rf $(FBDIR)/packages/apps/eiq $(DESTDIR)/opt && $(call fbprint_d,"eIQ")
endif
endif


.PHONY: selinux
selinux:
ifeq ($(CONFIG_APP_EDGESCALE), y)
	@[ $(DISTROTYPE) != ubuntu -o $(DISTROSCALE) = mate -o $(DISTROSCALE) = lite ] && exit || \
	 if [ $(CONFIG_EDGESCALE_SECURE_MODE) = y ]; then \
	     if [ ! -f $(RFSDIR)/usr/include/aarch64-linux-gnu/openssl/opensslconf.h ]; then $(call build_dependent_rfs); fi && \
             sudo mkdir -p $(RFSDIR)/tmp/selinux-build/ && \
             sudo cp $(FBDIR)/packages/rfs/misc/selinux/* $(RFSDIR)/tmp/selinux-build/ && \
	     if [ $(DISTROSCALE) != main -a $(DISTROSCALE) != lite ]; then \
                 sudo chroot $(RFSDIR) apt-get install -y dpkg gawk python bison flex selinux-utils \
	         policycoreutils auditd grub2-common selinux-policy-default checkpolicy semodule-utils; \
	     fi && \
             sudo bash -e $(RFSDIR)/tmp/selinux-build/download.sh && \
             sudo chroot $(RFSDIR) bash -e /tmp/selinux-build/build.sh; \
        fi
endif


.PHONY: cjson
cjson:
ifeq ($(CONFIG_APP_CJSON), y)
ifeq ($(DESTARCH),arm64)
	@[ $(DISTROTYPE) != ubuntu -a $(DISTROTYPE) != yocto -o $(DISTROSCALE) = mate ] && exit || \
	 $(call fbprint_b,"cjson") && $(call fetch-git-tree,cjson) && \
	 cd $(FBDIR)/packages/apps/cjson && export CC=$(CROSS_COMPILE)gcc && \
         mkdir -p build && cd build && cmake -DCMAKE_INSTALL_PREFIX=/usr/local .. && \
         $(MAKE) && sudo $(MAKE) install DESTDIR=$(RFSDIR) && $(call fbprint_d,"cjson")
endif
endif


.PHONY: tsntool
tsntool:
ifeq ($(CONFIG_APP_TSNTOOL), y)
ifeq ($(DESTARCH),arm64)
	@[ $(DISTROTYPE) != ubuntu -a $(DISTROTYPE) != yocto -o $(DISTROSCALE) = mate -o $(DISTROSCALE) = tiny ] && exit || \
	 $(call fbprint_b,"tsntool") && $(call fetch-git-tree,tsntool) && cd $(FBDIR)/packages/linux && $(call fetch-git-tree,linux) && cd - && \
	 if [ $(DISTROTYPE) = ubuntu -a ! -f $(RFSDIR)/lib/aarch64-linux-gnu/libnl-genl-3.so ] || \
	 [ $(DISTROTYPE) = yocto -a ! -f $(RFSDIR)/usr/lib/libnl-genl-3.so ]; then $(call build_dependent_rfs); fi && \
	 if [ ! -f $(RFSDIR)/usr/local/include/cjson/cJSON.h ]; then flex-builder -c cjson -a $(DESTARCH) -f $(CONFIGLIST); fi && \
	 cd $(FBDIR)/packages/apps/tsntool && export CC="$(CROSS_COMPILE)gcc --sysroot=$(RFSDIR)" && export PKG_CONFIG_SYSROOT_DIR=$(RFSDIR) && \
	 export PKG_CONFIG_LIBDIR=$(RFSDIR)/usr/local/lib/pkgconfig:$(RFSDIR)/usr/lib/pkgconfig:$(RFSDIR)/usr/lib/aarch64-linux-gnu/pkgconfig && \
	 mkdir -p include/linux && cp -f $(KERNEL_PATH)/include/uapi/linux/tsn.h include/linux && $(MAKE) clean && $(MAKE) && \
	 install -d $(DESTDIR)/usr/local/bin && install -d $(DESTDIR)/usr/lib && install -m 755 tsntool $(DESTDIR)/usr/local/bin/tsntool$$tsnver && \
	 install -m 755 libtsn.so $(DESTDIR)/usr/lib/libtsn.so$$tsnver && $(call fbprint_d,"tsntool")
endif
endif


.PHONY: wayland
wayland:
ifeq ($(CONFIG_APP_WAYLAND), y)
ifeq ($(DESTARCH),arm64)
	@[ $(DISTROTYPE) != ubuntu -o $(DISTROSCALE) = lite ] && exit || \
	 $(call fbprint_b,"wayland") && $(call fetch-git-tree,wayland) && \
	 if [ $(DISTROTYPE) != ubuntu ]; then echo wayland is not supported on $(DISTROTYPE) yet; exit; fi && \
	 export CC="$(CROSS_COMPILE)gcc --sysroot=$(RFSDIR)" && export PKG_CONFIG_SYSROOT_DIR=$(RFSDIR) && \
	 export PKG_CONFIG_LIBDIR=$(RFSDIR)/usr/lib/aarch64-linux-gnu/pkgconfig && cd $(FBDIR)/packages/apps/wayland && \
	 ./autogen.sh --prefix=/usr/local --host=aarch64-linux-gnu --disable-documentation --with-host-scanner && \
	 $(MAKE) && $(MAKE) install && $(call fbprint_d,"wayland")
endif
endif


.PHONY: wayland_protocols
wayland_protocols:
ifeq ($(CONFIG_APP_WAYLAND_PROTOCOLS), y)
ifeq ($(DESTARCH),arm64)
	@[ $(DISTROTYPE) != ubuntu -o $(DISTROSCALE) = lite ] && exit || \
	 $(call fbprint_b,"wayland_protocols") && $(call fetch-git-tree,wayland_protocols) && \
	 cd $(FBDIR)/packages/apps/wayland_protocols && ./autogen.sh --prefix=/usr --host=aarch64-linux-gnu && \
	 $(MAKE) && $(MAKE) install && $(call fbprint_d,"wayland_protocols")
endif
endif


.PHONY: libdrm
libdrm:
ifeq ($(CONFIG_APP_LIBDRM), y)
ifeq ($(DESTARCH),arm64)
	@[ $(DISTROTYPE) != ubuntu -o $(DISTROSCALE) = lite ] && exit || \
	 $(call fbprint_b,"libdrm") && $(call fetch-git-tree,libdrm) && \
	 export CC="$(CROSS_COMPILE)gcc --sysroot=$(RFSDIR)" && cd $(FBDIR)/packages/apps/libdrm && \
	 ./autogen.sh --prefix=/usr/local --host=aarch64-linux-gnu --disable-vc4 \
	 --enable-vivante-experimental-api --disable-freedreno --disable-vmwgfx --disable-nouveau \
	 --disable-amdgpu --disable-radeon --disable-intel && $(MAKE) && $(MAKE) install && \
	 cp tests/modetest/.libs/modetest $(DESTDIR)/usr/local/bin && \
	 $(call fbprint_d,"libdrm")
endif
endif


.PHONY: gpulib
gpulib:
ifeq ($(CONFIG_APP_GPULIB), y)
ifeq ($(DESTARCH),arm64)
	@[ $(DISTROTYPE) != ubuntu -o $(DISTROSCALE) = lite ] && exit || \
	 $(call fbprint_b,"gpulib") && $(call fetch-git-tree,gpulib) && \
	 if [ ! -d $(FBDIR)/packages/apps/gpulib ]; then \
	     curl -R -k -f $(gpulib_bin_url) -o gpulib.bin && chmod +x gpulib.bin && \
	     ./gpulib.bin --auto-accept && mv gpulib-* gpulib && rm -f gpulib.bin; \
	 fi && \
	 cd $(FBDIR)/packages/apps/gpulib/ls1028a/linux && install -d $(DESTDIR)/opt && \
	 install -d $(DESTDIR)/usr/local/include && install -d $(DESTDIR)/usr/local/lib && \
	 cp -a gpu-demos/opt/viv_samples/* $(DESTDIR)/opt && \
	 cp -a gpu-core/usr/include/* $(DESTDIR)/usr/local/include && \
	 cp -a gpu-core/usr/lib/* $(DESTDIR)/usr/local/lib && \
	 $(call fbprint_d,"gpulib")
endif
endif


.PHONY: weston
weston:
ifeq ($(CONFIG_APP_WESTON), y)
ifeq ($(DESTARCH),arm64)
	@[ $(DISTROTYPE) != ubuntu -o $(DISTROSCALE) = lite ] && exit || \
	 $(call fbprint_b,"weston") && $(call fetch-git-tree,weston) && \
	 if [ ! -f $(RFSDIR)/usr/lib/aarch64-linux-gnu/libpng.so ]; then $(call build_dependent_rfs); fi && \
	 if [ ! -d $(DESTDIR)/usr/local/include/libdrm ]; then flex-builder -c libdrm -r $(DISTROTYPE):$(DISTROSCALE) -f $(CONFIGLIST); fi && \
	 if [ ! -f $(DESTDIR)/usr/local/include/wayland-client.h ]; then flex-builder -c wayland -r $(DISTROTYPE):$(DISTROSCALE) -f $(CONFIGLIST); fi && \
	 if [ ! -d $(DESTDIR)/usr/share/wayland-protocols ]; then flex-builder -c wayland_protocols -r $(DISTROTYPE):$(DISTROSCALE) -f $(CONFIGLIST); fi && \
	 if [ ! -d $(DESTDIR)/usr/local/include/EGL ]; then flex-builder -c gpulib -r $(DISTROTYPE):$(DISTROSCALE) -f $(CONFIGLIST); fi && \
	 sudo cp -rf $(DESTDIR)/usr/* $(RFSDIR)/usr/ && sudo sed -i -e "s#'/usr/local/lib'#'$(RFSDIR)/usr/local/lib'#g" \
	 -e "s# /usr/local/lib# $(RFSDIR)/usr/local/lib#g" $(RFSDIR)/usr/local/lib/*.la && if [ "$(ON_WSL)" = n ]; then sudo chroot $(RFSDIR) ldconfig; fi && \
	 export CC="$(CROSS_COMPILE)gcc --sysroot=$(RFSDIR)" && export PKG_CONFIG_SYSROOT_DIR=$(RFSDIR) && \
	 export PKG_CONFIG_LIBDIR=$(RFSDIR)/usr/local/lib/pkgconfig:$(RFSDIR)/usr/lib/aarch64-linux-gnu/pkgconfig:$(RFSDIR)/usr/share/pkgconfig && \
	 cd $(FBDIR)/packages/apps/weston && ./autogen.sh --prefix=/usr/local --host=aarch64-linux-gnu --enable-ivi-shell --disable-silent-rules \
	 --disable-dependency-tracking --disable-setuid-install --disable-xwayland --enable-simple-clients --enable-clients \
	 --enable-demo-clients-install --disable-rdp-compositor --disable-xwayland-test WESTON_NATIVE_BACKEND=drm-backend.so \
	 --enable-egl --enable-simple-egl-clients --enable-fbdev-compositor --disable-headless-compositor --enable-drm-compositor \
	 --enable-weston-launch --disable-lcms --disable-vaapi-recorder --disable-wayland-compositor --disable-x11-compositor --disable-imxg2d && \
	 $(MAKE) COMPOSITOR_LIBS="-lGLESv2 -lEGL -lGAL -lwayland-server -lxkbcommon -lpixman-1" && sudo $(MAKE) install DESTDIR=$(RFSDIR) && \
	 if [ $(DISTROTYPE) = ubuntu -o $(DISTROTYPE) = debian ]; then \
	     echo OPTARGS=\" \" | sudo tee $(RFSDIR)/etc/default/weston && \
	     sudo install $(FBDIR)/packages/rfs/misc/weston/weston.ini $(RFSDIR)/etc/xdg/weston && \
	     sudo install -m 755 $(FBDIR)/packages/rfs/misc/weston/weston.sh $(RFSDIR)/etc/profile.d/ && \
	     sudo install $(FBDIR)/packages/rfs/misc/weston/weston.service $(RFSDIR)/lib/systemd/system/ && \
	     sudo ln -sf /lib/systemd/system/weston.service $(RFSDIR)/etc/systemd/system/multi-user.target.wants/weston.service; \
	 fi && \
	 sudo sed -i -e "s#$(RFSDIR)##g" $(RFSDIR)/usr/local/lib/*.la && $(call fbprint_d,"weston")
endif
endif


.PHONY: docker_ce
docker_ce:
ifeq ($(CONFIG_APP_DOCKER_CE), y)
ifeq ($(DISTROTYPE), ubuntu)
	@[ $(DISTROTYPE) != ubuntu -o $(DISTROSCALE) = lite ] && exit || \
	 $(call fbprint_b,"docker_ce") && $(call fetch-git-tree,docker_ce) && \
	 if [ ! -d $(FBDIR)/packages/apps/docker_ce ]; then \
	     mkdir -p $(FBDIR)/packages/apps/docker_ce && cd $(FBDIR)/packages/apps/docker_ce && \
	     curl -R -O -f $(docker_ce_bin_url) && tar xf docker-ce-bin-v18.09.6.tar.gz --strip-components 1 && cd -; \
	 fi && \
	 if [ $(DESTARCH) = arm32 ]; then tarch=armhf; else tarch=$(DESTARCH); fi && \
	 if [ -f $(RFSDIR)/usr/bin/dockerd-ce ]; then $(call fbprint_n,"docker-ce was already installed") && exit; fi && \
	 if [ ! -d $(RFSDIR) ]; then $(call build_dependent_rfs); fi && \
	 if [ $(DISTROTYPE) = ubuntu -a $(DISTROSCALE) != lite -a -d docker_ce ]; then \
	     sudo cp -f $(FBDIR)/packages/apps/docker_ce/containerd/containerd.io_1.2.4_$${tarch}.deb $(RFSDIR) && \
	     sudo cp -f $(FBDIR)/packages/apps/docker_ce/docker-ce/ubuntu-bionic/$$tarch/*.deb $(RFSDIR) && \
	     sudo chroot $(RFSDIR) dpkg -i containerd.io_1.2.4_$${tarch}.deb && \
	     sudo chroot $(RFSDIR) dpkg -i docker-ce-cli_v18.09.6-ubuntu-bionic_$${tarch}.deb && \
	     sudo chroot $(RFSDIR) dpkg -i docker-ce_v18.09.6-ubuntu-bionic_$${tarch}.deb && \
	     sudo rm -f $(RFSDIR)/*.deb && $(call fbprint_d,"docker_ce"); \
	 fi
endif
endif

misc:
	@$(CROSS_COMPILE)gcc $(FBDIR)/packages/rfs/misc/ccsr.c -o $(DESTDIR)/usr/local/bin/ccsr

repo_fetch:
	@echo -e "\nfetch apps repositories ..."
	@$(call repo-update,fetch,$(APPS_REPO_LIST))

repo_update_branch:
	@echo -e "\napps repositories update for branch ..."
	@$(call repo-update,branch,$(APPS_REPO_LIST))

repo_update_tag:
	@echo -e "\napps repositories update for tag ..."
	@$(call repo-update,tag,$(APPS_REPO_LIST))

repo_update_latest:
	@echo -e "\napps repositories update to latest HEAD commit ..."
	@$(call repo-update,update,$(APPS_REPO_LIST))

repo_update_commit:
	@echo -e "\napps repositories update to specified commit ID ..."
	@$(call repo-update,commit,$(APPS_REPO_LIST))
