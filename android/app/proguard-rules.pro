# Picky X Android ProGuard & R8 Optimization Rules

# Flutter JNI and Engine Embedding
-keep class io.flutter.embedding.** { *; }
-dontwarn io.flutter.embedding.**

# SharedPreferences plugin (persists settings and player progression)
-keep class io.flutter.plugins.sharedpreferences.** { *; }

# Suppress warnings for Flutter engine's optional Play Core dynamic feature references.
# The app does not declare dynamic feature modules in pubspec.yaml; Play Core is intentionally omitted.
-dontwarn com.google.android.play.core.**

# Native / JNI Reflection
-keepclasseswithmembernames class * {
    native <methods>;
}
