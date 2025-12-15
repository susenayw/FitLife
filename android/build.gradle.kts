// android/build.gradle.kts (KODE LENGKAP & TERKOREKSI)

buildscript {

    // Konfigurasi repository untuk menemukan plugin
    repositories {
        google()
        mavenCentral()
    }

    dependencies {
        // Classpath untuk Android Gradle Plugin
        classpath("com.android.tools.build:gradle:8.1.4") // Sesuaikan versi jika berbeda

        // WAJIB ADA: Classpath untuk plugin Google Services
        classpath("com.google.gms:google-services:4.4.1") // Versi terbaru saat ini
    }
}


allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

val newBuildDir: Directory =
    rootProject.layout.buildDirectory
        .dir("../../build")
        .get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}
subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}