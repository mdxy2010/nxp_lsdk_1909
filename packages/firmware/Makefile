#####################################
#
# Copyright 2017-2019 NXP
#
# SPDX-License-Identifier:      BSD-3-Clause
#
#####################################

SHELL=/bin/bash
include $(FBDIR)/configs/$(CONFIGLIST)
include $(FBDIR)/include/repo.mk


firmware: uboot uefi_bin rcw atf mc_utils bin_firmware

bin_firmware: fm_ucode qe_ucode mc_bin phy_cortina phy_inphi pfe_bin ddr_phy_bin dp_firmware_cadence

uboot u-boot:
ifeq ($(CONFIG_FW_UBOOT), y)
	@$(call fetch-git-tree,uboot)
ifeq ($(BUILD_IMX_IMAGE), y)
	@$(call fetch-git-tree,imx_mkimage)
	@$(call fetch-git-tree,imx_scfw)
	@$(call fetch-git-tree,linux_firmware_imx)
endif
ifeq ($(MACHINE), all)
	@for brd in $(LS_MACHINE_LIST); do \
		if [ $$brd = ls1088ardb_pb ]; then brd=ls1088ardb; fi; \
		if [ $(DESTARCH) = arm64 -a $$brd = ls1021atwr ]; then continue; \
		elif [ $(DESTARCH) = arm32 ] && [ $$brd != ls1021atwr ]; then continue; fi; \
		$(call fbprint_n,"*** machine = $$brd ***"); \
		if [ $$brd = ls2088ardb ]; then brdmsk=*ls208?ardb*; else brdmsk=*$$brd*; fi && \
		for cfg in `ls $(UBOOT_TREE)/configs/$$brdmsk 2>/dev/null | cut -d/ -f3 | \
		        grep -iE 'tfa_defconfig|tfa_SECURE_BOOT_defconfig'`; do \
		    $(call build-uboot-target,$$cfg) \
		done; \
	 done
else
	@$(call fbprint_b,"uboot for $(MACHINE)")
	@if [ $(MACHINE) = ls2088ardb -o $(MACHINE) = ls2088aqds ]; then \
	     brdmsk=`echo $(MACHINE)* | sed s/88/8?/`; \
	 elif echo $(MACHINE) | grep -q ^[p,t,P,T].*; then \
	     brdmsk=*`tr '[a-z]' '[A-Z]' <<< $(MACHINE)`*; \
	 elif [ $(MACHINE) = ls1088ardb_pb ]; then \
	     brdmsk=*ls1088ardb*; \
	 elif [ $(MACHINE) = imx8mqevk ]; then \
	     brdmsk=imx8mq_evk_defconfig; \
	 elif [ $(MACHINE) = imx8mmevk ]; then \
	     brdmsk=imx8mm_evk_defconfig; \
	 elif [ $(MACHINE) = imx8qmmek ]; then \
	     brdmsk=imx8qm_mek_defconfig; \
	 elif [ $(MACHINE) = imx8qxpmek ]; then \
	     brdmsk=imx8qxp_mek_defconfig; \
	 elif [ $(MACHINE) = imx6qsabresd ]; then \
	     brdmsk=mx6qsabresd_defconfig; \
	 elif [ $(MACHINE) = imx6sllevk ]; then \
	     brdmsk=mx6sllevk_defconfig; \
	 elif [ $(MACHINE) = imx7ulpevk ]; then \
	     brdmsk=mx7ulp_evk_defconfig; \
	 elif echo $(MACHINE) | grep -q ^[imx].*; then \
	     brdmsk=$(MACHINE)_defconfig; \
	 else \
	     brdmsk=*$(MACHINE)*; \
	 fi && \
	 if [ -z "$(BOOTTYPE)" ]; then \
	     $(call fbprint_e,"please specify -b boottype parameter for u-boot on $(MACHINE)"); \
	     exit; \
	 else \
	     if [ $(BOOTTYPE) = tfa ]; then \
	         boottype=tfa; \
	     elif [ $(BOOTTYPE) = sd ]; then \
		 boottype='sdcard|sd_defconfig|*_evk_defconfig|*_mek_defconfig|sllevk_defconfig|ulp_evk_defconfig'; \
	     elif [ $(BOOTTYPE) = qspi ]; then \
		 boottype='qspi_defconfig|qspi_SECURE_BOOT_defconfig'; \
	     elif [ $(BOOTTYPE) = nor ]; then \
	         boottype='nor|rdb_defconfig|rdb_SECURE_BOOT_defconfig|qds_defconfig|qds_SECURE_BOOT_defconfig'; \
	     elif [ $(BOOTTYPE) = nand ]; then \
	         boottype='nand'; \
	     fi; \
	     for cfg in `ls $(UBOOT_TREE)/configs/$$brdmsk 2>/dev/null | cut -d/ -f3 | grep -iE $$boottype`; do \
	         $(call build-uboot-target,$$cfg) \
	     done; \
	 fi
