import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:crud_lab/providers/auth_providers.dart';
import 'package:crud_lab/screens/coffee_list.dart';
import 'package:crud_lab/users/login_page.dart';
import 'package:crud_lab/screens/profile_screens.dart';
import 'package:crud_lab/screens/settings_screen.dart';
import 'package:crud_lab/screens/preference_screen.dart';

void main() {
  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (context) => AuthProvider()),
    ],
    child: const MyApp(),
  ));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, auth, child) {
        return MaterialApp(
          title: 'Kofeetih?',
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.brown),
          ),
          home: auth.isLoggedin ? const CoffeeListScreen() : const LoginPage(),
          routes: {
            '/profile': (context) => const ProfileScreen(),
            '/settings': (context) => const SettingsScreen(),
            // '/preference': (context) => const PreferenceScreen(),
          },
        );
      },
    );
  }
}
