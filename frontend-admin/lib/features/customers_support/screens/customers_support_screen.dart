import 'package:flutter/material.dart';

class CustomersSupportScreen extends StatefulWidget {
  const CustomersSupportScreen({super.key});

  @override
  State<CustomersSupportScreen> createState() => _CustomersSupportScreenState();
}

class _CustomersSupportScreenState extends State<CustomersSupportScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text('Customers Support Screen'),
      ),
    );
  }
}