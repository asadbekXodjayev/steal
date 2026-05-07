#!/bin/bash
# STEEL-Mobile Phase 0 Setup Script
# Run this script to initialize both iOS and Android projects

set -e  # Exit on error

echo "=========================================="
echo "STEEL-Mobile Phase 0 Setup"
echo "=========================================="
echo ""

# Check if we're in the right directory
if [ ! -d "STEEL-iOS" ] || [ ! -d "STEEL-Android" ]; then
    echo "Error: Please run this script from the STEEL-Mobile directory"
    exit 1
fi

# ==========================================
# iOS Setup
# ==========================================
echo "🍎 Setting up iOS project..."

cd STEEL-iOS

# Create Info.plist
cat > STEEL-iOS/Info.plist << 'PLIST_EOF'
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
PLIST_EOF

echo "  ✓ Info.plist created"

# Create AppDelegate.swift
cat > STEEL-iOS/AppDelegate.swift << 'APPDELEGATE_EOF'
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
APPDELEGATE_EOF

echo "  ✓ AppDelegate.swift created"

# Create STEELApp.swift
cat > STEEL-iOS/STEELApp.swift << 'SWIFTAPP_EOF'
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
SWIFTAPP_EOF

echo "  ✓ STEELApp.swift created"

# Create ContentView.swift
cat > STEEL-iOS/ContentView.swift << 'CONTENTVIEW_EOF'
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
CONTENTVIEW_EOF

echo "  ✓ ContentView.swift created"

# Create Assets
mkdir -p STEEL-iOS/Assets.xcassets/AppIcon.appiconset
mkdir -p STEEL-iOS/Assets.xcassets/AccentColor.colorset
mkdir -p STEEL-iOS/Assets.xcassets/Colors.colorset

cat > STEEL-iOS/Assets.xcassets/Contents.json << 'ASSETS_EOF'
{
  "info" : {
    "author" : "xcode",
    "version" : 1
  }
}
ASSETS_EOF

cat > STEEL-iOS/Assets.xcassets/AppIcon.appiconset/Contents.json << 'APPICON_EOF'
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
APPICON_EOF

cat > STEEL-iOS/Assets.xcassets/AccentColor.colorset/Contents.json << 'ACCENT_EOF'
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
ACCENT_EOF

cat > STEEL-iOS/Assets.xcassets/Colors.colorset/Contents.json << 'COLORS_EOF'
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
COLORS_EOF

echo "  ✓ Assets created"

