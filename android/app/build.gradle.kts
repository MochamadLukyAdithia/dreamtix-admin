plugins {
    id("com.android.application")
    id("org.jetbrains.kotlin.android") // Lebih eksplisit dan modern
    id("dev.flutter.flutter-gradle-plugin") // Harus terakhir
}

android {
    namespace = "com.example.dreamtix_admin"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = "29.0.13599879"
    defaultConfig {
        applicationId = "com.example.dreamtix_admin"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = "11"
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

flutter {
    source = "../.."
}
