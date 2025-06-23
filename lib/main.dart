import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:traveljournal/features/auth/presentation/splashscreen.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:traveljournal/services/connectivity_service.dart';
import 'package:traveljournal/features/journal/data/local_database_service.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables
  await dotenv.load();

  // Initialize local database
  await LocalDatabaseService().database;

  // Supabase initialization
  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL']!,
    anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
  );

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final ConnectivityService _connectivityService = ConnectivityService();
  ScaffoldFeatureController<SnackBar, SnackBarClosedReason>? _snackBarController;
  bool _lastStatus = true; // Assume online at start

  @override
  void initState() {
    super.initState();
    _connectivityService.connectionStatusController.stream.listen((
      isConnected,
    ) {
      if (context.mounted) {
        _showConnectivitySnackBar(context, isConnected);
      }
    });
  }

  @override
  void dispose() {
    _connectivityService.dispose();
    super.dispose();
  }

  void _showConnectivitySnackBar(BuildContext context, bool isConnected) {
    if (!context.mounted) return;

    // Only react if status changed
    if (_lastStatus == isConnected) return;
    _lastStatus = isConnected;

    // Remove previous snackbar if any
    _snackBarController?.close();

    if (!isConnected) {
      // Show persistent red snackbar
      _snackBarController = ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Row(
            children: [
              Icon(Icons.wifi_off, color: Colors.white),
              SizedBox(width: 8),
              Text('No internet connection'),
            ],
          ),
          backgroundColor: Colors.red,
          duration: Duration(days: 1), // Effectively persistent
        ),
      );
    } else {
      // Show green snackbar for 2 seconds
      _snackBarController = ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Row(
            children: [
              Icon(Icons.wifi, color: Colors.white),
              SizedBox(width: 8),
              Text('Back online'),
            ],
          ),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'WanderLog',
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
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          elevation: 0,
          surfaceTintColor: Colors.white,
          scrolledUnderElevation: 0,
        ),
      ),
      home: const SplashScreen(),
    );
  }
}
