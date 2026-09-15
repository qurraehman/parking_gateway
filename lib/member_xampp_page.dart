import 'package:flutter/material.dart';
// 1. Import file yang baru kamu buat
import 'member_xampp_page.dart'; 

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: const MainNavigation(),
    );
  }
}

class MainNavigation extends StatelessWidget {
  const MainNavigation({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // 2. Panggil Widget-nya di sini (misal lewat tombol atau menu sidebar)
      body: const MemberListFromXampp(), 
    );
  }
}