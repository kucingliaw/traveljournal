import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:traveljournal/screen/splashscreen.dart';

void main() async {
  // Supabase initialization
  await Supabase.initialize(
    url: 'https://wynhgeabjnkycotojqqs.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Ind5bmhnZWFiam5reWNvdG9qcXFzIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDk2MzE5MDcsImV4cCI6MjA2NTIwNzkwN30.tx0WXSC_CVxVYeUDEqSvh4SO-LS5p33H7dtnUTV3WYQ',
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Travel Journal',
      debugShowCheckedModeBanner: false,
      home: SplashScreen(),
    );
  }
}
