import 'package:clients/screen/clientdashboard.dart';
import 'package:clients/screen/landingpage.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

// Background message handler
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(); // Required for background handling
  print("Handling a background message: ${message.messageId}");
}

// Initialize local notifications plugin
final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp();

  // Initialize Supabase
  await Supabase.initialize(
    url: 'https://awbbcyahdusjhmlryvef.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImF3YmJjeWFoZHVzamhtbHJ5dmVmIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MzkxODgyNDEsImV4cCI6MjA1NDc2NDI0MX0.6Uf3OQIgz466L-14CuUTiGQYxVdgu2ZliCnNcoNDh5I',
  );

  // Request notification permissions and set up FCM
  await requestNotificationPermission();
  await FirebaseMessaging.instance.setAutoInitEnabled(true);

  // Set up background message handler
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  // Initialize local notifications
  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('@mipmap/ic_launcher');
  const InitializationSettings initializationSettings =
      InitializationSettings(android: initializationSettingsAndroid);
  await flutterLocalNotificationsPlugin.initialize(initializationSettings);

  // Handle foreground messages
  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    print('Got a message whilst in the foreground!');
    print('Message data: ${message.notification?.title}');
    if (message.notification != null) {
      _showLocalNotification(message);
    }
  });

  // Handle notification when app is opened from a terminated state
  FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
    print('Notification opened: ${message.notification?.title}');
  });

  // Store FCM token in Supabase
  await _storeFCMToken();

  runApp(const MainApp());
}

Future<void> requestNotificationPermission() async {
  FirebaseMessaging messaging = FirebaseMessaging.instance;
  NotificationSettings settings = await messaging.requestPermission(
    alert: true,
    announcement: true,
    badge: true,
    sound: true,
  );

  if (settings.authorizationStatus == AuthorizationStatus.authorized) {
    print('User granted permission');
  } else if (settings.authorizationStatus == AuthorizationStatus.provisional) {
    print('User granted provisional permission');
  } else {
    print('User denied permission');
  }
}

Future<void> _storeFCMToken() async {
  String? token = await FirebaseMessaging.instance.getToken();
  if (token != null) {
    print("Client FCM Token: $token");
    final user = Supabase.instance.client.auth.currentUser;
    // if (user != null) {
    //   await Supabase.instance.client
    //       .from('tbl_client')
    //       .update({'fcm_token': token}).eq('id', user.id);
    //   print("FCM token stored for client: ${user.id}");
    // }
  }

  // Listen for token refresh
  FirebaseMessaging.instance.onTokenRefresh.listen((newToken) async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user != null) {
      await Supabase.instance.client
          .from('tbl_client')
          .update({'fcm_token': newToken}).eq('id', user.id);
      print("FCM token refreshed for client: $newToken");
    }
  });
}

void _showLocalNotification(RemoteMessage message) async {
  const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
    'channel_id', 'Notifications',
    importance: Importance.max,
    priority: Priority.high,
  );
  const NotificationDetails notificationDetails =
      NotificationDetails(android: androidDetails);
  await flutterLocalNotificationsPlugin.show(
    0, // Notification ID
    message.notification?.title ?? 'No Title',
    message.notification?.body ?? 'No Body',
    notificationDetails,
  );
}

// Supabase client reference
final supabase = Supabase.instance.client;

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: AuthWrapper(),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final session = supabase.auth.currentSession;
    return session != null ? ClientDashboard() : Mylanding();
  }
}