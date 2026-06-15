#
# Reference BoardConfig.
# Replace these values with board-specific boot, partition, kernel, and HAL data.
#

TARGET_ARCH := arm64
TARGET_ARCH_VARIANT := armv8-a
TARGET_CPU_VARIANT := generic
TARGET_CPU_ABI := arm64-v8a

TARGET_NO_BOOTLOADER := true
TARGET_NO_KERNEL := true

BOARD_USES_GENERIC_KERNEL_IMAGE := true
BOARD_BUILD_SYSTEM_ROOT_IMAGE := false

BOARD_FLASH_BLOCK_SIZE := 4096
BOARD_SYSTEMIMAGE_PARTITION_SIZE := 2147483648
BOARD_VENDORIMAGE_PARTITION_SIZE := 536870912
BOARD_PRODUCTIMAGE_PARTITION_SIZE := 536870912

BOARD_SEPOLICY_DIRS += \
    vendor/teravolt/sepolicy/public \
    vendor/teravolt/sepolicy/private
