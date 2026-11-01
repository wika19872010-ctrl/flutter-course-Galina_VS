// Файл настроек сборки Android-приложения и подключения Firebase.

plugins {
    id("com.android.application")
    // START: FlutterFire Configuration
    id("com.google.gms.google-services")
    // END: FlutterFire Configuration
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android { // Настраиваем Android-приложение.
    namespace = "com.example.flutter_application_dz_27092026" // Задаём пространство имён Android-кода.
    compileSdk = flutter.compileSdkVersion // Берём версию SDK, рекомендованную Flutter.
    ndkVersion = flutter.ndkVersion // Согласуем версию NDK с Flutter.

    compileOptions { // Настраиваем совместимость Java-кода.
        sourceCompatibility = JavaVersion.VERSION_17 // Используем синтаксис Java 17.
        targetCompatibility = JavaVersion.VERSION_17 // Генерируем байткод для Java 17.
    }

    defaultConfig { // Задаём основные параметры Android-приложения.
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.example.flutter_application_dz_27092026" // Указываем ID приложения, зарегистрированный в Firebase.
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion // Используем минимальную версию Android из Flutter SDK.
        targetSdk = flutter.targetSdkVersion // Используем целевую версию Android из Flutter SDK.
        // Uses the version code from pubspec.yaml. When using split APKs, 1000 * ABI_VERSION
        // is added automatically by Flutter. (https://developer.android.com/studio/build/configure-apk-splits#configure-APK-versions)
        // You can force using the value of versionCode by specifying the `-P force-version-code-ignoring-abi=true`
        // flag during build.
        versionCode = flutter.versionCode // Читаем номер сборки из pubspec.yaml.
        versionName = flutter.versionName // Читаем версию приложения из pubspec.yaml.
    }

    buildTypes { // Описываем варианты сборки.
        release { // Настраиваем учебную release-сборку.
            // TODO: Add your own signing config for the release build.
            // Signing with the debug keys for now, so `flutter run --release` works.
            signingConfig = signingConfigs.getByName("debug") // Используем отладочную подпись учебного приложения.
        }
    }
}

kotlin { // Настраиваем Kotlin-компилятор.
    compilerOptions { // Указываем параметры генерации Kotlin-кода.
        jvmTarget = org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17 // Согласуем целевую JVM с Java 17.
    }
}

flutter { // Настраиваем Flutter-часть Android-модуля.
    source = "../.." // Указываем корень Flutter-проекта.
}
