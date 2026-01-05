import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'features/startup/splash_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://ocsgixkwwccytcaynlot.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im9jc2dpeGt3d2NjeXRjYXlubG90Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3Njc1OTYzNzAsImV4cCI6MjA4MzE3MjM3MH0.es0hrlp8tUsVuwip7AceK5xjb9onZJxF4WRYDQYFDlA',
  );

  runApp(
    const ProviderScope(
      child: FoodDeciderApp(),
    ),
  );
}

class FoodDeciderApp extends StatelessWidget {
  const FoodDeciderApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Food Mood',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
      ),
      home: const SplashPage(),
    );
  }
}
