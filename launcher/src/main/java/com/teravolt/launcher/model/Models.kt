package com.teravolt.launcher.model

// System Status
data class SystemStatus(
    val state: String,
    val message: String
)

// Dashboard Card
data class DashboardCard(
    val title: String,
    val subtitle: String,
    val status: String
)

// System Metrics
data class SystemMetrics(
    val cpuUsage: Int,
    val memoryUsage: Int,
    val temperature: Int
)

// Device Information
data class DeviceInfo(
    val productName: String,
    val productModel: String,
    val serialNumber: String,
    val buildVersion: String,
    val androidVersion: String,
    val kernelVersion: String
)

// Hardware Status
data class HardwareStatus(
    val serialAvailable: Boolean,
    val canAvailable: Boolean,
    val mqttAvailable: Boolean,
    val gpioAvailable: Boolean
)
