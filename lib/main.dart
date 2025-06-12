import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:traveljournal/screen/splashscreen.dart';
import 'package:google_fonts/google_fonts.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
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
      theme: ThemeData(
        // Set Poppins as the default font family
        textTheme: GoogleFonts.poppinsTextTheme(Theme.of(context).textTheme),
        // You can also set specific styles for different text types
        primaryTextTheme: GoogleFonts.poppinsTextTheme(
          Theme.of(context).primaryTextTheme,
        ),
        // Set color scheme and button themes
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF1E201E)),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF1E201E),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 15),
          ),
        ),
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            backgroundColor: const Color(0xFF1E201E),
            foregroundColor: Colors.white,
          ),
        ),
        floatingActionButtonTheme: FloatingActionButtonThemeData(
          backgroundColor: const Color(0xFF1E201E),
          foregroundColor: Colors.white,
        ),
        iconButtonTheme: IconButtonThemeData(
          style: IconButton.styleFrom(foregroundColor: const Color(0xFF1E201E)),
        ),
        useMaterial3: true,
      ),
      home: SplashScreen(),
    );
  }
}
