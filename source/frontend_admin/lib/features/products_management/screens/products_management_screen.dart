import 'package:flutter/material.dart';
import 'package:frontend_admin/core/utils/image_helper.dart';
import 'package:frontend_admin/features/products_management/screens/product_form_screen.dart';
import 'package:frontend_admin/features/products_management/screens/product_types_tab.dart';
import 'package:frontend_admin/features/products_management/screens/brands_tab.dart';
import 'package:frontend_admin/features/products_management/screens/tags_tab.dart';
import 'package:frontend_admin/models/product_model.dart';
import 'package:frontend_admin/providers/product_provider.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class ProductsManagementScreen extends StatefulWidget {
  const ProductsManagementScreen({super.key});

  @override
  State<ProductsManagementScreen> createState() => _ProductsManagementScreenState();
}

class _ProductsManagementScreenState extends State<ProductsManagementScreen> with SingleTickerProviderStateMixin {
  final currencyFormat = NumberFormat.currency(locale: 'vi_VN', symbol: '₫');
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _tabController.addListener(_handleTabSelection);
    // Gọi API để lấy danh sách sản phẩm khi màn hình được khởi tạo
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ProductProvider>(context, listen: false).fetchProducts();
    });
  }

  void _handleTabSelection() {
    // Khi tab thay đổi, cập nhật lại state để cập nhật UI (ví dụ: hiển thị/ẩn floatingActionButton)
    setState(() {});
  }

  @override
  void dispose() {
    _searchController.dispose();
    _tabController.removeListener(_handleTabSelection);
    _tabController.dispose();
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
        title: const Text('Quản lý kho hàng', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.indigo.shade800,
        foregroundColor: Colors.white,
        elevation: 2,
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: Colors.orange,
          indicatorWeight: 3,
          tabs: const [
            Tab(
              icon: Icon(Icons.inventory),
              text: 'Sản phẩm',
            ),
            Tab(
              icon: Icon(Icons.category),
              text: 'Danh mục',
            ),
            Tab(
              icon: Icon(Icons.branding_watermark),
              text: 'Thương hiệu',
            ),
            Tab(
              icon: Icon(Icons.label),
              text: 'Nhãn',
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildProductsTab(),
          const ProductTypesTab(),
          const BrandsTab(),
          const TagsTab(),
        ],
      ),
      floatingActionButton: _tabController.index == 0
          ? FloatingActionButton(
              heroTag: 'add_product',
              backgroundColor: Colors.orange,
              child: const Icon(Icons.add),
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const ProductFormScreen(),
                  ),
                ).then((_) {
                  Provider.of<ProductProvider>(context, listen: false).fetchProducts();
                });
              },
            )
          : null,
    );
  }

  Widget _buildProductsTab() {
    return Column(
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
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: Colors.indigo.shade500, width: 2),
                    ),
                    filled: true,
                    fillColor: Colors.grey.shade50,
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
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.indigo.shade500,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
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
    );
  }

  Widget _buildBody() {
    return Consumer<ProductProvider>(
      builder: (context, productProvider, child) {
        final status = productProvider.status;

        if (status == ProductStatus.loading || _isSearching) {
          return const Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.indigo),
            ),
          );
        } else if (status == ProductStatus.error) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 60, color: Colors.red.shade300),
                const SizedBox(height: 16),
                Text(
                  'Lỗi: ${productProvider.errorMessage}',
                  style: TextStyle(color: Colors.red.shade700),
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: () {
                    productProvider.fetchProducts();
                  },
                  icon: const Icon(Icons.refresh),
                  label: const Text('Thử lại'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.indigo.shade500,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  ),
                )
              ],
            ),
          );
        } else if (status == ProductStatus.loaded) {
          final products = productProvider.products;

          if (products.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.inventory_2_outlined, size: 80, color: Colors.grey.shade400),
                  const SizedBox(height: 16),
                  Text(
                    'Không có sản phẩm nào',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey.shade700,
                    ),
                  ),
                ],
              ),
            );
          }

          return _buildProductsTable(products);
        }

        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.cloud_download_outlined, size: 60, color: Colors.indigo.shade200),
              const SizedBox(height: 16),
              Text(
                'Vui lòng tải dữ liệu sản phẩm',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.indigo.shade700,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildProductsTable(List<Product> products) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            offset: const Offset(0, 2),
            blurRadius: 6,
          ),
        ],
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: DataTable(
            headingRowColor: MaterialStateProperty.all(Colors.indigo.shade50),
            dataRowColor: MaterialStateProperty.resolveWith<Color?>(
              (Set<MaterialState> states) {
                if (states.contains(MaterialState.selected)) {
                  return Colors.indigo.shade50;
                }
                if (states.contains(MaterialState.hovered)) {
                  return Colors.orange.shade50;
                }
                return null;
              },
            ),
            border: TableBorder.all(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(10),
            ),
            horizontalMargin: 16,
            columnSpacing: 20,
            columns: [
              DataColumn(
                label: Text(
                  'ID',
                  style: TextStyle(fontWeight: FontWeight.bold, color: Colors.indigo.shade800),
                ),
              ),
              DataColumn(
                label: Text(
                  'Hình ảnh',
                  style: TextStyle(fontWeight: FontWeight.bold, color: Colors.indigo.shade800),
                ),
              ),
              DataColumn(
                label: Text(
                  'Tên sản phẩm',
                  style: TextStyle(fontWeight: FontWeight.bold, color: Colors.indigo.shade800),
                ),
              ),
              DataColumn(
                label: Text(
                  'Giá',
                  style: TextStyle(fontWeight: FontWeight.bold, color: Colors.indigo.shade800),
                ),
              ),
              DataColumn(
                label: Text(
                  'Giảm giá',
                  style: TextStyle(fontWeight: FontWeight.bold, color: Colors.indigo.shade800),
                ),
              ),
              DataColumn(
                label: Text(
                  'Số lượng',
                  style: TextStyle(fontWeight: FontWeight.bold, color: Colors.indigo.shade800),
                ),
              ),
              DataColumn(
                label: Text(
                  'Đã bán',
                  style: TextStyle(fontWeight: FontWeight.bold, color: Colors.indigo.shade800),
                ),
              ),
              DataColumn(
                label: Text(
                  'Thương hiệu',
                  style: TextStyle(fontWeight: FontWeight.bold, color: Colors.indigo.shade800),
                ),
              ),
              DataColumn(
                label: Text(
                  'Loại',
                  style: TextStyle(fontWeight: FontWeight.bold, color: Colors.indigo.shade800),
                ),
              ),
              DataColumn(
                label: Text(
                  'Thao tác',
                  style: TextStyle(fontWeight: FontWeight.bold, color: Colors.indigo.shade800),
                ),
              ),
            ],
            rows: products.map((product) {
              return DataRow(
                cells: [
                  DataCell(Text(
                    product.id.length > 8 ? '${product.id.substring(0, 8)}...' : product.id,
                    style: TextStyle(color: Colors.grey.shade700, fontSize: 13),
                  )),
                  DataCell(
                    product.primaryImageUrl.isNotEmpty
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(
                              ImageHelper.getProductImage(product.primaryImageUrl),
                              width: 50,
                              height: 50,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  width: 50, 
                                  height: 50,
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade200,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Icon(
                                    Icons.image_not_supported,
                                    color: Colors.grey.shade400,
                                  ),
                                );
                              },
                            ),
                          )
                        : Container(
                            width: 50, 
                            height: 50,
                            decoration: BoxDecoration(
                              color: Colors.grey.shade200,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              Icons.image_not_supported,
                              color: Colors.grey.shade400,
                            ),
                          ),
                  ),
                  DataCell(
                    Text(
                      product.name,
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                  ),
                  DataCell(
                    Text(
                      currencyFormat.format(product.price),
                      style: TextStyle(color: Colors.indigo.shade700),
                    ),
                  ),
                  DataCell(
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: product.discountPercent > 0
                            ? Colors.red.shade50
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(12),
                        border: product.discountPercent > 0
                            ? Border.all(color: Colors.red.shade200)
                            : null,
                      ),
                      child: Text(
                        '${product.discountPercent.toStringAsFixed(0)}%',
                        style: TextStyle(
                          color: product.discountPercent > 0
                              ? Colors.red.shade700
                              : Colors.grey.shade700,
                          fontWeight: product.discountPercent > 0
                              ? FontWeight.bold
                              : FontWeight.normal,
                        ),
                      ),
                    ),
                  ),
                  DataCell(
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: product.quantity > 10
                            ? Colors.green.shade50
                            : (product.quantity > 0
                                ? Colors.orange.shade50
                                : Colors.red.shade50),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: product.quantity > 10
                              ? Colors.green.shade200
                              : (product.quantity > 0
                                  ? Colors.orange.shade200
                                  : Colors.red.shade200),
                        ),
                      ),
                      child: Text(
                        '${product.quantity}',
                        style: TextStyle(
                          color: product.quantity > 10
                              ? Colors.green.shade700
                              : (product.quantity > 0
                                  ? Colors.orange.shade700
                                  : Colors.red.shade700),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  DataCell(
                    Text(
                      '${product.soldCount}',
                      style: TextStyle(
                        color: product.soldCount > 0
                            ? Colors.indigo.shade600
                            : Colors.grey.shade600,
                      ),
                    ),
                  ),
                  DataCell(
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        product.brand['name'] ?? 'Không có',
                        style: TextStyle(
                          color: Colors.blue.shade700,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ),
                  DataCell(
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.purple.shade50,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        product.productType['name'] ?? 'Không có',
                        style: TextStyle(
                          color: Colors.purple.shade700,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ),
                  DataCell(
                    Row(
                      children: [
                        IconButton(
                          icon: Icon(
                            Icons.edit,
                            color: Colors.blue.shade600,
                          ),
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
                          icon: Icon(
                            Icons.delete,
                            color: Colors.red.shade600,
                          ),
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
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, Product product) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: Colors.red.shade500),
              const SizedBox(width: 10),
              const Text('Xác nhận xóa'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Bạn có chắc chắn muốn xóa sản phẩm:'),
              const SizedBox(height: 8),
              Text(
                product.name,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 16),
              Text(
                'Hành động này không thể hoàn tác.',
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontStyle: FontStyle.italic,
                  fontSize: 13,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(
                'Hủy',
                style: TextStyle(color: Colors.grey.shade700),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.of(context).pop();
                
                final productProvider = Provider.of<ProductProvider>(context, listen: false);
                final success = await productProvider.deleteProduct(product.id);
                
                if (success && context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Row(
                        children: [
                          const Icon(Icons.check_circle, color: Colors.white),
                          const SizedBox(width: 16),
                          const Text('Xóa sản phẩm thành công'),
                        ],
                      ),
                      backgroundColor: Colors.green.shade600,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      margin: const EdgeInsets.all(16),
                    ),
                  );
                } else if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Row(
                        children: [
                          const Icon(Icons.error_outline, color: Colors.white),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Text('Lỗi: ${productProvider.errorMessage}'),
                          ),
                        ],
                      ),
                      backgroundColor: Colors.red.shade600,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      margin: const EdgeInsets.all(16),
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.shade600,
                foregroundColor: Colors.white,
              ),
              child: const Text('Xóa'),
            ),
          ],
        );
      },
    );
  }
}