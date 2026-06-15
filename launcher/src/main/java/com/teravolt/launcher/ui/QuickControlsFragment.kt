package com.teravolt.launcher.ui

import android.os.Bundle
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import androidx.fragment.app.Fragment
import androidx.lifecycle.ViewModelProvider
import com.teravolt.launcher.databinding.FragmentQuickControlsBinding
import com.teravolt.launcher.viewmodel.QuickControlsViewModel

/**
 * Quick Controls Fragment - Fast access to common functions
 */
class QuickControlsFragment : Fragment() {

    private lateinit var binding: FragmentQuickControlsBinding
    private lateinit var viewModel: QuickControlsViewModel

    override fun onCreateView(
        inflater: LayoutInflater,
        container: ViewGroup?,
        savedInstanceState: Bundle?
    ): View {
        binding = FragmentQuickControlsBinding.inflate(inflater, container, false)
        return binding.root
    }

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)

        viewModel = ViewModelProvider(this).get(QuickControlsViewModel::class.java)

        // Setup control buttons
        binding.btnMqttConnect.setOnClickListener {
            viewModel.toggleMQTTConnection()
        }

        binding.btnCanInterface.setOnClickListener {
            viewModel.toggleCANInterface()
        }

        binding.btnSerialConsole.setOnClickListener {
            viewModel.openSerialConsole()
        }

        binding.btnAiInference.setOnClickListener {
            viewModel.runAIInference()
        }

        binding.btnCheckUpdates.setOnClickListener {
            viewModel.checkOTAUpdates()
        }

        binding.btnReboot.setOnClickListener {
            viewModel.requestReboot()
        }

        // Observe control states
        viewModel.mqttConnected.observe(viewLifecycleOwner) { connected ->
            binding.btnMqttConnect.text = if (connected) "Disconnect MQTT" else "Connect MQTT"
            binding.btnMqttConnect.setTextColor(
                resources.getColor(if (connected) android.R.color.holo_green_dark else android.R.color.holo_red_dark)
            )
        }

        viewModel.canEnabled.observe(viewLifecycleOwner) { enabled ->
            binding.btnCanInterface.text = if (enabled) "Disable CAN" else "Enable CAN"
        }

        // Load initial states
        viewModel.loadControlStates()
    }
}