# Create Xcode project file
cat > STEEL-iOS.xcodeproj/project.pbxproj << 'XCODEPROJ_EOF'
// !$*UTF8*$!
{
	archiveVersion = 1;
	classes = {
	};
	objectVersion = 56;
	objects = {

/* Begin PBXBuildFile section */
		1A000001 /* STEELApp.swift in Sources */ = {isa = PBXBuildFile; fileRef = 2A000001; };
		1A000002 /* AppDelegate.swift in Sources */ = {isa = PBXBuildFile; fileRef = 2A000002; };
		1A000003 /* ContentView.swift in Sources */ = {isa = PBXBuildFile; fileRef = 2A000003; };
		1A000004 /* Assets.xcassets in Resources */ = {isa = PBXBuildFile; fileRef = 2A000004; };
/* End PBXBuildFile section */

/* Begin PBXFileReference section */
		2A000001 /* STEELApp.swift */ = {isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = STEELApp.swift; sourceTree = "<group>"; };
		2A000002 /* AppDelegate.swift */ = {isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = AppDelegate.swift; sourceTree = "<group>"; };
		2A000003 /* ContentView.swift */ = {isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = ContentView.swift; sourceTree = "<group>"; };
		2A000004 /* Assets.xcassets */ = {isa = PBXFileReference; lastKnownFileType = folder.assetcatalog; path = Assets.xcassets; sourceTree = "<group>"; };
		2A000005 /* Info.plist */ = {isa = PBXFileReference; lastKnownFileType = text.plist.xml; path = Info.plist; sourceTree = "<group>"; };
		3A000001 /* STEEL-iOS.app */ = {isa = PBXFileReference; explicitFileType = wrapper.application; includeInIndex = 0; path = "STEEL-iOS.app"; sourceTree = BUILT_PRODUCTS_DIR; };
/* End PBXFileReference section */

/* Begin PBXFrameworksBuildPhase section */
		4A000001 /* Frameworks */ = {
			isa = PBXFrameworksBuildPhase;
			buildActionMask = 2147483647;
			files = (
			);
			runOnlyForDeploymentPostprocessing = 0;
		};
/* End PBXFrameworksBuildPhase section */

/* Begin PBXGroup section */
		5A000001 = {
			isa = PBXGroup;
			children = (
				5A000002 /* STEEL-iOS */,
				5A000003 /* Products */,
			);
			sourceTree = "<group>";
		};
		5A000002 /* STEEL-iOS */ = {
			isa = PBXGroup;
			children = (
				2A000001 /* STEELApp.swift */,
				2A000002 /* AppDelegate.swift */,
				2A000003 /* ContentView.swift */,
				2A000004 /* Assets.xcassets */,
				2A000005 /* Info.plist */,
			);
			path = STEEL-iOS;
			sourceTree = "<group>";
		};
		5A000003 /* Products */ = {
			isa = PBXGroup;
			children = (
				3A000001 /* STEEL-iOS.app */,
			);
			name = Products;
			sourceTree = "<group>";
		};
/* End PBXGroup section */

/* Begin PBXNativeTarget section */
		6A000001 /* STEEL-iOS */ = {
			isa = PBXNativeTarget;
			buildConfigurationList = 8A000001;
			buildPhases = (
				7A000001 /* Sources */,
				4A000001 /* Frameworks */,
				9A000001 /* Resources */,
			);
			buildRules = (
			);
			dependencies = (
			);
			name = "STEEL-iOS";
			productName = "STEEL-iOS";
			productReference = 3A000001;
			productType = "com.apple.product-type.application";
		};
/* End PBXNativeTarget section */

/* Begin PBXProject section */
		5A000000 /* Project object */ = {
			isa = PBXProject;
			attributes = {
				BuildIndependentTargetsInParallel = 1;
				LastSwiftUpdateCheck = 1500;
				LastUpgradeCheck = 1500;
			};
			buildConfigurationList = 8A000002;
			compatibilityVersion = "Xcode 14.0";
			developmentRegion = en;
			hasScannedForEncodings = 0;
			knownRegions = (
				en,
				Base,
			);
			mainGroup = 5A000001;
			productRefGroup = 5A000003;
			projectDirPath = "";
			projectRoot = "";
			targets = (
				6A000001,
			);
		};
/* End PBXProject section */

/* Begin PBXResourcesBuildPhase section */
		9A000001 /* Resources */ = {
			isa = PBXResourcesBuildPhase;
			buildActionMask = 2147483647;
			files = (
				1A000004,
			);
			runOnlyForDeploymentPostprocessing = 0;
		};
/* End PBXResourcesBuildPhase section */

/* Begin PBXSourcesBuildPhase section */
		7A000001 /* Sources */ = {
			isa = PBXSourcesBuildPhase;
			buildActionMask = 2147483647;
			files = (
				1A000001,
				1A000002,
				1A000003,
			);
			runOnlyForDeploymentPostprocessing = 0;
		};
/* End PBXSourcesBuildPhase section */

/* Begin XCBuildConfiguration section */
		8A000003 /* Debug */ = {
			isa = XCBuildConfiguration;
			buildSettings = {
				ALWAYS_SEARCH_USER_PATHS = NO;
				CLANG_ENABLE_MODULES = YES;
				CLANG_ENABLE_OBJC_ARC = YES;
				COPY_PHASE_STRIP = NO;
				DEBUG_INFORMATION_FORMAT = dwarf;
				ENABLE_STRICT_OBJC_MSGSEND = YES;
				ENABLE_TESTABILITY = YES;
				GCC_OPTIMIZATION_LEVEL = 0;
				IPHONEOS_DEPLOYMENT_TARGET = 16.0;
				MTL_ENABLE_DEBUG_INFO = INCLUDE_SOURCE;
				SDKROOT = iphoneos;
				SWIFT_ACTIVE_COMPILATION_CONDITIONS = DEBUG;
				SWIFT_OPTIMIZATION_LEVEL = "-Onone";
			};
			name = Debug;
		};
		8A000004 /* Release */ = {
			isa = XCBuildConfiguration;
			buildSettings = {
				ALWAYS_SEARCH_USER_PATHS = NO;
				CLANG_ENABLE_MODULES = YES;
				CLANG_ENABLE_OBJC_ARC = YES;
				COPY_PHASE_STRIP = NO;
				DEBUG_INFORMATION_FORMAT = "dwarf-with-dsym";
				ENABLE_NS_ASSERTIONS = NO;
				IPHONEOS_DEPLOYMENT_TARGET = 16.0;
				MTL_ENABLE_DEBUG_INFO = NO;
				SDKROOT = iphoneos;
				SWIFT_COMPILATION_MODE = wholemodule;
				VALIDATE_PRODUCT = YES;
			};
			name = Release;
		};
		8A000005 /* Debug */ = {
			isa = XCBuildConfiguration;
			buildSettings = {
				ASSETCATALOG_COMPILER_APPICON_NAME = AppIcon;
				CODE_SIGN_STYLE = Automatic;
				CURRENT_PROJECT_VERSION = 1;
				GENERATE_INFOPLIST_FILE = NO;
				INFOPLIST_FILE = STEEL-iOS/Info.plist;
				LD_RUNPATH_SEARCH_PATHS = (
					"$(inherited)",
					"@executable_path/Frameworks",
				);
				MARKETING_VERSION = 1.0;
				PRODUCT_BUNDLE_IDENTIFIER = com.steel.ios;
				PRODUCT_NAME = "$(TARGET_NAME)";
				SWIFT_EMIT_LOC_STRINGS = YES;
				SWIFT_VERSION = 5.9;
				TARGETED_DEVICE_FAMILY = 1;
			};
			name = Debug;
		};
		8A000006 /* Release */ = {
			isa = XCBuildConfiguration;
			buildSettings = {
				ASSETCATALOG_COMPILER_APPICON_NAME = AppIcon;
				CODE_SIGN_STYLE = Automatic;
				CURRENT_PROJECT_VERSION = 1;
				GENERATE_INFOPLIST_FILE = NO;
				INFOPLIST_FILE = STEEL-iOS/Info.plist;
				LD_RUNPATH_SEARCH_PATHS = (
					"$(inherited)",
					"@executable_path/Frameworks",
				);
				MARKETING_VERSION = 1.0;
				PRODUCT_BUNDLE_IDENTIFIER = com.steel.ios;
				PRODUCT_NAME = "$(TARGET_NAME)";
				SWIFT_EMIT_LOC_STRINGS = YES;
				SWIFT_VERSION = 5.9;
				TARGETED_DEVICE_FAMILY = 1;
			};
			name = Release;
		};
/* End XCBuildConfiguration section */

/* Begin XCConfigurationList section */
		8A000001 /* Build configuration list for PBXNativeTarget */ = {
			isa = XCConfigurationList;
			buildConfigurations = (
				8A000005,
				8A000006,
			);
			defaultConfigurationIsVisible = 0;
		};
		8A000002 /* Build configuration list for PBXProject */ = {
			isa = XCConfigurationList;
			buildConfigurations = (
				8A000003,
				8A000004,
			);
			defaultConfigurationIsVisible = 0;
		};
/* End XCConfigurationList section */
	};
	rootObject = 5A000000;
}
XCODEPROJ_EOF

