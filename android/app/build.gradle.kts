plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

data class SigningMaterial(
    val storePath: String,
    val storePassword: String,
    val keyAlias: String,
    val keyPassword: String,
)

fun signingMaterial(prefix: String): SigningMaterial? {
    val values = listOf(
        System.getenv("${prefix}_KEYSTORE_PATH"),
        System.getenv("${prefix}_KEYSTORE_PASSWORD"),
        System.getenv("${prefix}_KEY_ALIAS"),
        System.getenv("${prefix}_KEY_PASSWORD"),
    )
    if (values.all { it.isNullOrBlank() }) return null
    require(values.none { it.isNullOrBlank() }) {
        "All ${prefix}_KEYSTORE_* and ${prefix}_KEY_* signing values must be provided together"
    }
    return SigningMaterial(
        storePath = values[0]!!,
        storePassword = values[1]!!,
        keyAlias = values[2]!!,
        keyPassword = values[3]!!,
    )
}

fun quotedBuildConfigValue(value: String): String {
    return "\"${value.replace("\\", "\\\\").replace("\"", "\\\"")}\""
}

val playSigning = signingMaterial("PLAY")
val researchSigning = signingMaterial("RESEARCH")
val protectionGrantTrustStore =
    System.getenv("PROTECTION_GRANT_TRUST_STORE_BASE64").orEmpty()
val signedRelease = System.getenv("GAMBLOCK_SIGNED_RELEASE") == "true"

if (signedRelease) {
    require(playSigning != null) {
        "GAMBLOCK_SIGNED_RELEASE requires complete PLAY_* signing values"
    }
    require(researchSigning != null) {
        "GAMBLOCK_SIGNED_RELEASE requires complete RESEARCH_* signing values"
    }
    require(protectionGrantTrustStore.isNotBlank()) {
        "GAMBLOCK_SIGNED_RELEASE requires PROTECTION_GRANT_TRUST_STORE_BASE64"
    }
}

android {
    namespace = "com.gamblock.gamblock_ai_apps"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
        // flutter_local_notifications requires java.time via desugaring.
        isCoreLibraryDesugaringEnabled = true
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    defaultConfig {
        applicationId = "com.gamblock.gamblock_ai_apps"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
        buildConfigField(
            "String",
            "PROTECTION_GRANT_TRUST_STORE_BASE64",
            quotedBuildConfigValue(protectionGrantTrustStore),
        )
    }

    signingConfigs {
        playSigning?.let { material ->
            create("playRelease") {
                storeFile = file(material.storePath)
                storePassword = material.storePassword
                keyAlias = material.keyAlias
                keyPassword = material.keyPassword
            }
        }
        researchSigning?.let { material ->
            create("researchRelease") {
                storeFile = file(material.storePath)
                storePassword = material.storePassword
                keyAlias = material.keyAlias
                keyPassword = material.keyPassword
            }
        }
    }

    flavorDimensions += "distribution"
    productFlavors {
        create("play") {
            dimension = "distribution"
            applicationId = "com.gamblock.gamblock_ai_apps"
            manifestPlaceholders["appLabel"] = "Gamblock-AI"
            buildConfigField("boolean", "SUPPORTS_CONTROLLED_REMOVAL", "false")
            playSigning?.let {
                signingConfig = signingConfigs.getByName("playRelease")
            }
        }
        create("research") {
            dimension = "distribution"
            applicationIdSuffix = ".research"
            versionNameSuffix = "-research"
            manifestPlaceholders["appLabel"] = "Gamblock-AI Research"
            buildConfigField("boolean", "SUPPORTS_CONTROLLED_REMOVAL", "true")
            researchSigning?.let {
                signingConfig = signingConfigs.getByName("researchRelease")
            }
        }
    }

    buildFeatures {
        buildConfig = true
    }
}

flutter {
    source = "../.."
}

dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.5")
}
