import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Size size;

  @override
  Widget build(BuildContext context) {
    size = MediaQuery.of(context).size;
    return Container(
      height: size.height,
      width: size.width,
      color: Colors.white,
      child: Center(
        child: Text(
          'Home Screen',
          style: GoogleFonts.poppins(
            fontSize: 24,
            color: Colors.black,
            decoration: TextDecoration.none,
          ),
        ),
      ),
    );
  }
}
