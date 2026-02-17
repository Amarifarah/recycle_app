import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:recycle_app/pages/clients_page.dart';
import '/pages/login_page.dart';
import '/pages/dashboard_page.dart';
import '/pages/clients_page.dart';
import '/pages/settings_page.dart';
import '/pages/analytics_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [Provider<int>.value(value: 0)],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'My Dashboard App',
        theme: ThemeData(primarySwatch: Colors.blue),

        // PAGE DE DÉMARRAGE
        home: const LoginPage(),

        // ⭐⭐ ROUTES ICI ⭐⭐
        routes: {
          "/login": (context) => const LoginPage(),
          "/dashboard": (context) => const DashboardPage(),
          "/clients": (context) => const ClientsPage(),
          "/settings": (context) => const SettingsPage(), // ⭐ ROUTE AJOUTÉE
        },
      ),
    );
  }
}
