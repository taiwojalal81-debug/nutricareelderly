allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

subprojects {
    configurations.all {
        resolutionStrategy {
            eachDependency {
                if (requested.group == "androidx.core") {
                    if (requested.name == "core-ktx" || requested.name == "core") {
                        useVersion("1.13.1")
                    }
                }
                if (requested.group == "androidx.activity") {
                    if (requested.name == "activity" || requested.name == "activity-ktx") {
                        useVersion("1.9.3")
                    }
                }
                if (requested.group == "androidx.browser" && requested.name == "browser") {
                    useVersion("1.8.0")
                }
            }
        }
    }
    afterEvaluate {
        if (project.extensions.findByName("android") != null) {
            val android = project.extensions.getByName("android") as com.android.build.gradle.BaseExtension
            android.compileSdkVersion(35)
        }
    }
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
