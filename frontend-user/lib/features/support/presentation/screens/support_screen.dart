import 'package:flutter/material.dart';

class SupportScreen extends StatelessWidget {
  const SupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const SingleChildScrollView(
      child: Center(
        child: Padding(
          padding: EdgeInsets.all(20.0),
          child: Text('Hỗ trợ'),
        ),
      ),
    );
  }
} 