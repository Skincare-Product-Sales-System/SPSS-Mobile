import java.util.Properties
import java.io.FileInputStream

plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
}

val localProperties = Properties().apply {
    val localPropsFile = rootProject.file("local.properties")
    if (localPropsFile.exists()) {
        load(FileInputStream(localPropsFile))
    }
}

val flutterVersionName = localProperties.getProperty("flutter.versionName") ?: "1.0"

val keyStoreProperties = Properties()
val keyStorePropertiesFile = rootProject.file("key.properties")
if (keyStorePropertiesFile.exists()) {
    keyStoreProperties.load(FileInputStream(keyStorePropertiesFile))
}

android {
    namespace = "com.example.shopsmart_users_en"
    compileSdk = 35
    ndkVersion = "27.0.12077973"

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = "11"
    }

    defaultConfig {
        applicationId = "com.svgfpt.spss"
        minSdk = 21
        targetSdk = 35
        versionCode = 1
        versionName = flutterVersionName
    }

    signingConfigs {
        create("release") {
            keyAlias = keyStoreProperties["keyAlias"] as String?
            keyPassword = keyStoreProperties["keyPassword"] as String?
            storeFile = keyStoreProperties["storeFile"]?.let { file(it.toString()) }
            storePassword = keyStoreProperties["storePassword"] as String?
        }
    }

    buildTypes {
        getByName("release") {
            signingConfig = signingConfigs.getByName("release")
        }
    }
}

flutter {
    source = "../.."
}
