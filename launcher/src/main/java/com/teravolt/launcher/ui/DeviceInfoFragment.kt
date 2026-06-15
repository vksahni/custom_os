package com.teravolt.launcher.ui

import android.os.Bundle
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import androidx.fragment.app.Fragment
import androidx.lifecycle.ViewModelProvider
import com.teravolt.launcher.databinding.FragmentDeviceInfoBinding
import com.teravolt.launcher.viewmodel.DeviceInfoViewModel

/**
 * Device Info Fragment - Displays system information
 */
class DeviceInfoFragment : Fragment() {

    private lateinit var binding: FragmentDeviceInfoBinding
    private lateinit var viewModel: DeviceInfoViewModel

    override fun onCreateView(
        inflater: LayoutInflater,
        container: ViewGroup?,
        savedInstanceState: Bundle?
    ): View {
        binding = FragmentDeviceInfoBinding.inflate(inflater, container, false)
        return binding.root
    }

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)

        viewModel = ViewModelProvider(this).get(DeviceInfoViewModel::class.java)

        // Observe device info
        viewModel.deviceInfo.observe(viewLifecycleOwner) { info ->
            binding.productName.text = "Device: ${info.productName}"
            binding.productModel.text = "Model: ${info.productModel}"
            binding.serialNumber.text = "Serial: ${info.serialNumber}"
            binding.buildVersion.text = "Build: ${info.buildVersion}"
            binding.androidVersion.text = "Android: ${info.androidVersion}"
            binding.kernelVersion.text = "Kernel: ${info.kernelVersion}"
        }

        // Observe hardware status
        viewModel.hardwareStatus.observe(viewLifecycleOwner) { status ->
            binding.serialStatus.text = "Serial: ${if (status.serialAvailable) "✓" else "✗"}"
            binding.canStatus.text = "CAN: ${if (status.canAvailable) "✓" else "✗"}"
            binding.mqttStatus.text = "MQTT: ${if (status.mqttAvailable) "✓" else "✗"}"
            binding.gpioStatus.text = "GPIO: ${if (status.gpioAvailable) "✓" else "✗"}"
        }

        // Load device info
        viewModel.loadDeviceInfo()
    }
}
