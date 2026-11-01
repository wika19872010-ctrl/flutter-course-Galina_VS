// Файл подключения Flutter SDK и объявления плагинов сборки Android.

pluginManagement { // Настраиваем поиск и загрузку Gradle-плагинов.
    val flutterSdkPath = // Определяем путь к установленному Flutter SDK.
        run { // Вычисляем значение пути внутри отдельного блока.
            val properties = java.util.Properties() // Создаём контейнер настроек local.properties.
            file("local.properties").inputStream().use { properties.load(it) } // Загружаем локальные настройки SDK из файла.
            val flutterSdkPath = properties.getProperty("flutter.sdk") // Определяем путь к установленному Flutter SDK.
            require(flutterSdkPath != null) { "flutter.sdk not set in local.properties" } // Останавливаем сборку, если путь Flutter SDK не настроен.
            flutterSdkPath // Возвращаем найденный путь SDK из блока run.
        }

    includeBuild("$flutterSdkPath/packages/flutter_tools/gradle")

    repositories { // Перечисляем источники зависимостей сборки.
        google() // Используем репозиторий Android и Firebase.
        mavenCentral() // Используем общедоступные Java/Kotlin-зависимости.
        gradlePluginPortal() // Используем каталог Gradle-плагинов.
    }
}

plugins {
    id("dev.flutter.flutter-plugin-loader") version "1.0.0" // Загружаем плагины, объявленные в pubspec.yaml.
    id("com.android.application") version "9.1.0" apply false
    // START: FlutterFire Configuration
    id("com.google.gms.google-services") version("4.4.4") apply false
    // END: FlutterFire Configuration
    id("org.jetbrains.kotlin.android") version "2.4.0" apply false
}

include(":app") // Включаем основной Android-модуль приложения.
