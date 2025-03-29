import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Banner slider
          Container(
            height: 200,
            color: Colors.blue.shade100,
            child: const Center(
              child: Text('Banner Slider', style: TextStyle(fontSize: 24)),
            ),
          ),

          // Danh mục sản phẩm
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Danh mục sản phẩm',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  height: 100,
                  color: Colors.grey.shade200,
                  child: const Center(
                    child: Text('Category Slider', style: TextStyle(fontSize: 18)),
                  ),
                ),
              ],
            ),
          ),

          // Sản phẩm nổi bật
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Sản phẩm nổi bật',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  height: 300,
                  color: Colors.grey.shade200,
                  child: const Center(
                    child: Text('Featured Products', style: TextStyle(fontSize: 18)),
                  ),
                ),
              ],
            ),
          ),

          // Sản phẩm phổ biến
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Sản phẩm phổ biến',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  height: 300,
                  color: Colors.grey.shade200,
                  child: const Center(
                    child: Text('Popular Products', style: TextStyle(fontSize: 18)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
} 