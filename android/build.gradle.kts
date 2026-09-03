import com.android.build.gradle.BaseExtension

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

// Force all Android library/app modules to compileSdk 37 after their own
// build.gradle has applied (needed for older plugins still on 34/35).
gradle.projectsLoaded {
    rootProject.subprojects {
        val configureCompileSdk = Action<Project> {
            extensions.findByType(BaseExtension::class.java)?.apply {
                compileSdkVersion(37)
            }
        }
        if (state.executed) {
            configureCompileSdk.execute(this)
        } else {
            afterEvaluate(configureCompileSdk)
        }
    }
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
