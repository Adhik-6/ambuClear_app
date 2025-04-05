# Flutter and Dart
-keep class io.flutter.** { *; }
-keep class com.example.** { *; }

# Google Maps
-keep class com.google.android.gms.maps.** { *; }
-keep class com.google.maps.android.** { *; }
-keep class com.google.android.libraries.places.** { *; }

# Prevent obfuscation of Firebase-related classes
-keep class com.google.firebase.** { *; }
-keep class com.google.android.gms.** { *; }

# Keep Gson models
-keepclassmembers class * {
  @com.google.gson.annotations.SerializedName <fields>;
}

# Prevent stripping of Parcelable classes
-keepclassmembers class * implements android.os.Parcelable {
    public static final android.os.Parcelable$Creator *;
}

# Keep Play Core SplitCompat classes
-keep class com.google.android.play.core.splitcompat.** { *; }
-keep class com.google.android.play.core.splitinstall.** { *; }
-keep class com.google.android.play.core.tasks.** { *; }

# Prevent stripping of Flutter's Deferred Components
-keep class io.flutter.embedding.engine.deferredcomponents.** { *; }

# Ensure R8 doesn't remove Play Core functionality
-dontwarn com.google.android.play.core.**
-dontwarn com.google.android.play.core.splitinstall.**
-dontwarn com.google.android.play.core.tasks.**
