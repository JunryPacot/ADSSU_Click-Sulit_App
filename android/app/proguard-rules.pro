# Flutter ProGuard Rules
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }
-keep class io.flutter.plugins.GeneratedPluginRegistrant { *; }

# App Main Activity
-keep class com.adssunian.adssu_click_and_sulit.MainActivity { *; }
-keep class com.adssunian.adssu_click_and_sulit.** { *; }

# Flutter Plugins
-keep class studio.midoridesign.gal.** { *; }
-keep class io.flutter.plugins.imagepicker.** { *; }
-keep class io.flutter.plugins.sharedpreferences.** { *; }
-keep class io.flutter.plugins.urllauncher.** { *; }
-keep class dev.fluttercommunity.plus.share.** { *; }
-keep class com.baseflow.permissionhandler.** { *; }
-keep class com.github.dart_lang.** { *; }

# Keep native methods and JNI
-keepclasseswithmembernames class * {
    native <methods>;
}

-keepclassmembers enum * {
    public static **[] values();
    public static ** valueOf(java.lang.String);
}

-dontwarn io.flutter.**
-dontwarn studio.midoridesign.gal.**
-dontwarn io.flutter.plugins.**
