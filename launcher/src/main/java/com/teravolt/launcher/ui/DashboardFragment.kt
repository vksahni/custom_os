package com.teravolt.launcher.ui

import android.os.Bundle
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import androidx.fragment.app.Fragment
import androidx.lifecycle.ViewModelProvider
import androidx.recyclerview.widget.GridLayoutManager
import com.teravolt.launcher.databinding.FragmentDashboardBinding
import com.teravolt.launcher.viewmodel.DashboardViewModel
import com.teravolt.launcher.adapter.DashboardCardAdapter
import com.teravolt.launcher.model.DashboardCard

/**
 * Dashboard Fragment - Main dashboard display
 */
class DashboardFragment : Fragment() {

    private lateinit var binding: FragmentDashboardBinding
    private lateinit var viewModel: DashboardViewModel
    private lateinit var cardAdapter: DashboardCardAdapter

    override fun onCreateView(
        inflater: LayoutInflater,
        container: ViewGroup?,
        savedInstanceState: Bundle?
    ): View {
        binding = FragmentDashboardBinding.inflate(inflater, container, false)
        return binding.root
    }

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)

        viewModel = ViewModelProvider(this).get(DashboardViewModel::class.java)

        // Setup RecyclerView for dashboard cards
        cardAdapter = DashboardCardAdapter()
        binding.dashboardGrid.apply {
            layoutManager = GridLayoutManager(context, 2)
            adapter = cardAdapter
        }

        // Observe dashboard cards
        viewModel.dashboardCards.observe(viewLifecycleOwner) { cards ->
            cardAdapter.submitList(cards)
        }

        // Observe system metrics
        viewModel.systemMetrics.observe(viewLifecycleOwner) { metrics ->
            binding.cpuUsage.text = "CPU: ${metrics.cpuUsage}%"
            binding.memoryUsage.text = "Memory: ${metrics.memoryUsage}%"
            binding.temperature.text = "Temp: ${metrics.temperature}°C"
        }

        // Load dashboard data
        viewModel.loadDashboard()
    }
}
