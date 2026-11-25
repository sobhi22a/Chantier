plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "dz.chantier.chantier_mobile"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        // Identifiant provisoire (ADR 0008) : a confirmer avant toute publication.
        applicationId = "dz.chantier.terrain"
        // Android 6 minimum : exige par flutter_secure_storage 10 (Keystore).
        minSdk = 23
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            // ATTENTION (revue R1-19) : le build release est signe avec la cle de DEBUG, uniquement
            // pour que `flutter run --release` fonctionne en developpement. Un APK ainsi signe ne doit
            // JAMAIS etre diffuse : n'importe qui pourrait le remplacer. Avant toute diffusion :
            // keystore de livraison hors depot et signature release, voir README.md, section
            // « Livraison ». Aucune cle n'est generee ici.
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

flutter {
    source = "../.."
}