echo "  ✓ Xcode project created"

cd ..
echo "✅ iOS setup complete!"
echo ""

# ==========================================
# Android Setup
# ==========================================
echo "🤖 Setting up Android project..."

cd STEEL-Android

# Create settings.gradle.kts
cat > settings.gradle.kts << 'SETTINGS_EOF'
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
SETTINGS_EOF

echo "  ✓ settings.gradle.kts created"

# Create root build.gradle.kts
cat > build.gradle.kts << 'ROOTBUILD_EOF'
plugins {
    id("com.android.application") version "8.2.0" apply false
    id("org.jetbrains.kotlin.android") version "2.0.21" apply false
    id("org.jetbrains.kotlin.plugin.compose") version "2.0.21" apply false
}
ROOTBUILD_EOF

echo "  ✓ build.gradle.kts created"

# Create gradle.properties
cat > gradle.properties << 'GRADLEPROP_EOF'
org.gradle.jvmargs=-Xmx2048m -Dfile.encoding=UTF-8
android.useAndroidX=true
kotlin.code.style=official
android.nonTransitiveRClass=true
GRADLEPROP_EOF

echo "  ✓ gradle.properties created"

# Create app/build.gradle.kts
cat > app/build.gradle.kts << 'APPBUILD_EOF'
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
APPBUILD_EOF

