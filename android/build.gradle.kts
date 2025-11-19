// gui2761/check_men/Check_Men-e15d1b7f40dd23def6eca51b303d67d10e1cbdd7/android/build.gradle.kts

// NOVO: Adicionar o plugin do Google Services na seção plugins, como instruído.
plugins {
    // ... plugins existentes
    
    // Adicionar o plugin do Google Services
    id("com.google.gms.google-services") version "4.4.1" apply false 
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