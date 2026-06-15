#
# Common vendor additions for TeraVolt OS products.
#

PRODUCT_SOONG_NAMESPACES += \
    vendor/teravolt

PRODUCT_COPY_FILES += \
    vendor/teravolt/config/privapp-permissions-teravolt.xml:$(TARGET_COPY_OUT_SYSTEM)/etc/permissions/privapp-permissions-teravolt.xml

PRODUCT_SYSTEM_PROPERTIES += \
    ro.teravolt.security.selinux_required=true \
    ro.teravolt.ota.required=true
