import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'providers/theme_provider.dart';
import 'providers/notification_provider.dart';
import 'screens/home.dart';
import 'services/firebase_service.dart';
import 'utils/auto_add_data.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // Initialize Firebase
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    print('🔥 Firebase initialized successfully!');

    // Initialize Firebase Service
    await FirebaseService.initialize();

    // Test Firebase connection
    final bool isConnected = await FirebaseService.testConnection();
    if (isConnected) {
      print('✅ Firebase connection verified!');

      // Auto-add sample data to Firebase on startup
      await AutoAddData.addDataOnStartup();
      print('🔥 Sample data added to Firebase automatically!');
    } else {
      print('❌ Firebase connection failed!');
    }

  } catch (e) {
    print('⚠️ Firebase initialization error: $e');
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => NotificationProvider()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp(
            title: 'Kalasalingam University',
            theme: themeProvider.lightTheme,
            darkTheme: themeProvider.darkTheme,
            themeMode: themeProvider.isDarkMode ? ThemeMode.dark : ThemeMode.light,
            home: const HomePage(),
            debugShowCheckedModeBanner: false,
          );
        },
      ),
    );
  }
}