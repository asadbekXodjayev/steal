# STEEL-Mobile Phase 0 Setup Script for Windows
# Run in PowerShell: .\setup-phase0.ps1

Write-Host "==========================================" -ForegroundColor Cyan
Write-Host "STEEL-Mobile Phase 0 Setup" -ForegroundColor Cyan
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host ""

# Check if running from STEEL-Mobile directory
if (-not (Test-Path "STEEL-iOS") -or -not (Test-Path "STEEL-Android")) {
    Write-Host "Error: Please run this script from the STEEL-Mobile directory" -ForegroundColor Red
    exit 1
}

# ==========================================
# iOS Setup
# ==========================================
Write-Host "🍎 Setting up iOS project..." -ForegroundColor Green

Push-Location STEEL-iOS

# Create Info.plist
$infoPlist = @'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleDevelopmentRegion</key>
    <string>$(DEVELOPMENT_LANGUAGE)</string>
    <key>CFBundleExecutable</key>
    <string>$(EXECUTABLE_NAME)</string>
    <key>CFBundleIdentifier</key>
    <string>$(PRODUCT_BUNDLE_IDENTIFIER)</string>
    <key>CFBundleInfoDictionaryVersion</key>
    <string>6.0</string>
    <key>CFBundleName</key>
    <string>$(PRODUCT_NAME)</string>
    <key>CFBundlePackageType</key>
    <string>$(PRODUCT_BUNDLE_PACKAGE_TYPE)</string>
    <key>CFBundleShortVersionString</key>
    <string>1.0</string>
    <key>CFBundleVersion</key>
    <string>1</string>
    <key>LSRequiresIPhoneOS</key>
    <true/>
    <key>UIApplicationSceneManifest</key>
    <dict>
        <key>UIApplicationSupportsMultipleScenes</key>
        <false/>
    </dict>
    <key>UILaunchScreen</key>
    <dict/>
    <key>UIRequiredDeviceCapabilities</key>
    <array>
        <string>armv7</string>
    </array>
    <key>UISupportedInterfaceOrientations</key>
    <array>
        <string>UIInterfaceOrientationPortrait</string>
    </array>
    <key>UIStatusBarStyle</key>
    <string>UIStatusBarStyleLightContent</string>
    <key>UIViewControllerBasedStatusBarAppearance</key>
    <false/>
</dict>
</plist>
'@
Set-Content -Path "STEEL-iOS/Info.plist" -Value $infoPlist -Encoding UTF8
Write-Host "  ✓ Info.plist created" -ForegroundColor Gray

# Create AppDelegate.swift
$appDelegate = @'
import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        return true
    }
    
    func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
        return .portrait
    }
}
'@
Set-Content -Path "STEEL-iOS/AppDelegate.swift" -Value $appDelegate -Encoding UTF8
Write-Host "  ✓ AppDelegate.swift created" -ForegroundColor Gray

# Create STEELApp.swift
$steelApp = @'
import SwiftUI

@main
struct STEELApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .preferredColorScheme(.dark)
        }
    }
}
'@
Set-Content -Path "STEEL-iOS/STEELApp.swift" -Value $steelApp -Encoding UTF8
Write-Host "  ✓ STEELApp.swift created" -ForegroundColor Gray

# Create ContentView.swift
$ContentView = @'
import SwiftUI

struct ContentView: View {
    var body: some View {
        VStack {
            Image(systemName: "dumbbell.fill")
                .font(.system(size: 48))
                .foregroundColor(.red)
            
            Text("STEEL")
                .font(.system(size: 32, weight: .bold))
                .tracking(4)
                .foregroundColor(.white)
            
            Text("FORGES STEEL")
                .font(.system(size: 14, weight: .semibold))
                .tracking(6)
                .foregroundColor(.orange)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.black)
    }
}

#Preview {
    ContentView()
}
'@
Set-Content -Path "STEEL-iOS/ContentView.swift" -Value $ContentView -Encoding UTF8
Write-Host "  ✓ ContentView.swift created" -ForegroundColor Gray

