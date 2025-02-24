import 'package:flutter/material.dart';
import '../widgets/sell_item.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: SizedBox(
          height: 40,
          child: TextField(
            decoration: InputDecoration(
              hintText: 'Tìm kiếm...',
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.0),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.0),
                borderSide: BorderSide(color: Colors.blue, width: 2.0),
              ),
              contentPadding: EdgeInsets.symmetric(horizontal: 10),
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.shopping_cart),
            onPressed: () {
              // TODO: Implement cart navigation
            },
          ),
          IconButton(
            icon: const Icon(Icons.message),
            onPressed: () {
              // TODO: Implement message navigation
            },
          ),
        ],
      ),
      body: ListView(
        children: const [
          SellItem(
            name: 'Laptop Asus A15',
            price: 20000000,
            soldCount: 150,
            discountPercent: 10,
            imageUrl: '../../assets/bag_1.png',
          ),
          SellItem(
            name: 'Laptop Asus ROG',
            price: 30000000,
            soldCount: 80,
            discountPercent: 15,
            imageUrl: '../../assets/bag_1.png',
          ),
          SellItem(
            name: 'Laptop Asus Zenbook',
            price: 25000000,
            soldCount: 60,
            discountPercent: 5,
            imageUrl: '../../assets/bag_1.png',
          ),
          SellItem(
            name: 'Laptop Lenovo IdeaPad',
            price: 18000000,
            soldCount: 120,
            discountPercent: 12,
            imageUrl: '../../assets/bag_1.png',
          ),
          SellItem(
            name: 'Laptop Lenovo ThinkPad',
            price: 22000000,
            soldCount: 90,
            discountPercent: 8,
            imageUrl: '../../assets/bag_1.png',
          ),
          SellItem(
            name: 'Laptop Lenovo Legion',
            price: 35000000,
            soldCount: 40,
            discountPercent: 20,
            imageUrl: '../../assets/bag_1.png',
          ),
          SellItem(
            name: 'Laptop Dell Inspiron',
            price: 19000000,
            soldCount: 110,
            discountPercent: 10,
            imageUrl: '../../assets/bag_1.png',
          ),
          SellItem(
            name: 'Laptop Dell XPS',
            price: 28000000,
            soldCount: 70,
            discountPercent: 5,
            imageUrl: '../../assets/bag_1.png',
          ),
          SellItem(
            name: 'Laptop Dell G5',
            price: 32000000,
            soldCount: 30,
            discountPercent: 15,
            imageUrl: '../../assets/bag_1.png',
          ),
          SellItem(
            name: 'Laptop HP Pavilion',
            price: 21000000,
            soldCount: 100,
            discountPercent: 10,
            imageUrl: '../../assets/bag_1.png',
          ),
          SellItem(
            name: 'Laptop HP Omen',
            price: 33000000,
            soldCount: 50,
            discountPercent: 20,
            imageUrl: '../../assets/bag_1.png',
          ),
          SellItem(
            name: 'Laptop HP Envy',
            price: 24000000,
            soldCount: 40,
            discountPercent: 15,
            imageUrl: '../../assets/bag_1.png',
          ),
          SellItem(
            name: 'Laptop Macbook Air',
            price: 35000000,
            soldCount: 200,
            discountPercent: 5,
            imageUrl: '../../assets/bag_1.png',
          ),
          SellItem(
            name: 'Laptop Macbook Pro',
            price: 45000000,
            soldCount: 150,
            discountPercent: 10,
            imageUrl: '../../assets/bag_1.png',
          ),
          SellItem(
            name: 'Laptop Macbook Retina',
            price: 40000000,
            soldCount: 80,
            discountPercent: 15,
            imageUrl: '../../assets/bag_1.png',
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Trang chủ'),
          BottomNavigationBarItem(icon: Icon(Icons.notifications), label: 'Thông báo'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Tôi'),
        ],
      ),
    );
  }
}
