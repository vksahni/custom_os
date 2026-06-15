package com.teravolt.launcher.viewmodel

import androidx.lifecycle.LiveData
import androidx.lifecycle.MutableLiveData
import androidx.lifecycle.ViewModel
import com.teravolt.launcher.model.DashboardCard
import com.teravolt.launcher.model.SystemMetrics

/**
 * Dashboard ViewModel - Manages dashboard state
 */
class DashboardViewModel : ViewModel() {

    private val _dashboardCards = MutableLiveData<List<DashboardCard>>()
    val dashboardCards: LiveData<List<DashboardCard>> = _dashboardCards

    private val _systemMetrics = MutableLiveData<SystemMetrics>()
    val systemMetrics: LiveData<SystemMetrics> = _systemMetrics

    fun loadDashboard() {
        // Mock data
        val cards = listOf(
            DashboardCard("Serial Monitor", "UART/RS485", "Active"),
            DashboardCard("CAN Interface", "500 kbps", "Connected"),
            DashboardCard("MQTT Broker", "192.168.1.100", "Connected"),
            DashboardCard("AI Inference", "Model Loaded", "Ready"),
            DashboardCard("Device Monitor", "All Sensors", "Operational"),
            DashboardCard("OTA Updates", "Latest Build", "Up to Date")
        )
        _dashboardCards.value = cards

        _systemMetrics.value = SystemMetrics(
            cpuUsage = 15,
            memoryUsage = 42,
            temperature = 45
        )
    }
}
