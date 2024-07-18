# Copyright (C) 2016 The Pure Nexus Project
# Copyright (C) 2016 The JDCTeam
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

ARROW_MOD_VERSION = v13.1
ARROW_BUILD_TYPE := EXTENDED
ARROW_BUILD_ZIP_TYPE := VANILLA

ifeq ($(ARROW_BETA),true)
    ARROW_BUILD_TYPE := BETA
endif

ifeq ($(ARROW_GAPPS), true)
    $(call inherit-product, vendor/gapps/common/common-vendor.mk)
    ARROW_BUILD_ZIP_TYPE := GAPPS
endif

CURRENT_DEVICE=$(shell echo "$(TARGET_PRODUCT)" | cut -d'_' -f 2,3)

ifeq ($(ARROW_OFFICIAL), true)
   LIST = $(shell cat infrastructure/devices/arrow.devices | awk '$$1 != "#" { print $$2 }')
    ifeq ($(filter $(CURRENT_DEVICE), $(LIST)), $(CURRENT_DEVICE))
      IS_OFFICIAL=true
      ARROW_BUILD_TYPE := OFFICIAL

PRODUCT_PACKAGES += \
    Updater

    endif
    ifneq ($(IS_OFFICIAL), true)
       ARROW_BUILD_TYPE := EXTENDED
       $(error Device is not official "$(CURRENT_DEVICE)")
    endif
endif

ifeq ($(ARROW_COMMUNITY), true)
   LIST = $(shell cat infrastructure/devices/arrow-community.devices | awk '$$1 != "#" { print $$2 }')
    ifeq ($(filter $(CURRENT_DEVICE), $(LIST)), $(CURRENT_DEVICE))
      IS_COMMUNITY=true
      ARROW_BUILD_TYPE := COMMUNITY
    endif
    ifneq ($(IS_COMMUNITY), true)
       ARROW_BUILD_TYPE := EXTENDED
       $(error This isn't a community device "$(CURRENT_DEVICE)")
    endif
endif

# Signing
ifneq (eng,$(TARGET_BUILD_VARIANT))
ifneq (,$(wildcard vendor/arrow/signing/keys/releasekey.pk8))
PRODUCT_DEFAULT_DEV_CERTIFICATE := vendor/arrow/signing/keys/releasekey
PRODUCT_DEFAULT_PROPERTY_OVERRIDES += ro.oem_unlock_supported=1
endif
ifneq (,$(wildcard vendor/arrow/signing/keys/otakey.x509.pem))
PRODUCT_OTA_PUBLIC_KEYS := vendor/arrow/signing/keys/otakey.x509.pem
endif
endif

ARROW_VERSION := Arrow-$(ARROW_MOD_VERSION)-$(CURRENT_DEVICE)-$(ARROW_BUILD_TYPE)-$(shell date -u +%Y%m%d)-$(ARROW_BUILD_ZIP_TYPE)

PRODUCT_SYSTEM_DEFAULT_PROPERTIES += \
  ro.arrow.version=$(ARROW_VERSION) \
  ro.arrow.releasetype=$(ARROW_BUILD_TYPE) \
  ro.arrow.ziptype=$(ARROW_BUILD_ZIP_TYPE) \
  ro.modversion=$(ARROW_MOD_VERSION)

ARROW_DISPLAY_VERSION := Arrow-$(ARROW_MOD_VERSION)-$(ARROW_BUILD_TYPE)

PRODUCT_SYSTEM_DEFAULT_PROPERTIES += \
  ro.arrow.display.version=$(ARROW_DISPLAY_VERSION)
