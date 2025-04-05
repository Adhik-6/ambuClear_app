import java.util.Properties
import java.io.FileInputStream
import java.io.FileNotFoundException

plugins {
    id("com.android.application")
    // id("com.google.gms.google-services")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
}

val keystorePropertiesFile = rootProject.file("key.properties")
val keystoreProperties = Properties()

if (keystorePropertiesFile.exists()) {
    try {
        keystoreProperties.load(FileInputStream(keystorePropertiesFile))
    } catch (e: Exception) {
        println("Warning: Could not load key.properties file: ${e.message}")
        // Allow build to continue, but signingConfig below might fail if keys missing
    }
} else {
    println("Warning: key.properties file not found in android directory. Release signing may fail.")
    // Allow build to continue, but signingConfig below might fail if keys missing
}


android {
    namespace = "com.ambulance.clear"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = "27.0.12077973"

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_1_8
        targetCompatibility = JavaVersion.VERSION_1_8
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_1_8.toString()
    }

    defaultConfig {
        applicationId = "com.ambulance.clear"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    signingConfigs {
        create("release") {
            // Define the 'release' signing configuration properties
            // Only set properties if the file and keys exist
            if (keystorePropertiesFile.exists() && keystoreProperties.containsKey("storeFile")) {
                 try {
                    // Path in storeFile should be relative to 'android/', e.g., app/keystore.jks
                    storeFile = file(keystoreProperties.getProperty("storeFile"))
                    storePassword = keystoreProperties.getProperty("storePassword")
                    keyAlias = keystoreProperties.getProperty("keyAlias")
                    keyPassword = keystoreProperties.getProperty("keyPassword")
                 } catch (e: Exception) {
                    throw GradleException("Error reading required signing properties from android/key.properties: ${e.message}")
                 }
            } else {
                // If file or essential keys are missing, this signingConfig will be incomplete.
                // The build will likely fail later when 'buildTypes.release' tries to use it,
                // which is generally the desired behavior for a release build.
                println("Warning: android/key.properties not found or 'storeFile' key missing. Release signing config incomplete.")
            }
        }
    }

    buildTypes {
        release {
            // It tells the 'release' build type to USE the 'release' signing config defined above.
            // If that config is incomplete (e.g., storeFile wasn't set), the build should fail here.
            signingConfig = signingConfigs.getByName("release")

            isMinifyEnabled = true
            isShrinkResources = true
            proguardFiles(getDefaultProguardFile("proguard-android-optimize.txt"), "proguard-rules.pro")
        }
        // debug {
             // By default, debug builds are signed with the debug key
             // signingConfig = signingConfigs.getByName("debug")
        // }
    }
}

flutter {
    source = "../.."
}

dependencies {
  // Import the Firebase BoM
  // implementation(platform("com.google.firebase:firebase-bom:33.12.0"))


  // TODO: Add the dependencies for Firebase products you want to use
  // When using the BoM, don't specify versions in Firebase dependencies
  // implementation("com.google.firebase:firebase-analytics")
    implementation("com.google.android.play:core:1.10.3")
    implementation("com.google.android.play:core-ktx:1.8.1")


  // Add the dependencies for any other desired Firebase products
  // https://firebase.google.com/docs/android/setup#available-libraries
}
