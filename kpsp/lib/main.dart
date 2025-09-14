import 'dart:io';
import 'package:flutter/material.dart';
import 'package:kpsp/screens/welcome_screen.dart';
import 'package:kpsp/screens/main_menu_screen.dart';
import 'package:kpsp/theme/theme.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/date_symbol_data_local.dart';

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    final client = super.createHttpClient(context);
    client.badCertificateCallback = (cert, host, port) => true; // bypass SSL
    return client;
  }
}

void main() async {
  HttpOverrides.global = MyHttpOverrides(); // <<<<<< harus di sini
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('id_ID', null);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  Future<bool> _checkLogin() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    return token != null;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: LightMode,
      home: FutureBuilder<bool>(
        future: _checkLogin(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          } else {
            final isLoggedIn = snapshot.data ?? false;
            return isLoggedIn ? const MainMenuScreen() : const WelcomeScreen();
          }
        },
      ),
    );
  }
}