# Create Assets directories
New-Item -ItemType Directory -Force -Path "STEEL-iOS/Assets.xcassets/AppIcon.appiconset" | Out-Null
New-Item -ItemType Directory -Force -Path "STEEL-iOS/Assets.xcassets/AccentColor.colorset" | Out-Null
New-Item -ItemType Directory -Force -Path "STEEL-iOS/Assets.xcassets/Colors.colorset" | Out-Null

# Create Assets JSON files
$assetsContents = '{"info":{"author":"xcode","version":1}}'
Set-Content -Path "STEEL-iOS/Assets.xcassets/Contents.json" -Value $assetsContents -Encoding UTF8

$appIconContents = @"
{
  "images" : [
    {
      "idiom" : "universal",
      "platform" : "ios",
      "size" : "1024x1024"
    }
  ],
  "info" : {
    "author" : "xcode",
    "version" : 1
  }
}
"@
Set-Content -Path "STEEL-iOS/Assets.xcassets/AppIcon.appiconset/Contents.json" -Value $appIconContents -Encoding UTF8

$accentColorContents = @"
{
  "colors" : [
    {
      "color" : {
        "color-space" : "srgb",
        "components" : {
          "alpha" : "1.000",
          "blue" : "0.000",
          "green" : "0.000",
          "red" : "0.545"
        }
      },
      "idiom" : "universal"
    }
  ],
  "info" : {
    "author" : "xcode",
    "version" : 1
  }
}
"@
Set-Content -Path "STEEL-iOS/Assets.xcassets/AccentColor.colorset/Contents.json" -Value $accentColorContents -Encoding UTF8

$colorsContents = @"
{
  "colors" : [
    {
      "color" : {
        "color-space" : "srgb",
        "components" : {
          "alpha" : "1.000",
          "blue" : "0.020",
          "green" : "0.020",
          "red" : "0.020"
        }
      },
      "idiom" : "universal"
    }
  ],
  "info" : {
    "author" : "xcode",
    "version" : 1
  }
}
"@
Set-Content -Path "STEEL-iOS/Assets.xcassets/Colors.colorset/Contents.json" -Value $colorsContents -Encoding UTF8

Write-Host "  ✓ Assets created" -ForegroundColor Gray

# Create Models directory
New-Item -ItemType Directory -Force -Path "STEEL-iOS/Models" | Out-Null

Pop-Location

Write-Host "✅ iOS setup complete!" -ForegroundColor Green
Write-Host ""

# ==========================================
# Android Setup
# ==========================================
Write-Host "🤖 Setting up Android project..." -ForegroundColor Green

Push-Location STEEL-Android

# Create settings.gradle.kts
$settingsGradle = @'
pluginManagement {
    repositories {
        google()
        mavenCentral()
        gradlePluginPortal()
    }
}

dependencyResolutionManagement {
    repositoriesMode.set(RepositoriesMode.FAIL_ON_PROJECT_REPOS)
    repositories {
        google()
        mavenCentral()
    }
}

rootProject.name = "STEEL-Android"
include(":app")
'@
Set-Content -Path "settings.gradle.kts" -Value $settingsGradle -Encoding UTF8
Write-Host "  ✓ settings.gradle.kts created" -ForegroundColor Gray

# Create root build.gradle.kts
$rootBuildGradle = @'
plugins {
    id("com.android.application") version "8.2.0" apply false
    id("org.jetbrains.kotlin.android") version "2.0.21" apply false
    id("org.jetbrains.kotlin.plugin.compose") version "2.0.21" apply false
}
'@
Set-Content -Path "build.gradle.kts" -Value $rootBuildGradle -Encoding UTF8
Write-Host "  ✓ build.gradle.kts created" -ForegroundColor Gray

