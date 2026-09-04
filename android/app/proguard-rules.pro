# Flutter
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }

# WorkManager (GMA / play-services-ads) — R8 full mode strips reflective Room ctor
# and crashes at androidx.startup.InitializationProvider in release.
-keep class androidx.work.** { *; }
-keep class androidx.work.impl.** { *; }
-dontwarn androidx.work.**
-dontwarn androidx.work.impl.**

-keepclassmembers class * extends androidx.work.Worker {
    public <init>(android.content.Context,androidx.work.WorkerParameters);
}
-keepclassmembers class * extends androidx.work.ListenableWorker {
    public <init>(android.content.Context,androidx.work.WorkerParameters);
}

# Room reflective surface used by WorkDatabase_Impl
-keepclassmembers class * extends androidx.room.RoomDatabase {
    public <init>();
    protected abstract androidx.room.InvalidationTracker createInvalidationTracker();
    public abstract void clearAllTables();
}

# Google Mobile Ads / Play services
-keep class com.google.android.gms.ads.** { *; }
-dontwarn com.google.android.gms.ads.**
-keep class com.google.android.gms.common.** { *; }
-keep class com.google.android.gms.internal.ads.** { *; }

# Firebase / Crashlytics
-keepattributes SourceFile,LineNumberTable
-keep public class * extends java.lang.Exception
-keep class com.google.firebase.** { *; }
-dontwarn com.google.firebase.**

# Play Billing
-keep class com.android.vending.billing.** { *; }
-keep class com.android.billingclient.** { *; }

# Flutter deferred components / Play Core (optional; not bundled) — R8 AGP 8+
-dontwarn com.google.android.play.core.splitcompat.SplitCompatApplication
-dontwarn com.google.android.play.core.splitinstall.SplitInstallException
-dontwarn com.google.android.play.core.splitinstall.SplitInstallManager
-dontwarn com.google.android.play.core.splitinstall.SplitInstallManagerFactory
-dontwarn com.google.android.play.core.splitinstall.SplitInstallRequest$Builder
-dontwarn com.google.android.play.core.splitinstall.SplitInstallRequest
-dontwarn com.google.android.play.core.splitinstall.SplitInstallSessionState
-dontwarn com.google.android.play.core.splitinstall.SplitInstallStateUpdatedListener
-dontwarn com.google.android.play.core.tasks.OnFailureListener
-dontwarn com.google.android.play.core.tasks.OnSuccessListener
-dontwarn com.google.android.play.core.tasks.Task
