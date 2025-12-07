import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
// Import des pages
import '/pages/login_page.dart';
import '/pages/dashboard_page.dart'; // ⭐ IMPORTANT : import du dashboard

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
          "/dashboard": (context) => const DashboardPage(), // ⭐ ROUTE AJOUTÉE
        },
      ),
    );
  }
}
