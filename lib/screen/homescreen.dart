import 'package:flutter/material.dart';

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
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            color: Colors.black,
            decoration: TextDecoration.none,
          ),
        ),
      ),
    );
  }
}
