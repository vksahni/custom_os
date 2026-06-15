#
# Reference ARM64 product for early TeraVolt OS platform integration.
#

$(call inherit-product, $(SRC_TARGET_DIR)/product/generic_system.mk)
$(call inherit-product, vendor/teravolt/teravolt_vendor.mk)

PRODUCT_NAME := teravolt_arm64
PRODUCT_DEVICE := teravolt_arm64
PRODUCT_BRAND := TeraVolt
PRODUCT_MODEL := TeraVolt OS ARM64 Reference
PRODUCT_MANUFACTURER := TeraVolt

PRODUCT_SYSTEM_PROPERTIES += \
    ro.teravolt.os.name=TeraVoltOS \
    ro.teravolt.os.profile=reference \
    ro.teravolt.hardware.serial=true \
    ro.teravolt.hardware.can=true \
    ro.teravolt.hardware.mqtt=true \
    ro.teravolt.ai.edge=true
