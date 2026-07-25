pluginManagement {
    val flutterSdkPath =
        run {
            val properties = java.util.Properties()
            file("local.properties").inputStream().use { properties.load(it) }
            val flutterSdkPath = properties.getProperty("flutter.sdk")
            require(flutterSdkPath != null) { "flutter.sdk not set in local.properties" }
            flutterSdkPath
        }

    includeBuild("$flutterSdkPath/packages/flutter_tools/gradle")

    repositories {
        google()
        mavenCentral()
        gradlePluginPortal()
    }
}

plugins {
    id("dev.flutter.flutter-plugin-loader") version "1.0.0"
    // AGP9のBuilt-in Kotlin移行に未対応のプラグイン(file_picker/app_links等)が
    // 相互に矛盾する前提でビルドを壊すため、エコシステム全体で広く枯れているAGP8系に固定する。
    // 8.7.3ではandroidx.browser/activity/core等の新しいAARが要求するAGP最低バージョン
    // (8.9.1+)を満たせずchecDebugAarMetadataで失敗したため8.11.1に引き上げ。
    id("com.android.application") version "8.11.1" apply false
    id("org.jetbrains.kotlin.android") version "2.2.20" apply false
}

include(":app")
