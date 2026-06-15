package com.teravolt.launcher.viewmodel

import androidx.lifecycle.LiveData
import androidx.lifecycle.MutableLiveData
import androidx.lifecycle.ViewModel
import com.teravolt.launcher.model.SystemStatus

/**
 * Launcher ViewModel - Manages main launcher UI state
 */
class LauncherViewModel : ViewModel() {

    private val _systemStatus = MutableLiveData<SystemStatus>()
    val systemStatus: LiveData<SystemStatus> = _systemStatus

    private val _errorMessage = MutableLiveData<String?>()
    val errorMessage: LiveData<String?> = _errorMessage

    private val _isLoading = MutableLiveData<Boolean>()
    val isLoading: LiveData<Boolean> = _isLoading

    private val _currentPage = MutableLiveData<Int>()
    val currentPage: LiveData<Int> = _currentPage

    fun startServiceConnections() {
        _isLoading.value = true
        // TODO: Connect to TeraVolt services
        _systemStatus.value = SystemStatus("Ready", "System initialized")
        _isLoading.value = false
    }

    fun stopServiceConnections() {
        // TODO: Disconnect from TeraVolt services
    }

    fun setCurrentPage(page: Int) {
        _currentPage.value = page
    }

    fun reportError(message: String) {
        _errorMessage.value = message
    }

    fun clearError() {
        _errorMessage.value = null
    }
}
