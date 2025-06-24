import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:akiflash/view_models/auth_view_model.dart';
import 'package:akiflash/views/main_screen.dart';
import 'package:akiflash/views/login_screen.dart';
import 'package:akiflash/views/register_screen.dart';
import 'package:akiflash/views/profile_screen.dart';
import 'package:akiflash/views/splash_screen.dart';
import 'package:akiflash/views/home_screen.dart';
import 'package:akiflash/views/admin_screen.dart';
import 'package:akiflash/firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AuthViewModel(),
      child: MaterialApp(
        title: 'Aki Flash',
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF1976D2),
            brightness: Brightness.light,
          ).copyWith(
            primary: const Color(0xFF1976D2),
            secondary: const Color(0xFF42A5F5),
            surface: Colors.white,
            background: const Color(0xFFF8FAFF),
          ),
          fontFamily: 'SF Pro Display',
          appBarTheme: const AppBarTheme(
            centerTitle: false,
            elevation: 0,
            scrolledUnderElevation: 0,
            backgroundColor: Colors.transparent,
          ),
          // cardTheme: CardTheme(
          //   elevation: 0,
          //   shape: RoundedRectangleBorder(
          //     borderRadius: BorderRadius.circular(24),
          //   ),
          //   color: Colors.white,
          // ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ),
        initialRoute: '/splash',
        routes: {
          '/main': (context) => const MainScreen(),
          '/splash': (context) => const SplashScreen(),
          '/login': (context) => const LoginScreen(),
          '/register': (context) => const RegisterScreen(),
          '/home': (context) => const HomeScreen(),
          '/profile': (context) => const ProfileScreen(),
          '/admin': (context) => const AdminScreen(),
        },
      ),
    );
  }
}
