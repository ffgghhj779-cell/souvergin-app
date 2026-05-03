plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
    id("com.google.gms.google-services")
}

android {
    namespace = "com.sovereignmaareg.sovereign_maareg_app"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    // ── Signing Configuration ──────────────────────────────────────────────────
    // Release signing reads from environment variables so the keystore never
    // lives in the repository. Set these in your CI/CD pipeline secrets.
    signingConfigs {
        create("release") {
            val keystorePath = System.getenv("KEYSTORE_PATH")
            if (keystorePath != null) {
                storeFile = file(keystorePath)
                storePassword = System.getenv("STORE_PASSWORD") ?: ""
                keyAlias = System.getenv("KEY_ALIAS") ?: ""
                keyPassword = System.getenv("KEY_PASSWORD") ?: ""
            }
        }
    }

    defaultConfig {
        applicationId = "com.sovereignmaareg.sovereign_maareg_app"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        debug {
            // Debug keeps default signing so hot-reload works without env vars.
            signingConfig = signingConfigs.getByName("debug")
        }
        release {
            // Use release keys if KEYSTORE_PATH is set, otherwise fall back to
            // debug (local dev only — CI/CD must always provide KEYSTORE_PATH).
            val releaseConfig = signingConfigs.findByName("release")
            signingConfig = if (System.getenv("KEYSTORE_PATH") != null && releaseConfig != null) {
                releaseConfig
            } else {
                signingConfigs.getByName("debug")
            }
            // ── Code Shrinking & Obfuscation ─────────────────────────────────
            isMinifyEnabled = true
            isShrinkResources = true
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )
        }
    }
}

flutter {
    source = "../.."
}