# Create gradle.properties
$gradleProps = @'
org.gradle.jvmargs=-Xmx2048m -Dfile.encoding=UTF-8
android.useAndroidX=true
kotlin.code.style=official
android.nonTransitiveRClass=true
'@
Set-Content -Path "gradle.properties" -Value $gradleProps -Encoding UTF8
Write-Host "  ✓ gradle.properties created" -ForegroundColor Gray

# Create app/build.gradle.kts
$appBuildGradle = @'
plugins {
    id("com.android.application")
    id("org.jetbrains.kotlin.android")
    id("org.jetbrains.kotlin.plugin.compose")
    id("kotlin-kapt")
    kotlin("plugin.serialization") version "2.0.21"
}

android {
    namespace = "com.steel.steel"
    compileSdk = 34

    defaultConfig {
        applicationId = "com.steel.steel"
        minSdk = 24
        targetSdk = 34
        versionCode = 1
        versionName = "1.0"

        testInstrumentationRunner = "androidx.test.runner.AndroidJUnitRunner"
        vectorDrawables {
            useSupportLibrary = true
        }
    }

    buildTypes {
        release {
            isMinifyEnabled = false
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )
        }
    }
    
    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }
    
    kotlinOptions {
        jvmTarget = "17"
    }
    
    buildFeatures {
        compose = true
        buildConfig = true
    }
    
    composeOptions {
        kotlinCompilerExtensionVersion = "1.5.14"
    }
    
    packaging {
        resources {
            excludes += "/META-INF/{AL2.0,LGPL2.1}"
        }
    }
}

dependencies {
    // Core Android
    implementation("androidx.core:core-ktx:1.13.1")
    implementation("androidx.lifecycle:lifecycle-runtime-ktx:2.8.7")
    implementation("androidx.activity:activity-compose:1.9.3")
    
    // Compose
    implementation(platform("androidx.compose:compose-bom:2024.10.01"))
    implementation("androidx.compose.ui:ui")
    implementation("androidx.compose.ui:ui-graphics")
    implementation("androidx.compose.ui:ui-tooling-preview")
    implementation("androidx.compose.material3:material3")
    
    // Navigation
    implementation("androidx.navigation:navigation-compose:2.8.4")
    
    // ViewModel
    implementation("androidx.lifecycle:lifecycle-viewmodel-compose:2.8.7")
    
    // Room
    implementation("androidx.room:room-runtime:2.6.1")
    implementation("androidx.room:room-ktx:2.6.1")
    kapt("androidx.room:room-compiler:2.6.1")
    
    // Coroutines
    implementation("org.jetbrains.kotlinx:kotlinx-coroutines-android:1.9.0")
    
    // Serialization
    implementation("org.jetbrains.kotlinx:kotlinx-serialization-json:1.7.3")
    
    // Testing
    testImplementation("junit:junit:4.13.2")
    androidTestImplementation("androidx.test.ext:junit:1.2.1")
    androidTestImplementation("androidx.test.espresso:espresso-core:3.6.1")
    androidTestImplementation(platform("androidx.compose:compose-bom:2024.10.01"))
    androidTestImplementation("androidx.compose.ui:ui-test-junit4")
    debugImplementation("androidx.compose.ui:ui-tooling")
    debugImplementation("androidx.compose.ui:ui-test-manifest")
}
'@
New-Item -ItemType Directory -Force -Path "app" | Out-Null
Set-Content -Path "app/build.gradle.kts" -Value $appBuildGradle -Encoding UTF8
Write-Host "  ✓ app/build.gradle.kts created" -ForegroundColor Gray

