import 'package:flutter/material.dart';

class ProductsPromotionScreen extends StatefulWidget {
  const ProductsPromotionScreen({super.key});

  @override
  State<ProductsPromotionScreen> createState() => _ProductsPromotionScreenState();
}

class _ProductsPromotionScreenState extends State<ProductsPromotionScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text('Products Promotion Screen'),
      ),
    );
  }
}