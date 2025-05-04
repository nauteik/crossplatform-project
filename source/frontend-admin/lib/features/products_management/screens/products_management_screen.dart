import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:admin_interface/providers/product_provider.dart';
import 'package:admin_interface/models/product_model.dart';
import 'package:admin_interface/core/utils/image_helper.dart';
import 'package:admin_interface/features/products_management/screens/product_form_screen.dart';
import 'package:intl/intl.dart';

class ProductsManagementScreen extends StatefulWidget {
  const ProductsManagementScreen({super.key});

  @override
  State<ProductsManagementScreen> createState() => _ProductsManagementScreenState();
}

class _ProductsManagementScreenState extends State<ProductsManagementScreen> {
  final currencyFormat = NumberFormat.currency(locale: 'vi_VN', symbol: '₫');
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    // Gọi API để lấy danh sách sản phẩm khi màn hình được khởi tạo
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ProductProvider>(context, listen: false).fetchProducts();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _searchProducts() {
    final query = _searchController.text.trim();
    if (query.isNotEmpty) {
      setState(() {
        _isSearching = true;
      });
      Provider.of<ProductProvider>(context, listen: false)
          .searchProducts(query)
          .whenComplete(() {
        setState(() {
          _isSearching = false;
        });
      });
    }
  }

  void _clearSearch() {
    _searchController.clear();
    Provider.of<ProductProvider>(context, listen: false).fetchProducts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quản lý sản phẩm'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const ProductFormScreen(),
                ),
              ).then((_) {
                // Refresh product list when returning from add screen
                Provider.of<ProductProvider>(context, listen: false).fetchProducts();
              });
            },
            tooltip: 'Thêm sản phẩm mới',
          ),
        ],
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Tìm kiếm sản phẩm...',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: _clearSearch,
                            )
                          : null,
                    ),
                    onSubmitted: (_) => _searchProducts(),
                  ),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: _searchProducts,
                  child: const Text('Tìm kiếm'),
                ),
              ],
            ),
          ),
          // Product list
          Expanded(
            child: _buildBody(),
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    return Consumer<ProductProvider>(
      builder: (context, productProvider, child) {
        final status = productProvider.status;

        if (status == ProductStatus.loading || _isSearching) {
          return const Center(child: CircularProgressIndicator());
        } else if (status == ProductStatus.error) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Lỗi: ${productProvider.errorMessage}', style: const TextStyle(color: Colors.red)),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    productProvider.fetchProducts();
                  },
                  child: const Text('Thử lại'),
                )
              ],
            ),
          );
        } else if (status == ProductStatus.loaded) {
          final products = productProvider.products;

          if (products.isEmpty) {
            return const Center(
              child: Text('Không có sản phẩm nào'),
            );
          }

          return _buildProductsTable(products);
        }

        return const Center(child: Text('Vui lòng tải dữ liệu sản phẩm'));
      },
    );
  }

  Widget _buildProductsTable(List<Product> products) {
    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          columns: const [
            DataColumn(label: Text('ID')),
            DataColumn(label: Text('Hình ảnh')),
            DataColumn(label: Text('Tên sản phẩm')),
            DataColumn(label: Text('Giá')),
            DataColumn(label: Text('Giảm giá')),
            DataColumn(label: Text('Số lượng')),
            DataColumn(label: Text('Đã bán')),
            DataColumn(label: Text('Thương hiệu')),
            DataColumn(label: Text('Loại')),
            DataColumn(label: Text('Thao tác')),
          ],
          rows: products.map((product) {
            return DataRow(
              cells: [
                DataCell(Text(product.id.length > 8 
                    ? '${product.id.substring(0, 8)}...' 
                    : product.id)),
                DataCell(
                  product.primaryImageUrl.isNotEmpty
                      ? Image.network(
                          ImageHelper.getProductImage(product.primaryImageUrl),
                          width: 50,
                          height: 50,
                          errorBuilder: (context, error, stackTrace) {
                            return const Icon(Icons.image_not_supported);
                          },
                        )
                      : const Icon(Icons.image_not_supported),
                ),
                DataCell(Text(product.name)),
                DataCell(Text(currencyFormat.format(product.price))),
                DataCell(Text('${product.discountPercent.toStringAsFixed(0)}%')),
                DataCell(Text('${product.quantity}')),
                DataCell(Text('${product.soldCount}')),
                DataCell(Text(product.brand['name'] ?? 'Không có')),
                DataCell(Text(product.productType['name'] ?? 'Không có')),
                DataCell(
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => ProductFormScreen(
                                product: product,
                                isEditing: true,
                              ),
                            ),
                          ).then((_) {
                            // Refresh product list when returning from edit screen
                            Provider.of<ProductProvider>(context, listen: false).fetchProducts();
                          });
                        },
                        tooltip: 'Sửa',
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () {
                          _showDeleteConfirmation(context, product);
                        },
                        tooltip: 'Xóa',
                      ),
                    ],
                  ),
                ),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, Product product) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Xác nhận xóa'),
          content: Text('Bạn có chắc chắn muốn xóa sản phẩm ${product.name}?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Hủy'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                
                final productProvider = Provider.of<ProductProvider>(context, listen: false);
                final success = await productProvider.deleteProduct(product.id);
                
                if (success && context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Xóa sản phẩm thành công'),
                      backgroundColor: Colors.green,
                    ),
                  );
                } else if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Lỗi: ${productProvider.errorMessage}'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              child: const Text('Xóa', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }
}