# Create AndroidManifest.xml
New-Item -ItemType Directory -Force -Path "app/src/main" | Out-Null
$manifest = @'
<?xml version="1.0" encoding="utf-8"?>
<manifest xmlns:android="http://schemas.android.com/apk/res/android"
    xmlns:tools="http://schemas.android.com/tools">

    <uses-permission android:name="android.permission.INTERNET" />
    <uses-permission android:name="android.permission.ACCESS_NETWORK_STATE" />

    <application
        android:allowBackup="true"
        android:dataExtractionRules="@xml/data_extraction_rules"
        android:fullBackupContent="@xml/backup_rules"
        android:icon="@mipmap/ic_launcher"
        android:label="@string/app_name"
        android:roundIcon="@mipmap/ic_launcher_round"
        android:supportsRtl="true"
        android:theme="@style/Theme.STEELAndroid"
        tools:targetApi="31">
        <activity
            android:name=".MainActivity"
            android:exported="true"
            android:theme="@style/Theme.STEELAndroid">
            <intent-filter>
                <action android:name="android.intent.action.MAIN" />
                <category android:name="android.intent.category.LAUNCHER" />
            </intent-filter>
        </activity>
    </application>

</manifest>
'@
Set-Content -Path "app/src/main/AndroidManifest.xml" -Value $manifest -Encoding UTF8
Write-Host "  ✓ AndroidManifest.xml created" -ForegroundColor Gray

# Create resource directories and files
New-Item -ItemType Directory -Force -Path "app/src/main/res/values" | Out-Null
New-Item -ItemType Directory -Force -Path "app/src/main/res/xml" | Out-Null

$stringsXml = @'
<resources>
    <string name="app_name">STEEL</string>
</resources>
'@
Set-Content -Path "app/src/main/res/values/strings.xml" -Value $stringsXml -Encoding UTF8

$themesXml = @'
<?xml version="1.0" encoding="utf-8"?>
<resources>
    <style name="Theme.STEELAndroid" parent="android:Theme.Material.Light.NoActionBar">
        <item name="android:statusBarColor">@android:color/black</item>
        <item name="android:navigationBarColor">@android:color/black</item>
    </style>
</resources>
'@
Set-Content -Path "app/src/main/res/values/themes.xml" -Value $themesXml -Encoding UTF8

$extractionRules = @'
<?xml version="1.0" encoding="utf-8"?>
<data-extraction-rules>
    <cloud-backup>
        <include domain="sharedpref" path="."/>
        <exclude domain="sharedpref" path="device.xml"/>
    </cloud-backup>
</data-extraction-rules>
'@
Set-Content -Path "app/src/main/res/xml/data_extraction_rules.xml" -Value $extractionRules -Encoding UTF8

$backupRules = @'
<?xml version="1.0" encoding="utf-8"?>
<full-backup-content>
    <include domain="sharedpref" path="."/>
    <exclude domain="sharedpref" path="device.xml"/>
</full-backup-content>
'@
Set-Content -Path "app/src/main/res/xml/backup_rules.xml" -Value $backupRules -Encoding UTF8

# Create Java source directories
New-Item -ItemType Directory -Force -Path "app/src/main/java/com/steel/steel/models" | Out-Null
New-Item -ItemType Directory -Force -Path "app/src/main/java/com/steel/steel/ui/theme" | Out-Null

Pop-Location

Write-Host "✅ Android setup complete!" -ForegroundColor Green
Write-Host ""

# ==========================================
# Summary
# ==========================================
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host "Phase 0 Setup Complete!" -ForegroundColor Cyan
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "📱 iOS Project: STEEL-iOS/STEEL-iOS.xcodeproj" -ForegroundColor White
Write-Host "🤖 Android Project: STEEL-Android/" -ForegroundColor White
Write-Host ""
Write-Host "Next steps:" -ForegroundColor Yellow
Write-Host "1. Open iOS in Xcode (on macOS): open STEEL-iOS/STEEL-iOS.xcodeproj" -ForegroundColor White
Write-Host "2. Open Android in Android Studio: File > Open > STEEL-Android" -ForegroundColor White
Write-Host "3. Build Android: ./gradlew assembleDebug" -ForegroundColor White
Write-Host "4. Commit to GitHub for Codemagic: git add . && git commit -m 'Phase 0: Initial setup' && git push" -ForegroundColor White
Write-Host ""