echo "  ✓ app/build.gradle.kts created"

# Create AndroidManifest.xml
mkdir -p app/src/main

cat > app/src/main/AndroidManifest.xml << 'MANIFEST_EOF'
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
MANIFEST_EOF

echo "  ✓ AndroidManifest.xml created"

# Create resource directories
mkdir -p app/src/main/res/values
mkdir -p app/src/main/res/xml
mkdir -p app/src/main/res/mipmap-hdpi
mkdir -p app/src/main/res/mipmap-mdpi
mkdir -p app/src/main/res/mipmap-xhdpi
mkdir -p app/src/main/res/mipmap-xxhdpi
mkdir -p app/src/main/res/mipmap-xxxhdpi

# Create strings.xml
cat > app/src/main/res/values/strings.xml << 'STRINGS_EOF'
<resources>
    <string name="app_name">STEEL</string>
</resources>
STRINGS_EOF

echo "  ✓ strings.xml created"

# Create themes.xml
cat > app/src/main/res/values/themes.xml << 'THEMES_EOF'
<?xml version="1.0" encoding="utf-8"?>
<resources>
    <style name="Theme.STEELAndroid" parent="android:Theme.Material.Light.NoActionBar">
        <item name="android:statusBarColor">@android:color/black</item>
        <item name="android:navigationBarColor">@android:color/black</item>
    </style>
</resources>
THEMES_EOF

echo "  ✓ themes.xml created"

# Create data_extraction_rules.xml
cat > app/src/main/res/xml/data_extraction_rules.xml << 'EXTRACTION_EOF'
<?xml version="1.0" encoding="utf-8"?>
<data-extraction-rules>
    <cloud-backup>
        <include domain="sharedpref" path="."/>
        <exclude domain="sharedpref" path="device.xml"/>
    </cloud-backup>
</data-extraction-rules>
EXTRACTION_EOF

echo "  ✓ data_extraction_rules.xml created"

# Create backup_rules.xml
cat > app/src/main/res/xml/backup_rules.xml << 'BACKUP_EOF'
<?xml version="1.0" encoding="utf-8"?>
<full-backup-content>
    <include domain="sharedpref" path="."/>
    <exclude domain="sharedpref" path="device.xml"/>
</full-backup-content>
BACKUP_EOF

echo "  ✓ backup_rules.xml created"

# Create MainActivity.kt
mkdir -p app/src/main/java/com/steel/steel

cat > app/src/main/java/com/steel/steel/MainActivity.kt << 'MAINACTIVITY_EOF'
package com.steel.steel

import android.os.Bundle
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.compose.foundation.background
import androidx.compose.foundation.layout.*
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Surface
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.steel.steel.ui.theme.STEELAndroidTheme

class MainActivity : ComponentActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContent {
            STEELAndroidTheme {
                Surface(
                    modifier = Modifier.fillMaxSize(),
                    color = Color(0xFF050505)
                ) {
                    AppContent()
                }
            }
        }
    }
}

@Composable
fun AppContent() {
    Column(
        modifier = Modifier
            .fillMaxSize()
            .background(Color(0xFF050505)),
        horizontalAlignment = Alignment.CenterHorizontally,
        verticalArrangement = Arrangement.Center
    ) {
        Text(
            text = "💪",
            fontSize = 48.sp
        )
        Spacer(modifier = Modifier.height(16.dp))
        Text(
            text = "STEEL",
            fontSize = 32.sp,
            fontWeight = FontWeight.Bold,
            color = Color(0xFF8B0000),
            letterSpacing = 4.sp
        )
        Spacer(modifier = Modifier.height(8.dp))
        Text(
            text = "FORGES STEEL",
            fontSize = 14.sp,
            fontWeight = FontWeight.SemiBold,
            color = Color(0xFFC2410C),
            letterSpacing = 6.sp
        )
    }
}
MAINACTIVITY_EOF

