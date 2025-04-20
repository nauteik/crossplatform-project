import 'package:admin_interface/models/product_model.dart';
import 'package:admin_interface/providers/product_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ProductProvider>(context, listen: false).fetchProducts();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<ProductProvider>(
        builder: (context, productProvider, child) {
          final status = productProvider.status;

          if (status == ProductStatus.loading &&
              productProvider.products.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          } else if (status == ProductStatus.error &&
              productProvider.products.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Có lỗi xảy ra: ${productProvider.errorMessage}',
                    style: const TextStyle(color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      productProvider.fetchProducts();
                    },
                    child: const Text('Thử lại'),
                  ),
                ],
              ),
            );
          }

          final products = productProvider.products;

          return RefreshIndicator(
            onRefresh: () => productProvider.fetchProducts(),
            child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  children: [for (Product product in products) Text(product.name + ' - ' + product.productType.toString())],
                )),
          );
        },
      ),
    );
  }
}
