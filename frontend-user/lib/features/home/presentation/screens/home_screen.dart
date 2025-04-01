import 'package:flutter/material.dart';
import '../../../../widgets/product_card.dart';
import '../../presentation/widgets/app_search_bar.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Sample product data - in a real app, this would come from an API
  final List<Map<String, dynamic>> _products = [
    {
      'name': 'Laptop Asus TUF Gaming A15',
      'price': 22000000,
      'soldCount': 128,
      'discountPercent': 15,
      'imageUrl': 'https://dlcdnwebimgs.asus.com/gain/31CFEEE7-41D7-4F07-A507-6581919A1C5C/w1000/h732'
    },
    {
      'name': 'Smartphone Samsung Galaxy S23',
      'price': 18990000,
      'soldCount': 215,
      'discountPercent': 10,
      'imageUrl': 'https://images.samsung.com/is/image/samsung/p6pim/vn/2302/gallery/vn-galaxy-s23-s911-sm-s911bzgcxxv-534856962'
    },
    {
      'name': 'iPad Pro 12.9" M2 Chip',
      'price': 29990000,
      'soldCount': 73,
      'discountPercent': 5,
      'imageUrl': 'https://store.storeimages.cdn-apple.com/4982/as-images.apple.com/is/ipad-pro-finish-select-202210-12-9inch-space-gray-wifi_FMT_WHH?wid=1280&hei=720&fmt=p-jpg&qlt=95&.v=1664411207212'
    },
    {
      'name': 'Bluetooth Headphones Sony WH-1000XM5',
      'price': 8490000,
      'soldCount': 354,
      'discountPercent': 12,
      'imageUrl': 'https://product.hstatic.net/1000370129/product/sony_wh-1000xm5_black_b_f6aafcda3f3546bca46e2b8f5d341309_master.jpg'
    },
    {
      'name': 'Mechanical Keyboard Keychron K2',
      'price': 1890000,
      'soldCount': 487,
      'discountPercent': 0,
      'imageUrl': 'https://cdn.shopify.com/s/files/1/0059/0630/1017/products/Keychron-K2-wireless-mechanical-keyboard-for-Mac-Windows-iOS-Gateron-switch-red-with-type-C-RGB-white-backlight_1800x1800.jpg'
    },
    {
      'name': 'Smart Watch Apple Watch Series 9',
      'price': 10990000,
      'soldCount': 201,
      'discountPercent': 8,
      'imageUrl': 'https://store.storeimages.cdn-apple.com/4982/as-images.apple.com/is/watch-s9-og-202309?wid=1200&hei=630&fmt=jpeg&qlt=95&.v=1693919592697'
    },
    {
      'name': 'Gaming Mouse Logitech G Pro X',
      'price': 2490000,
      'soldCount': 562,
      'discountPercent': 20,
      'imageUrl': 'https://resource.logitechg.com/d_transparent.gif/content/dam/gaming/en/products/pro-x-superlight/pro-x-superlight-black-gallery-1.png'
    },
    {
      'name': 'Portable SSD Samsung T7 1TB',
      'price': 3290000,
      'soldCount': 145,
      'discountPercent': 15,
      'imageUrl': 'https://images.samsung.com/is/image/samsung/p6pim/vn/mu-pc1t0h-ww/gallery/vn-portable-ssd-t7-mu-pc1t0h-437335-mu-pc1t0h-ww-534297538'
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const PreferredSize(
        preferredSize: Size.fromHeight(kToolbarHeight),
        child: AppSearchBar(),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Featured banner
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              margin: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.blue.shade700, Colors.blue.shade500],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(12.0),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8.0,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  const Text(
                    'Khuyến Mãi Đặc Biệt',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Giảm đến 20% cho tất cả sản phẩm công nghệ',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.blue.shade700,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    ),
                    child: const Text(
                      'Khám Phá Ngay',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
            
            // Category title
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'SẢN PHẨM NỔI BẬT',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextButton(
                    onPressed: () {},
                    child: Text(
                      'Xem tất cả',
                      style: TextStyle(color: Colors.blue[700]),
                    ),
                  ),
                ],
              ),
            ),

            // Product grid
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              child: GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.7,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                ),
                itemCount: _products.length,
                itemBuilder: (context, index) {
                  final product = _products[index];
                  return ProductCard(
                    name: product['name'],
                    price: product['price'].toDouble(),
                    soldCount: product['soldCount'],
                    discountPercent: product['discountPercent'].toDouble(),
                    imageUrl: product['imageUrl'],
                  );
                },
              ),
            ),

            // Additional section for promotions
            Container(
              margin: const EdgeInsets.all(16.0),
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Ưu Đãi Đặc Quyền',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      _buildPromotionCard(
                        Icons.local_shipping_outlined,
                        'Miễn Phí Vận Chuyển',
                        'Cho đơn hàng trên 500K',
                        Colors.green.shade700,
                      ),
                      const SizedBox(width: 8),
                      _buildPromotionCard(
                        Icons.discount_outlined,
                        'Voucher 100K',
                        'Cho khách hàng mới',
                        Colors.orange.shade700,
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Add some padding at the bottom
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildPromotionCard(IconData icon, String title, String subtitle, Color color) {
    return Expanded(
      child: Card(
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            children: [
              Icon(icon, color: color, size: 32),
              const SizedBox(height: 8),
              Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade700,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
} 