echo "  ✓ MainActivity.kt created"

# Create Color.kt
cat > app/src/main/java/com/steel/steel/ui/theme/Color.kt << 'COLORKOTLIN_EOF'
package com.steel.steel.ui.theme

import androidx.compose.ui.graphics.Color

// Core Backgrounds
val Background = Color(0xFF050505)
val BackgroundSecondary = Color(0xFF0A0A0A)
val Foreground = Color(0xFFE5E5E5)

// Cards
val Card = Color(0xFF0A0A0A)
val CardForeground = Color(0xFFE5E5E5)
val CardBorder = Color(0xFF1A1A1A)

// Primary (Blood Red)
val Primary = Color(0xFF8B0000)
val PrimaryHover = Color(0xFF9F1239)
val PrimaryActive = Color(0xFFB91C1C)

// Secondary (Forged Steel Orange)
val Secondary = Color(0xFFC2410C)
val SecondaryHover = Color(0xFFEA580C)
val SecondaryActive = Color(0xFFF97316)

// Muted
val Muted = Color(0xFF1A1A1A)
val MutedForeground = Color(0xFFA1A1AA)

// Tactical (Military Green)
val Tactical = Color(0xFF166534)
val TacticalHover = Color(0xFF15803D)

// Ink (Text hierarchy)
val InkHigh = Color(0xFFE5E5E5)
val InkMid = Color(0xFFC9C9C9)
val InkLow = Color(0xFFA1A1AA)
val InkDim = Color(0xFF737373)

// Surfaces
val Surface0 = Color(0xFF050505)
val Surface1 = Color(0xFF0A0A0A)
val Surface2 = Color(0xFF111111)
val Surface3 = Color(0xFF171717)
val Surface4 = Color(0xFF1F1F1F)
COLORKOTLIN_EOF

echo "  ✓ Color.kt created"

# Create Theme.kt
cat > app/src/main/java/com/steel/steel/ui/theme/Theme.kt << 'THEMEKOTLIN_EOF'
package com.steel.steel.ui.theme

import android.app.Activity
import androidx.compose.foundation.isSystemInDarkTheme
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.darkColorScheme
import androidx.compose.runtime.Composable
import androidx.compose.runtime.SideEffect
import androidx.compose.ui.graphics.toArgb
import androidx.compose.ui.platform.LocalView
import androidx.core.view.WindowCompat

private val DarkColorScheme = darkColorScheme(
    primary = Primary,
    secondary = Secondary,
    tertiary = Tactical,
    background = Background,
    surface = Card,
    onPrimary = CardForeground,
    onSecondary = CardForeground,
    onBackground = Foreground,
    onSurface = Foreground
)

@Composable
fun STEELAndroidTheme(
    darkTheme: Boolean = true,
    content: @Composable () -> Unit
) {
    val colorScheme = when {
        darkTheme -> DarkColorScheme
        else -> DarkColorScheme // Force dark theme
    }
    
    val view = LocalView.current
    if (!view.isInEditMode) {
        SideEffect {
            val window = (view.context as Activity).window
            window.statusBarColor = colorScheme.background.toArgb()
            WindowCompat.getInsetsController(window, view).isAppearanceLightStatusBars = false
        }
    }

    MaterialTheme(
        colorScheme = colorScheme,
        content = content
    )
}
THEMEKOTLIN_EOF

echo "  ✓ Theme.kt created"

cd ..
echo "✅ Android setup complete!"
echo ""

# ==========================================
# Summary
# ==========================================
echo "=========================================="
echo "Phase 0 Setup Complete!"
echo "=========================================="
echo ""
echo "📱 iOS Project: STEEL-iOS/STEEL-iOS.xcodeproj"
echo "🤖 Android Project: STEEL-Android/"
echo ""
echo "Next steps:"
echo "1. Open iOS: open STEEL-iOS/STEEL-iOS.xcodeproj"
echo "2. Open Android: Open STEEL-Android folder in Android Studio"
echo "3. Build iOS: Select simulator and press ⌘R"
echo "4. Build Android: Select emulator and press Shift+F10"
echo ""