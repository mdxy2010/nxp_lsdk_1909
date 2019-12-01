#####################################
#
# Copyright 2017 NXP
#
# SPDX-License-Identifier:      BSD-3-Clause
#
#####################################

ifndef FBDIR
  FBDIR = $(shell cd "$(dirname "${BASH_SOURCE[0]}" )" && pwd)
endif

include $(FBDIR)/configs/$(CONFIGLIST)

all:
	@$(MAKE) -C $(FBDIR)/packages

$(FIRMWARE_REPO_LIST) bin_firmware imx_atf:
	@$(MAKE) -C $(FBDIR)/packages/firmware $@

$(LINUX_ALL_LIST):
	@$(MAKE) -C $(FBDIR)/packages/linux $@

$(APPS_ALL_LIST) misc:
	@$(MAKE) -C $(FBDIR)/packages/apps $@

firmware apps:
	@$(MAKE) -C $(FBDIR)/packages/$@

initrd:
	@$(MAKE) -C $(FBDIR)/packages/rfs $@
