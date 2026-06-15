package com.teravolt.launcher.viewmodel

import androidx.lifecycle.LiveData
import androidx.lifecycle.MutableLiveData
import androidx.lifecycle.ViewModel
import com.teravolt.launcher.model.DeviceInfo
import com.teravolt.launcher.model.HardwareStatus

/**
 * Device Info ViewModel - Manages device information
 */
class DeviceInfoViewModel : ViewModel() {

    private val _deviceInfo = MutableLiveData<DeviceInfo>()
    val deviceInfo: LiveData<DeviceInfo> = _deviceInfo

    private val _hardwareStatus = MutableLiveData<HardwareStatus>()
    val hardwareStatus: LiveData<HardwareStatus> = _hardwareStatus

    fun loadDeviceInfo() {
        _deviceInfo.value = DeviceInfo(
            productName = "TeraVolt OS ARM64",
            productModel = "Reference Platform",
            serialNumber = "TV-ARM64-001",
            buildVersion = "1.0.0",
            androidVersion = "15.0.0_r1",
            kernelVersion = "Generic ARM64"
        )

        _hardwareStatus.value = HardwareStatus(
            serialAvailable = true,
            canAvailable = true,
            mqttAvailable = true,
            gpioAvailable = true
        )
    }
}
