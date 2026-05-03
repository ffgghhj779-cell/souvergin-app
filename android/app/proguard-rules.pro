# ── Flutter / Dart ─────────────────────────────────────────────────────────────
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }
-keep class io.flutter.embedding.** { *; }

# ── Dart/Flutter serialization ─────────────────────────────────────────────────
# Prevents stripping of classes used via reflection in fromJson/toJson patterns.
-keepattributes *Annotation*
-keepattributes Signature
-keepattributes Exceptions
-keepattributes EnclosingMethod

# ── Supabase / Ktor / OkHttp ───────────────────────────────────────────────────
-keep class io.github.jan.supabase.** { *; }
-dontwarn okhttp3.**
-dontwarn okio.**
-keep class okhttp3.** { *; }
-keep interface okhttp3.** { *; }

# ── flutter_secure_storage ─────────────────────────────────────────────────────
-keep class com.it_nomads.fluttersecurestorage.** { *; }

# ── google_fonts (loads fonts via reflection) ──────────────────────────────────
-keep class com.google.** { *; }
-dontwarn com.google.**

# ── Kotlin coroutines (used by Ktor) ───────────────────────────────────────────
-dontwarn kotlinx.coroutines.**
-keep class kotlinx.coroutines.** { *; }

# ── Kotlin serialization ───────────────────────────────────────────────────────
-keepnames class kotlinx.serialization.** { *; }
-keepclassmembers class ** {
    @kotlinx.serialization.SerialName <fields>;
}
