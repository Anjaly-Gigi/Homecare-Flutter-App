# Keep Razorpay classes
-keep class com.razorpay.** { *; }
-dontwarn com.razorpay.**
-keep class proguard.annotation.Keep { *; }
-keep class proguard.annotation.KeepClassMembers { *; }
-keepattributes InnerClasses, EnclosingMethod
-dontwarn proguard.annotation.**
