# TeraVolt OS GUI Implementation

Complete Android application implementation for TeraVolt OS user interface, including Launcher and Settings apps.

## Overview

This implementation provides two main Android applications for the TeraVolt OS:

### 1. **TeraVolt Launcher** (Industrial Dashboard)
Location: `launcher/`

A home screen application providing:
- **Dashboard Tab**: System metrics (CPU, memory, temperature), hardware status cards
- **Device Info Tab**: System information, hardware interfaces status
- **Quick Controls Tab**: Fast access buttons for:
  - MQTT connection toggle
  - CAN interface enable/disable
  - Serial console access
  - AI inference execution
  - OTA update checks
  - System reboot

**Features:**
- Tab-based navigation (ViewPager2 + TabLayout)
- RecyclerView for dashboard cards
- LiveData-based MVVM architecture
- Material Design 3 components
- Smooth animations and transitions

### 2. **TeraVolt Settings** (Configuration App)
Location: `settings/`

A settings application providing:
- **Device Information**: Device name, model, build version
- **Serial Port Configuration**: Enable/disable, baud rate selection
- **CAN Bus Configuration**: Enable/disable, bitrate selection (125/250/500/1000 kbps)
- **MQTT Configuration**: Broker address, port, enable/disable
- **AI Configuration**: Model selection, enable/disable
- **OTA Configuration**: Auto-update checking, manual update checks
- **Network Tools**: Network information, connectivity testing

**Features:**
- PreferenceFragmentCompat for settings UI
- Hierarchical preferences with categories
- Easy service configuration
- Material Design consistent styling

## Project Structure

### Launcher App

```
launcher/
├── src/main/
│   ├── AndroidManifest.xml          # App manifest
│   ├── java/com/teravolt/launcher/
│   │   ├── MainActivity.kt          # Main activity (ViewPager + TabLayout)
│   │   ├── ui/
│   │   │   ├── DashboardFragment.kt    # Dashboard tab
│   │   │   ├── DeviceInfoFragment.kt   # Device info tab
│   │   │   └── QuickControlsFragment.kt # Controls tab
│   │   ├── viewmodel/
│   │   │   ├── LauncherViewModel.kt    # Main ViewModel
│   │   │   ├── DashboardViewModel.kt   # Dashboard ViewModel
│   │   │   ├── DeviceInfoViewModel.kt  # Device info ViewModel
│   │   │   └── QuickControlsViewModel.kt # Controls ViewModel
│   │   ├── model/
│   │   │   └── Models.kt            # Data models
│   │   ├── adapter/
│   │   │   └── DashboardCardAdapter.kt # RecyclerView adapter
│   │   └── service/
│   │       └── ServiceClients.kt    # TeraVolt service clients
│   ├── res/
│   │   ├── layout/
│   │   │   ├── activity_main.xml       # Main activity layout
│   │   │   ├── fragment_dashboard.xml  # Dashboard layout
│   │   │   ├── fragment_device_info.xml
│   │   │   ├── fragment_quick_controls.xml
│   │   │   └── item_dashboard_card.xml # Card item layout
│   │   ├── values/
│   │   │   ├── strings.xml
│   │   │   └── colors.xml
│   │   └── xml/
│   │       └── dashboard_widget_info.xml
│   └── build.gradle.kts             # Gradle build config
```

### Settings App

```
settings/
├── src/main/
│   ├── AndroidManifest.xml          # App manifest
│   ├── java/com/teravolt/settings/
│   │   └── SettingsActivity.kt      # Main settings activity
│   ├── res/
│   │   ├── layout/
│   │   │   └── activity_settings.xml
│   │   ├── values/
│   │   │   ├── strings.xml
│   │   │   └── colors.xml
│   │   └── xml/
│   │       └── root_preferences.xml # Preference hierarchy
│   └── build.gradle.kts             # Gradle build config
```

## Build Configuration

### Launcher build.gradle.kts

