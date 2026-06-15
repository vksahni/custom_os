package com.teravolt.settings

import android.os.Bundle
import androidx.appcompat.app.AppCompatActivity
import androidx.preference.Preference
import androidx.preference.PreferenceFragmentCompat
import androidx.preference.PreferenceManager
import com.teravolt.settings.databinding.ActivitySettingsBinding

/**
 * TeraVolt Settings - Main Settings Activity
 * Configuration interface for TeraVolt OS hardware and services.
 */
class SettingsActivity : AppCompatActivity() {

    private lateinit var binding: ActivitySettingsBinding

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        binding = ActivitySettingsBinding.inflate(layoutInflater)
        setContentView(binding.root)

        // Setup toolbar
        setSupportActionBar(binding.toolbar)
        supportActionBar?.setDisplayHomeAsUpEnabled(true)

        // Load settings fragment
        if (savedInstanceState == null) {
            supportFragmentManager
                .beginTransaction()
                .replace(R.id.settings_container, SettingsFragment())
                .commit()
        }
    }

    override fun onSupportNavigateUp(): Boolean {
        onBackPressedDispatcher.onBackPressed()
        return true
    }

    /**
     * Main Settings Fragment
     */
    class SettingsFragment : PreferenceFragmentCompat() {
        override fun onCreatePreferences(savedInstanceState: Bundle?, rootKey: String?) {
            setPreferencesFromResource(R.xml.root_preferences, rootKey)

            // Setup preference listeners
            findPreference<Preference>("serial_config")?.apply {
                onPreferenceClickListener = Preference.OnPreferenceClickListener {
                    // Handle serial configuration
                    true
                }
            }

            findPreference<Preference>("can_config")?.apply {
                onPreferenceClickListener = Preference.OnPreferenceClickListener {
                    // Handle CAN configuration
                    true
                }
            }

            findPreference<Preference>("mqtt_config")?.apply {
                onPreferenceClickListener = Preference.OnPreferenceClickListener {
                    // Handle MQTT configuration
                    true
                }
            }

            findPreference<Preference>("ai_config")?.apply {
                onPreferenceClickListener = Preference.OnPreferenceClickListener {
                    // Handle AI configuration
                    true
                }
            }

            findPreference<Preference>("ota_config")?.apply {
                onPreferenceClickListener = Preference.OnPreferenceClickListener {
                    // Handle OTA configuration
                    true
                }
            }
        }
    }
}