endif

define build-uboot-target
	if echo $1 | grep -qE 'ls1021atwr|^mx';  then export ARCH=arm; export CROSS_COMPILE=arm-linux-gnueabihf-; dtbstr=-dtb; \
	elif echo $1 | grep -q ^[p,t,P,T].*;  then export ARCH=powerpc; export CROSS_COMPILE=powerpc-linux-; \
	     if [ ! -f $(FBDIR)/build/rfs/rootfs_buildroot_ppc32_tiny/host/bin/powerpc-linux-gcc ]; then \
	         flex-builder -i mktoolchain -a ppc32 -f $(CONFIGLIST); fi; \
	     if ! echo "$(PATH)" | grep -q ppc32; then export PATH="$(FBDIR)/build/rfs/rootfs_buildroot_ppc32_tiny/host/bin:$(PATH)";fi; \
	else export ARCH=arm64;export CROSS_COMPILE=aarch64-linux-gnu-; dtbstr=-dtb; fi && \
	if [ $(MACHINE) != all ]; then brd=$(MACHINE); fi && \
	if [ $$brd = ls1088ardb_pb ]; then brd=ls1088ardb; fi && \
	opdir=$(FBDIR)/build/firmware/u-boot/$$brd/output/$1 && \
	if [ ! -d $$opdir ]; then mkdir -p $$opdir; fi &&  \
	$(call fbprint_b,"for config = $1") && if [ ! -f $$opdir/.config ]; then $(MAKE) -C $(UBOOT_TREE) $1 O=$$opdir; fi && \
	$(MAKE) -C $(UBOOT_TREE) -j$(JOBS) O=$$opdir && \
	if echo $1 | grep -iqE 'sdcard|nand'; then \
	   if [ -f $$opdir/u-boot-with-spl-pbl.bin ]; then \
	       srcbin=u-boot-with-spl-pbl.bin; \
	   else \
	       srcbin=u-boot-with-spl.bin; \
	   fi; \
	   if echo $1 | grep -iqE 'SECURE_BOOT'; then \
	       if echo $1 | grep -iqE 'sdcard'; then \
		   cp $$opdir/spl/u-boot-spl.bin $(FBDIR)/build/firmware/u-boot/$$brd/uboot_$${brd}_sdcard_spl.bin ; \
		   cp $$opdir/u-boot-dtb.bin $(FBDIR)/build/firmware/u-boot/$$brd/uboot_$${brd}_sdcard_dtb.bin ; \
	       elif echo $1 | grep -iqE 'nand'; then \
		   cp $$opdir/spl/u-boot-spl.bin $(FBDIR)/build/firmware/u-boot/$$brd/uboot_$${brd}_nand_spl.bin ; \
		   cp $$opdir/u-boot-dtb.bin $(FBDIR)/build/firmware/u-boot/$$brd/uboot_$${brd}_nand_dtb.bin ; \
	       fi; \
	   fi; \
	   tgtbin=uboot_`echo $1|sed -r 's/(.*)(_.*)/\1/'`.bin; \
	else \
	    if echo $1 | grep -qE ^mx; then \
		srcbin=u-boot-dtb.imx; \
		tgtbin=uboot_`echo $1|sed -r 's/(.*)(_.*)/\1/'`.imx; \
	    else \
		srcbin=u-boot$$dtbstr.bin; \
		tgtbin=uboot_`echo $1|sed -r 's/(.*)(_.*)/\1/'`.bin; \
	    fi; \
	fi;  \
	if echo $1 | grep -qE ^imx8; then \
	    flex-builder -c imx_atf -m $(MACHINE); \
	    $(call imx_mkimage_target, $1) \
	    cp $(FBDIR)/packages/firmware/imx_mkimage/$$board_path/flash.bin $(FBDIR)/build/firmware/u-boot/$$brd/$$tgtbin; \
	else \
	    cp $$opdir/$$srcbin $(FBDIR)/build/firmware/u-boot/$$brd/$$tgtbin ; \
	fi; \
	$(call fbprint_d,"$(FBDIR)/build/firmware/u-boot/$$brd/$$tgtbin"); 
