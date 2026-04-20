plugins {
    id("com.android.application")
    id("kotlin-android")
    // Flutter Gradle Plugin phải nằm sau Android và Kotlin
    id("dev.flutter.flutter-gradle-plugin")
    // Áp dụng plugin Google Services (Không ghi version ở đây nữa)
    id("com.google.gms.google-services")
}

android {
    namespace = "com.example.vitaminc"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    defaultConfig {
        applicationId = "com.example.vitaminc"
        
        // Firebase yêu cầu minSdkVersion tối thiểu là 21
        minSdk = flutter.minSdkVersion 
        
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            // Sử dụng debug keys để có thể chạy thử bản release tạm thời
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

dependencies {
    // Nhập Firebase BoM để quản lý phiên bản tự động các thư viện Firebase
    implementation(platform("com.google.firebase:firebase-bom:34.12.0"))
    implementation("com.google.firebase:firebase-analytics")
}

flutter {
    source = "../.."
}