```kotlin
// Android Configuration
android {
    namespace = "com.teravolt.launcher"
    compileSdk = 35
    minSdk = 30
    targetSdk = 35
}

// Key Dependencies
- androidx.appcompat:appcompat (base app compat)
- androidx.core:core-ktx (Kotlin extensions)
- androidx.fragment:fragment-ktx (Fragment support)
- androidx.lifecycle:lifecycle-* (MVVM architecture)
- androidx.viewpager2:viewpager2 (Tab navigation)
- com.google.android.material:material (Material Design 3)
- androidx.compose.* (Optional: Jetpack Compose)
```

### Settings build.gradle.kts

```kotlin
// Android Configuration
android {
    namespace = "com.teravolt.settings"
    compileSdk = 35
    minSdk = 30
    targetSdk = 35
}

// Key Dependencies
- androidx.appcompat:appcompat
- androidx.preference:preference-ktx (PreferenceFragment)
- androidx.lifecycle:lifecycle-*
- com.google.android.material:material
```

## Data Models

### Launcher Models

```kotlin
data class SystemStatus(
    val state: String,          // "Ready", "Busy", etc.
    val message: String
)

data class DashboardCard(
    val title: String,          // "Serial Monitor"
    val subtitle: String,       // "UART/RS485"
    val status: String          // "Active", "Connected"
)

data class SystemMetrics(
    val cpuUsage: Int,          // 0-100%
    val memoryUsage: Int,       // 0-100%
    val temperature: Int        // Celsius
)

data class DeviceInfo(
    val productName: String,    // "TeraVolt OS ARM64"
    val productModel: String,
    val serialNumber: String,
    val buildVersion: String,
    val androidVersion: String,
    val kernelVersion: String
)

data class HardwareStatus(
    val serialAvailable: Boolean,
    val canAvailable: Boolean,
    val mqttAvailable: Boolean,
    val gpioAvailable: Boolean
)
```

## UI Components

### Launcher UI

**MainActivity**
- Toolbar with app title
- Status bar showing current system state
- TabLayout with 3 tabs
- ViewPager2 for fragment navigation
- Progress indicator for loading

**DashboardFragment**
- System metrics display (CPU, Memory, Temperature)
- GridLayout RecyclerView with dashboard cards
- Each card shows: title, subtitle, status indicator

**DeviceInfoFragment**
- ScrollView with device information
- Card sections for device specs
- Hardware interface status indicators

**QuickControlsFragment**
- GridLayout with 6 control buttons
- Real-time state display
- Status information section

### Settings UI

**SettingsActivity**
- Toolbar with navigation
- PreferenceFragmentCompat container

**root_preferences.xml**
- Device Information category
- Serial Port Configuration category
- CAN Bus Configuration category
- MQTT Broker Configuration category
- AI Inference Configuration category
- OTA Update Configuration category
- Network Tools category

## MVVM Architecture

### ViewModels

```
LauncherViewModel
├── systemStatus: LiveData<SystemStatus>
├── errorMessage: LiveData<String?>
├── isLoading: LiveData<Boolean>
└── currentPage: LiveData<Int>

DashboardViewModel
├── dashboardCards: LiveData<List<DashboardCard>>
└── systemMetrics: LiveData<SystemMetrics>

DeviceInfoViewModel
├── deviceInfo: LiveData<DeviceInfo>
└── hardwareStatus: LiveData<HardwareStatus>

QuickControlsViewModel
├── mqttConnected: LiveData<Boolean>
├── canEnabled: LiveData<Boolean>
└── ... control state LiveDatas
```

### Fragment Architecture

Each fragment:
1. Inflates its layout using View Binding
2. Creates/retrieves ViewModel via ViewModelProvider
3. Observes LiveData from ViewModel
4. Updates UI reactively when data changes
5. Handles user interactions and calls ViewModel methods

## Service Integration

### TeraVolt Service Permissions

