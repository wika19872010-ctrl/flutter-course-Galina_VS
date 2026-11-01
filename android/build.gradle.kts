// Файл общих настроек сборки Android и каталогов результатов.

allprojects { // Применяем настройки ко всем Gradle-проектам.
    repositories { // Перечисляем источники зависимостей сборки.
        google() // Используем репозиторий Android и Firebase.
        mavenCentral() // Используем общедоступные Java/Kotlin-зависимости.
    }
}

val newBuildDir: Directory = // Вычисляем общий каталог результатов сборки.
    rootProject.layout.buildDirectory // Перенаправляем результаты в общий каталог build.
        .dir("../../build") // Дополняем путь именем каталога сборки.
        .get() // Получаем рассчитанное значение пути.
rootProject.layout.buildDirectory.value(newBuildDir) // Перенаправляем результаты в общий каталог build.

subprojects { // Настраиваем каждый вложенный модуль.
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name) // Выделяем отдельный каталог сборки модуля.
    project.layout.buildDirectory.value(newSubprojectBuildDir) // Применяем каталог сборки к текущему модулю.
}
subprojects { // Настраиваем каждый вложенный модуль.
    project.evaluationDependsOn(":app") // Согласуем порядок настройки модулей с приложением.
}

tasks.register<Delete>("clean") { // Создаём Gradle-задачу очистки результатов сборки.
    delete(rootProject.layout.buildDirectory) // Очищаем только автоматически созданный каталог build.
}