endef

define imx_mkimage_target
    if echo $1 | grep -qE ^imx8mm; then \
	board_path="iMX8M"; fdt="fsl-imx8mm-evk.dtb"; target="flash_hdmi_spl_uboot"; \
    elif echo $1 | grep -qE ^imx8mq; then \
	board_path="iMX8M"; fdt="fsl-imx8mq-evk.dtb"; target="flash_hdmi_spl_uboot"; \
    elif echo $1 | grep -qE ^imx8qm; then \
	board_path="iMX8QM"; fdt="fsl-imx8qm-mek.dtb"; target="flash"; \
	cp $(FBDIR)/packages/firmware/linux_firmware_imx/firmware/seco/mx8qm-ahab-container.img \
	$(FBDIR)/packages/firmware/imx_mkimage/$$board_path/mx8qm-ahab-container.img; \
	cp $(FBDIR)/packages/firmware/imx_scfw/imx_4.9.88_imx8qxp_beta2/img/scfw-mx8qm-a0-mek.bin \
	$(FBDIR)/packages/firmware/imx_mkimage/$$board_path/scfw_tcm.bin; \
    elif echo $1 | grep -qE ^imx8qx; then \
	board_path="iMX8QX"; fdt="fsl-imx8qxp-mek.dtb"; target="flash"; \
	cp $(FBDIR)/packages/firmware/linux_firmware_imx/firmware/seco/mx8qx-ahab-container.img \
	$(FBDIR)/packages/firmware/imx_mkimage/$$board_path/mx8qx-ahab-container.img; \
	cp $(FBDIR)/packages/firmware/imx_scfw/imx_4.9.88_imx8qxp_beta2/img/scfw-mx8qx-a0-mek.bin \
	$(FBDIR)/packages/firmware/imx_mkimage/$$board_path/scfw_tcm.bin; \
    fi; \
    plat=`echo ${MACHINE} | cut -c 1-6`; \
    cp -vt $(FBDIR)/packages/firmware/imx_mkimage/$$board_path $$opdir/spl/u-boot-spl.bin \
      $$opdir/u-boot-nodtb.bin $$opdir/u-boot.bin $$opdir/arch/arm/dts/$$fdt \
      $(FBDIR)/packages/firmware/linux_firmware_imx/firmware/ddr/synopsys/lpddr* \
      $(FBDIR)/packages/firmware/linux_firmware_imx/firmware/hdmi/cadence/signed_hdmi_imx8m.bin; \
    cp -v $$opdir/tools/mkimage $(FBDIR)/packages/firmware/imx_mkimage/$$board_path/mkimage_uboot; \
    cp $(FBDIR)/packages/firmware/imx_atf/build/$$plat/release/bl31.bin \
    $(FBDIR)/packages/firmware/imx_mkimage/$$board_path/bl31.bin ;\
    cd $(FBDIR)/packages/firmware/imx_mkimage; \
    $(MAKE)  clean; \
    $(MAKE)  SOC=$$board_path DTBS=$$fdt $$target;
endef

endif


