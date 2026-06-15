package com.teravolt.launcher

import android.os.Bundle
import android.view.WindowManager
import androidx.appcompat.app.AppCompatActivity
import androidx.core.splashscreen.SplashScreen.Companion.installSplashScreen
import androidx.lifecycle.ViewModelProvider
import androidx.viewpager2.adapter.FragmentStateAdapter
import androidx.viewpager2.widget.ViewPager2
import com.google.android.material.tabs.TabLayoutMediator
import com.teravolt.launcher.databinding.ActivityMainBinding
import com.teravolt.launcher.ui.DashboardFragment
import com.teravolt.launcher.ui.DeviceInfoFragment
import com.teravolt.launcher.ui.QuickControlsFragment
import com.teravolt.launcher.viewmodel.LauncherViewModel

/**
 * TeraVolt Launcher - Main Activity
 * Industrial dashboard home screen with device controls and monitoring.
 */
class MainActivity : AppCompatActivity() {

    private lateinit var binding: ActivityMainBinding
    private lateinit var viewModel: LauncherViewModel
    private lateinit var pagerAdapter: MainPagerAdapter

    override fun onCreate(savedInstanceState: Bundle?) {
        // Install splash screen
        installSplashScreen()

        super.onCreate(savedInstanceState)

        // Initialize binding
        binding = ActivityMainBinding.inflate(layoutInflater)
        setContentView(binding.root)

        // Keep screen on (industrial use case)
        window.addFlags(WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON)

        // Initialize ViewModel
        viewModel = ViewModelProvider(this).get(LauncherViewModel::class.java)

        // Setup ViewPager2 with fragments
        setupViewPager()

        // Setup UI observers
        setupObservers()

        // Setup toolbar
        setSupportActionBar(binding.toolbar)
    }

    /**
     * Setup ViewPager2 with dashboard fragments
     */
    private fun setupViewPager() {
        pagerAdapter = MainPagerAdapter(this)
        binding.viewPager.adapter = pagerAdapter
        binding.viewPager.offscreenPageLimit = 3

        // Connect TabLayout with ViewPager2
        TabLayoutMediator(binding.tabLayout, binding.viewPager) { tab, position ->
            tab.text = when (position) {
                0 -> "Dashboard"
                1 -> "Device Info"
                2 -> "Quick Controls"
                else -> "Unknown"
            }
        }.attach()

        binding.viewPager.registerOnPageChangeCallback(
            object : ViewPager2.OnPageChangeCallback() {
                override fun onPageSelected(position: Int) {
                    super.onPageSelected(position)
                    viewModel.setCurrentPage(position)
                }
            }
        )
    }

    /**
     * Setup ViewModel observers
     */
    private fun setupObservers() {
        viewModel.systemStatus.observe(this) { status ->
            binding.statusText.text = "Status: ${status.state}"
        }

        viewModel.errorMessage.observe(this) { message ->
            if (message != null) {
                showError(message)
            }
        }

        viewModel.isLoading.observe(this) { isLoading ->
            binding.progressBar.visibility = if (isLoading) android.view.View.VISIBLE else android.view.View.GONE
        }
    }

    /**
     * Show error message
     */
    private fun showError(message: String) {
        com.google.android.material.snackbar.Snackbar.make(binding.root, message, 3000).show()
    }

    override fun onStart() {
        super.onStart()
        viewModel.startServiceConnections()
    }

    override fun onStop() {
        viewModel.stopServiceConnections()
        super.onStop()
    }

    /**
     * ViewPager2 Adapter for main fragments
     */
    private inner class MainPagerAdapter(activity: AppCompatActivity) : FragmentStateAdapter(activity) {
        override fun getItemCount(): Int = 3

        override fun createFragment(position: Int) = when (position) {
            0 -> DashboardFragment()
            1 -> DeviceInfoFragment()
            2 -> QuickControlsFragment()
            else -> DashboardFragment()
        }
    }
}
