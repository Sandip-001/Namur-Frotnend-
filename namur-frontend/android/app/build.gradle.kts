import java.util.Properties
import java.io.FileInputStream

// --------------------
// Plugins
// --------------------
plugins {
    id("com.android.application")
    id("kotlin-android")

    // Flutter plugin (MUST be after Android + Kotlin)
    id("dev.flutter.flutter-gradle-plugin")

    // Google Services plugin for Firebase
    id("com.google.gms.google-services")
}

// --------------------
// Keystore properties
// --------------------
val keystoreProperties = Properties()
val keystorePropertiesFile = rootProject.file("key.properties")

if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(FileInputStream(keystorePropertiesFile))
}

// --------------------
// Android config
// --------------------
android {
    namespace = "com.inkaanalysis.namur"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        applicationId = "com.inkaanalysis.namur"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    // --------------------
    // Signing config
    // --------------------
    signingConfigs {
        if (keystorePropertiesFile.exists()) {
            create("release") {
                keyAlias = keystoreProperties["keyAlias"] as String
                keyPassword = keystoreProperties["keyPassword"] as String
                storeFile = file(keystoreProperties["storeFile"] as String)
                storePassword = keystoreProperties["storePassword"] as String
            }
        }
    }

    buildTypes {
        getByName("release") {
            if (keystorePropertiesFile.exists()) {
                signingConfig = signingConfigs.getByName("release")
            }
            isMinifyEnabled = false
            isShrinkResources = false
        }
    }
}

// --------------------
// Flutter source
// --------------------
flutter {
    source = "../.."
}