.PHONY: uefi_bin
uefi uefi_bin:
ifeq ($(CONFIG_FW_UEFI_BIN), y)
	@$(call fbprint_b,"UEFI_BIN")
	@$(call fetch-git-tree,uefi_bin)
	@for brd in "$(uefi_machine_list)"; do \
	     mkdir -p $(FBDIR)/build/firmware/uefi/$$brd; \
	     if [ ! -f $(FBDIR)/build/firmware/uefi/$$brd/*RDB_EFI* ]; then \
		cp uefi_bin/$$brd/*.fd $(FBDIR)/build/firmware/uefi/$$brd/; \
	     fi; \
	 done && mkdir -p $(FBDIR)/build/firmware/uefi/grub && \
	 cp uefi_bin/grub/BOOTAA64.EFI $(FBDIR)/build/firmware/uefi/grub && $(call fbprint_d,"UEFI_BIN")
endif


.PHONY: rcw
rcw:
ifeq ($(CONFIG_FW_RCW), y)
	@$(call fbprint_b,"RCW")
	@$(call fetch-git-tree,rcw)
	@mkdir -p $(FBDIR)/build/firmware/rcw
ifeq ($(MACHINE), all)
	@for brd in `find $(RCW_TREE) -maxdepth 1 -type d -name "l*"|cut -d/ -f2`; do \
	     if [ $$brd = ls1088ardb_pb ]; then brd=ls1088ardb; fi && \
	     test -f $(RCW_TREE)/$$brd/Makefile || continue; \
	     $(MAKE) -C $(RCW_TREE)/$$brd && \
	     $(MAKE) -C $(RCW_TREE)/$$brd install DESTDIR=$(FBDIR)/build/firmware/rcw/$$brd; \
	 done
else
	@if [ $(MACHINE) = ls1088ardb_pb ]; then brd=ls1088ardb; else brd=$(MACHINE); fi && \
	 $(MAKE) -C $(RCW_TREE)/$$brd && \
	 $(MAKE) -C $(RCW_TREE)/$$brd install DESTDIR=$(FBDIR)/build/firmware/rcw/$$brd
endif
	@rm -f $(FBDIR)/build/firmware/rcw/*/README && $(call fbprint_d,"RCW")
endif


.PHONY: atf
atf:
ifeq ($(CONFIG_FW_ATF), y)
	@$(call fbprint_b,"ATF")
	@$(call fetch-git-tree,atf)
	@$(call fetch-git-tree,uboot)
	@if [ $(MACHINE) = all ]; then \
	     if [ "$(SECURE)" = "y" ]; then secopt=-s; fi; \
	     for brd in $(LS_MACHINE_LIST); do \
		 if [ $$brd = ls1021atwr ]; then continue; fi; \
		 if [ -z "$(BOOTTYPE)" -o "$(BOOTTYPE)" = all ]; then \
		     for bt in nor qspi sd emmc; do \
			 flex-builder -c atf -m $$brd -b $$bt $$secopt; \
		     done; \
		 else \
		     flex-builder -c atf -m $$brd -b $(BOOTTYPE) $$secopt; \
		 fi; \
	     done; \
	 elif [ -z "$(BOOTTYPE)" -o "$(BOOTTYPE)" = all ]; then \
	     for bt in nor qspi sd emmc; do \
		 flex-builder -c atf -m $(MACHINE) -b $$bt $$secopt; \
	     done; \
	 else \
	     mkdir -p $(FBDIR)/build/firmware/atf/$(MACHINE) && \
	     if [ $(MACHINE) = ls1088ardb_pb ]; then platform=ls1088ardb; else platform=$(MACHINE); fi && \
	     if [ $${platform:0:6} = ls1012 -o $${platform:0:5} = ls104 ]; then \
		 chassistype=ls104x_1012; \
	     else \
		 chassistype=ls2088_1088; \
	     fi && \
	     if [ ! -f $(FBDIR)/configs/board/$(MACHINE)/manifest ]; then \
	         echo $(MACHINE) is not supported! && exit 0; \
	     fi && \
	     if [ "$(SECURE)" = "y" ]; then \
		 if [ $$chassistype = ls104x_1012 ]; then \
		     rcwbin=`grep ^rcw_$(BOOTTYPE)_sec= $(FBDIR)/configs/board/$(MACHINE)/manifest | cut -d= -f2`; \
		 else \
		     rcwbin=`grep ^rcw_$(BOOTTYPE)= $(FBDIR)/configs/board/$(MACHINE)/manifest | cut -d= -f2`; \
		 fi; \
		 if [ $(MACHINE) = lx2160ardb -o $(MACHINE) = lx2160aqds ]; then ddrphyopt=fip_ddr_sec; fi && \
		 if [ ! -f $(FBDIR)/packages/firmware/atf/ddr4_pmu_train_dmem.bin ]; then \
		     flex-builder -c ddr_phy_bin -f $(CONFIGLIST); \
		 fi && \
		 secureopt="TRUSTED_BOARD_BOOT=1 $$ddrphyopt CST_DIR=$(FBDIR)/packages/apps/cst"; \
		 secext=_sec; \
		 if [ ! -f $(FBDIR)/packages/apps/cst/srk.pub ]; then \
		     flex-builder -c cst -f $(CONFIGLIST); \
		 fi && \
		 cp -f $(FBDIR)/packages/apps/cst/srk.* $(FBDIR)/packages/firmware/atf; \
		 ubootcfg=$(FBDIR)/packages/firmware/$(UBOOT_TREE)/configs/$${platform}_tfa_SECURE_BOOT_defconfig; \
		 bl33=$(FBDIR)/build/firmware/u-boot/$$platform/uboot_$${platform}_tfa_SECURE_BOOT.bin; \
	     else \
		 if [ $(BL33TYPE) = uboot ]; then \
		     ubootcfg=$(FBDIR)/packages/firmware/$(UBOOT_TREE)/configs/$${platform}_tfa_defconfig; \
		     bl33=$(FBDIR)/build/firmware/u-boot/$$platform/uboot_$${platform}_tfa.bin; \
		 elif [ $(BL33TYPE) = uefi ]; then \
		     bl33=`grep ^uefi_$(BOOTTYPE) $(FBDIR)/configs/board/$(MACHINE)/manifest | cut -d= -f2`; \
		     if [ -z "$$bl33" ]; then echo uefi_$(BOOTTYPE)boot is not supported; exit; fi; \
		     bl33=$(FBDIR)/$$bl33; \
		 fi; \
		 rcwbin=`grep ^rcw_$(BOOTTYPE)= $(FBDIR)/configs/board/$(MACHINE)/manifest | cut -d= -f2`; \
	     fi && \
	     if [ -z "$$rcwbin" ]; then echo $(MACHINE) $(BOOTTYPE)boot$$secext is not supported && exit 0; fi && \
	     rcwbin=$(FBDIR)/$$rcwbin && \
	     if [ -z "$(BOOTTYPE)" ]; then $(call fbprint_e,"Please specify '-b <boottype>'") && exit 0; fi && \
	     if [ ! -f $$rcwbin ] || `cd $(FBDIR)/packages/firmware/$(RCW_TREE) && git status -s|grep -qiE 'M|A|D' && cd - 1>/dev/null`; then \
		 echo building dependent rcw ...; \
		 flex-builder -c rcw -m $$platform -f $(CONFIGLIST); \
		 test -f $$rcwbin || { $(call fbprint_e,"$$rcwbin not exist"); exit;} \
	     fi && \
	     if [ "$(CONFIG_FUSE_PROVISIONING)" = "y" ]; then \
		 fusefile=$(FBDIR)/packages/apps/cst/fuse_scr.bin && \
		 fuseopt="fip_fuse FUSE_PROG=1 FUSE_PROV_FILE=$$fusefile" && \
		 if [ ! -d $(FBDIR)/packages/apps/cst ]; then flex-builder -c cst -f $(CONFIGLIST); fi && \
		 $(call fbprint_b,"dependent fuse_scr.bin") && \
		 cd $(FBDIR)/packages/apps/cst && ./gen_fusescr input_files/gen_fusescr/$$chassistype/input_fuse_file && cd -; \
	     fi && \
	     if [ "$(CONFIG_APP_EDGESCALE)" = "y" -a $(BOOTTYPE) != sd -a $(BOOTTYPE) != emmc -a $(BOOTTYPE) != nand ]; then otaopt="POLICY_OTA=1"; fi && \
	     if [ "$(CONFIG_APP_OPTEE)" = "y" ]; then \
		 bl32=$(FBDIR)/packages/apps/optee_os/out/arm-plat-ls/core/tee_$$platform.bin; \
		 bl32opt="BL32=$$bl32"; \
		 if [ ! -f $$bl32 ]; then \
		     flex-builder -c optee_os -m $$platform -f $(CONFIGLIST); \
		 fi; \
		 spdopt="SPD=opteed"; \
	     fi && \
	     if [ $(BL33TYPE) = uboot ]; then \
		if [ ! -f $$bl33 ] || `cd $(FBDIR)/packages/firmware/$(UBOOT_TREE) && git status -s|grep -qiE 'M|A|D' && cd - 1>/dev/null`; then \
		    echo building dependent $$bl33 ...; \
		    if [ ! -f $$ubootcfg ]; then \
		        $(call fbprint_e,Please add the dependent $$ubootcfg) && exit; \
		    fi; \
		    flex-builder -c uboot -m $(MACHINE) -b tfa -f $(CONFIGLIST); \
		fi; \
	     elif [ $(BL33TYPE) = uefi ]; then \
		if [ ! -f $$bl33 ]; then \
		    flex-builder -c uefi_bin -m $(MACHINE) -f $(CONFIGLIST); \
		fi; \
	     fi && \
	     if [ -z "$$bl32opt" ]; then echo BL32=NULL as OPTEE is not enabled; fi && \
	     if [ $(BOOTTYPE) = xspi ]; then bootmode=flexspi_nor; else bootmode=$(BOOTTYPE); fi && \
	     echo $(MAKE) -j4 -C atf all fip pbl PLAT=$$platform BOOT_MODE=$$bootmode RCW=$$rcwbin BL33=$$bl33 $$bl32opt $$spdopt $$secureopt $$fuseopt $$otaopt && \
	     $(MAKE) -j4 -C atf realclean && $(MAKE) -C atf all fip pbl PLAT=$$platform \
	     BOOT_MODE=$$bootmode RCW=$$rcwbin BL33=$$bl33 $$bl32opt $$spdopt $$secureopt $$fuseopt $$otaopt && \
	     cp -f atf/build/$$platform/release/bl2_$$bootmode*.pbl $(FBDIR)/build/firmware/atf/$(MACHINE)/ && \
	     cp -f atf/build/$$platform/release/fip.bin $(FBDIR)/build/firmware/atf/$(MACHINE)/fip_$(BL33TYPE)$$secext.bin && \
	     if [ -f atf/fip_ddr_sec.bin ] && [ $(MACHINE) = lx2160ardb -o $(MACHINE) = lx2160aqds ]; then \
	         cp -f atf/fip_ddr_sec.bin $(FBDIR)/build/firmware/atf/$(MACHINE)/; \
	     fi && \
	     if [ "$(CONFIG_FUSE_PROVISIONING)" = "y" ]; then \
		cp -f atf/build/$$platform/release/fuse_fip.bin $(FBDIR)/build/firmware/atf/$(MACHINE)/fuse_fip$$secext.bin; \
	     fi && \
	     if [ $(MACHINE) = ls1012afrwy ]; then \
		 bl32=$(FBDIR)/packages/apps/optee_os/out/arm-plat-ls/core/tee_ls1012afrwy_512mb.bin && bl32opt="BL32=$$bl32" && \
		 $(MAKE) -j4 -C atf realclean && $(MAKE) -C atf all fip pbl PLAT=ls1012afrwy_512mb \
		 BOOT_MODE=$$bootmode RCW=$$rcwbin BL33=$$bl33 $$bl32opt $$spdopt $$secureopt $$fuseopt && \
		 mkdir -p $(FBDIR)/build/firmware/atf/ls1012afrwy_512mb && \
		 cp -f atf/build/ls1012afrwy_512mb/release/bl2_$$bootmode*.pbl $(FBDIR)/build/firmware/atf/ls1012afrwy_512mb/ && \
		 cp -f atf/build/ls1012afrwy_512mb/release/fip.bin $(FBDIR)/build/firmware/atf/ls1012afrwy_512mb/fip_uboot$$secext.bin && \
		 if [ "$(CONFIG_FUSE_PROVISIONING)" = "y" ]; then \
		     cp -f atf/build/ls1012afrwy_512mb/release/fuse_fip.bin $(FBDIR)/build/firmware/atf/ls1012afrwy_512mb/fuse_fip$$secext.bin; \
		 fi; \
	     fi && ls -l $(FBDIR)/build/firmware/atf/$(MACHINE)/* && \
	     $(call fbprint_d,"ATF for $(MACHINE) $${bootmode}boot in $(FBDIR)/build/firmware/atf/$(MACHINE)"); \
	 fi
endif


.PHONY: imx_atf
imx_atf:
ifeq ($(CONFIG_FW_ATF), y)
	@$(call fbprint_b,"imx_atf")
	@$(call fetch-git-tree,imx_atf)
	@plat=`echo ${MACHINE} | cut -c 1-6`; $(MAKE) -C imx_atf PLAT=$$plat; \
	 mkdir -p $(FBDIR)/build/firmware/atf/$(MACHINE) && \
	 cp -f $(FBDIR)/packages/firmware/imx_atf/build/$$plat/release/bl31.bin $(FBDIR)/build/firmware/atf/$(MACHINE)/bl31.bin && \
	 ls -l $(FBDIR)/build/firmware/atf/$(MACHINE)/bl31.bin && $(call fbprint_d,"imx_atf")
endif


.PHONY: mc_utils
mc_utils:
	@$(call fbprint_b,"mc_utils")
	@$(call fetch-git-tree,mc_utils)
	@if [ ! -h $(FBDIR)/build/firmware/mc_utils ]; then \
         ln -s $(FBDIR)/packages/firmware/mc_utils $(FBDIR)/build/firmware/mc_utils; fi
	@$(MAKE) -C mc_utils/config && ls -l $(FBDIR)/build/firmware/mc_utils/config/*/RDB/*.dtb && $(call fbprint_d,"mc_utils")



.PHONY: fm_ucode
fm_ucode:
	@$(call fetch-git-tree,fm_ucode)
	@if [ ! -h $(FBDIR)/build/firmware/fm_ucode ]; then \
	 ln -s $(FBDIR)/packages/firmware/fm_ucode $(FBDIR)/build/firmware/fm_ucode; fi
	@ls -l $(FBDIR)/build/firmware/fm_ucode/*.bin && $(call fbprint_d,"fm_ucode")


.PHONY: qe_ucode
qe_ucode:
	@$(call fetch-git-tree,qe_ucode)
	@if [ ! -h $(FBDIR)/build/firmware/qe_ucode ]; then \
	 ln -s $(FBDIR)/packages/firmware/qe_ucode $(FBDIR)/build/firmware/qe_ucode; fi
	@ls -l $(FBDIR)/build/firmware/qe_ucode/*.bin && $(call fbprint_d,"qe_ucode")


.PHONY: dp_firmware_cadence
dp_firmware_cadence:
	@$(call fetch-git-tree,dp_firmware_cadence)
	@ if [ ! -d $(FBDIR)/packages/firmware/dp_firmware_cadence ]; then \
             curl -R -k -f $(dp_firmware_cadence_bin_url) -o dp_firmware_cadence.bin && chmod +x dp_firmware_cadence.bin && \
             ./dp_firmware_cadence.bin --auto-accept && mv firmware-cadence-* dp_firmware_cadence && rm -f dp_firmware_cadence.bin; \
         fi && \
	 if [ ! -L $(FBDIR)/build/firmware/dp_firmware_cadence ]; then \
	     ln -sf $(FBDIR)/packages/firmware/dp_firmware_cadence $(FBDIR)/build/firmware/dp_firmware_cadence; \
	 fi && \
	 ls -l $(FBDIR)/build/firmware/dp_firmware_cadence/dp/*.bin && $(call fbprint_d,"dp_firmware_cadence")


.PHONY: mc_bin
mc_bin:
	@$(call fetch-git-tree,mc_bin)
	@if [ ! -h $(FBDIR)/build/firmware/mc_bin ]; then \
	 ln -s $(FBDIR)/packages/firmware/mc_bin $(FBDIR)/build/firmware/mc_bin; fi
	@ls -l $(FBDIR)/build/firmware/mc_bin/*/*.itb && $(call fbprint_d,"mc_bin")


.PHONY: phy_cortina
phy_cortina:
	@$(call fetch-git-tree,phy_cortina)
	@if [ ! -h $(FBDIR)/build/firmware/phy_cortina ]; then \
	 ln -s $(FBDIR)/packages/firmware/phy_cortina $(FBDIR)/build/firmware/phy_cortina; fi
	@$(call fbprint_d,"phy_cortina")


.PHONY: phy_inphi
phy_inphi:
	@$(call fetch-git-tree,phy_inphi)
	@if [ ! -h $(FBDIR)/build/firmware/phy_inphi ]; then \
	 ln -s $(FBDIR)/packages/firmware/phy_inphi $(FBDIR)/build/firmware/phy_inphi; fi
	@$(call fbprint_d,"phy_inphi")


.PHONY: pfe_bin
pfe_bin:
	@$(call fetch-git-tree,pfe_bin)
	@if [ ! -h $(FBDIR)/build/firmware/pfe_bin ]; then \
	 ln -s $(FBDIR)/packages/firmware/pfe_bin $(FBDIR)/build/firmware/pfe_bin; fi
	@ls -l $(FBDIR)/build/firmware/pfe_bin/ls1012a/*/ && $(call fbprint_d,"pfe_bin")


.PHONY: ddr_phy_bin
ddr_phy_bin:
	@$(call fetch-git-tree,ddr_phy_bin)
	@$(call fetch-git-tree,atf)
	@if [ ! -f $(FBDIR)/packages/firmware/atf/tools/fiptool/fiptool ]; then \
	     $(MAKE) -C $(FBDIR)/packages/firmware/atf fiptool; \
	 fi && \
	 if [ ! -f $(FBDIR)/build/firmware/ddr_phy_bin/fip_ddr_all.bin ]; then \
	     ln -sf $(FBDIR)/packages/firmware/ddr_phy_bin $(FBDIR)/build/firmware/ddr_phy_bin; \
	     cd ddr_phy_bin/lx2160a && $(FBDIR)/packages/firmware/atf/tools/fiptool/fiptool create \
	     --ddr-immem-udimm-1d ddr4_pmu_train_imem.bin \
	     --ddr-immem-udimm-2d ddr4_2d_pmu_train_imem.bin \
	     --ddr-dmmem-udimm-1d ddr4_pmu_train_dmem.bin \
	     --ddr-dmmem-udimm-2d ddr4_2d_pmu_train_dmem.bin \
	     --ddr-immem-rdimm-1d ddr4_rdimm_pmu_train_imem.bin \
	     --ddr-immem-rdimm-2d ddr4_rdimm2d_pmu_train_imem.bin \
	     --ddr-dmmem-rdimm-1d ddr4_rdimm_pmu_train_dmem.bin \
	     --ddr-dmmem-rdimm-2d ddr4_rdimm2d_pmu_train_dmem.bin \
	     $(FBDIR)/build/firmware/ddr_phy_bin/fip_ddr_all.bin && \
	     cp -f *.bin $(FBDIR)/packages/firmware/atf/ && \
	     cd - && ls -l $(FBDIR)/build/firmware/ddr_phy_bin/fip_ddr_all.bin; \
	 fi && $(call fbprint_d,"ddr_phy_bin")


repo_fetch:
	@echo -e "\nfetch firmware repositories ..."
	@$(call repo-update,fetch,$(FIRMWARE_REPO_LIST))

repo_update_branch:
	@echo -e "\nfirmware repositories update for branch ..."
	@$(call repo-update,branch,$(FIRMWARE_REPO_LIST))

repo_update_tag:
	@echo -e "\nfirmware repositories update for tag ..."
	@$(call repo-update,tag,$(FIRMWARE_REPO_LIST))

repo_update_latest:
	@echo -e "\nfirmware repositories update to latest HEAD commit ..."
	@$(call repo-update,update,$(FIRMWARE_REPO_LIST))

repo_update_commit:
	@echo -e "\nfirmware repositories update to specified commit ID ..."
	@$(call repo-update,commit,$(FIRMWARE_REPO_LIST))