```xml
<!-- Launcher Permissions -->
com.teravolt.permission.ACCESS_MQTT_SERVICE
com.teravolt.permission.ACCESS_CAN_SERVICE
com.teravolt.permission.ACCESS_SERIAL_SERVICE
com.teravolt.permission.ACCESS_AI_SERVICE
com.teravolt.permission.ACCESS_MONITOR_SERVICE
com.teravolt.permission.ACCESS_OTA_SERVICE

<!-- Settings Permissions (Configuration) -->
com.teravolt.permission.CONFIGURE_MQTT_SERVICE
com.teravolt.permission.CONFIGURE_CAN_SERVICE
com.teravolt.permission.CONFIGURE_SERIAL_SERVICE
com.teravolt.permission.CONFIGURE_AI_SERVICE
com.teravolt.permission.CONFIGURE_OTA_SERVICE
```

### Service Client Pattern

```kotlin
// Example: MQTT Service Client
class MQTTServiceClient {
    private var mqttService: IMQTTService? = null
    private val connection = object : ServiceConnection {
        override fun onServiceConnected(name: ComponentName?, service: IBinder?) {
            mqttService = IMQTTService.Stub.asInterface(service)
        }
        override fun onServiceDisconnected(name: ComponentName?) {
            mqttService = null
        }
    }
    
    fun connect() = mqttService?.connect()
    fun disconnect() = mqttService?.disconnect()
}
```

## Build Instructions

### Building the Apps

```bash
# Build launcher app
cd launcher
gradle assembleDebug        # Debug APK
gradle assembleRelease      # Release APK

# Build settings app
cd ../settings
gradle assembleDebug        # Debug APK
gradle assembleRelease      # Release APK
```

### Integrating into TeraVolt Build

Add to `vendor/teravolt/teravolt_vendor.mk`:

```makefile
PRODUCT_PACKAGES += \
    TeraVoltLauncher \
    TeraVoltSettings

PRODUCT_COPY_FILES += \
    packages/apps/TeraVoltLauncher/config/launcher-permissions.xml:$(TARGET_COPY_OUT_SYSTEM)/etc/permissions/
```

## Testing

### Unit Tests

```bash
# Launcher tests
cd launcher
gradle test

# Settings tests
cd settings
gradle test
```

### UI Tests (Instrumented)

```bash
# Run on device/emulator
gradle connectedAndroidTest
```

### Manual Testing

1. **Launcher**
   - Launch app → verify all 3 tabs load
   - Dashboard tab → check card display
   - Device Info tab → verify info accuracy
   - Quick Controls tab → test button functions

2. **Settings**
   - Launch app → verify preference hierarchy
   - Modify settings → check persistence
   - Test service integration with TeraVolt services

## Customization

### Theming

Modify `values/colors.xml`:
```xml
<color name="primary">#1976D2</color>
<color name="background_primary">#FAFAFA</color>
```

### Adding New Dashboard Cards

```kotlin
// In DashboardViewModel
val newCard = DashboardCard(
    title = "New Service",
    subtitle = "Service Details",
    status = "Active"
)
```

### Adding New Settings Preference

```xml
<!-- In root_preferences.xml -->
<EditTextPreference
    android:key="new_setting"
    android:title="New Setting"
    android:defaultValue="value" />
```

## Next Steps

1. **Implement Service Clients**: Connect to actual TeraVolt platform services via Binder
2. **Add Fragments**: Create detailed configuration fragments for each subsystem
3. **Implement Service Bindings**: Wire up real service communication
4. **Add Theming**: Implement dark mode and custom themes
5. **Enhance UI**: Add animations, better graphics, industrial styling
6. **Permissions**: Implement proper permission handling and checks
7. **Error Handling**: Comprehensive error handling and user feedback

## References

- [Android Architecture Guide](https://developer.android.com/architecture)
- [MVVM Pattern](https://developer.android.com/codelabs/android-mvvm)
- [ViewPager2 Documentation](https://developer.android.com/guide/topics/ui/layout/viewpager)
- [PreferenceFragment Guide](https://developer.android.com/guide/topics/ui/settings)
- [Material Design 3](https://m3.material.io/)
