import 'dart:async';
import 'package:flutter/material.dart';
import 'package:frontend_admin/core/utils/image_helper.dart';
import 'package:frontend_admin/features/products_management/screens/product_form_screen.dart';
import 'package:frontend_admin/features/products_management/screens/product_types_tab.dart';
import 'package:frontend_admin/features/products_management/screens/brands_tab.dart';
import 'package:frontend_admin/features/products_management/screens/tags_tab.dart';
import 'package:frontend_admin/models/product_model.dart';
import 'package:frontend_admin/providers/product_provider.dart';
import 'package:frontend_admin/providers/brand_provider.dart';
import 'package:frontend_admin/providers/product_type_provider.dart';
import 'package:frontend_admin/providers/tag_provider.dart';
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
  
  // Biến cho lọc và sắp xếp
  String? _selectedBrandId;
  String? _selectedTypeId;
  String? _selectedTagId;
  ProductSortField _sortField = ProductSortField.createdAt;
  SortDirection _sortDirection = SortDirection.desc;
  
  // Debounce cho tìm kiếm
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _tabController.addListener(_handleTabSelection);
    
    // Gọi API để lấy danh sách sản phẩm, brands và product types khi màn hình được khởi tạo
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final productProvider = Provider.of<ProductProvider>(context, listen: false);
      final brandProvider = Provider.of<BrandProvider>(context, listen: false);
      final typeProvider = Provider.of<ProductTypeProvider>(context, listen: false);
      final tagProvider = Provider.of<TagProvider>(context, listen: false);
      
      productProvider.setSorting(ProductSortField.createdAt, SortDirection.desc); // Sắp xếp mặc định theo thời gian tạo
      
      // Tải dữ liệu từ tất cả các providers để đảm bảo bộ lọc hiển thị đầy đủ
      await Future.wait([
        brandProvider.fetchBrands(),
        typeProvider.fetchProductTypes(),
        tagProvider.fetchTags(),
      ]);
      
      // Tải sản phẩm sau khi các bộ lọc đã sẵn sàng
      await productProvider.fetchProducts();
    });
    
    // Thêm listener cho thanh tìm kiếm
    _searchController.addListener(_onSearchChanged);
  }
  
  void _onSearchChanged() {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      // Chỉ tìm kiếm khi có ít nhất 2 ký tự
      if (_searchController.text.length >= 2) {
        _searchProducts();
      } else if (_searchController.text.isEmpty) {
        _clearSearch();
      }
    });
  }

  void _handleTabSelection() {
    // Khi tab thay đổi, cập nhật lại state để cập nhật UI (ví dụ: hiển thị/ẩn floatingActionButton)
    setState(() {});
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    _tabController.removeListener(_handleTabSelection);
    _tabController.dispose();
    _debounce?.cancel();
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
    Provider.of<ProductProvider>(context, listen: false).resetFilters();
  }
  
  void _filterByBrand(String brandId) {
    setState(() {
      _selectedBrandId = brandId;
      _selectedTypeId = null;
      _selectedTagId = null;
    });
    Provider.of<ProductProvider>(context, listen: false).getProductsByBrand(brandId);
  }
  
  void _filterByType(String typeId) {
    setState(() {
      _selectedTypeId = typeId;
      _selectedBrandId = null;
      _selectedTagId = null;
    });
    Provider.of<ProductProvider>(context, listen: false).getProductsByType(typeId);
  }
  
  void _filterByTag(String tagId) {
    setState(() {
      _selectedTagId = tagId;
      _selectedBrandId = null;
      _selectedTypeId = null;
    });
    Provider.of<ProductProvider>(context, listen: false).getProductsByTag(tagId);
  }
  
  void _setSorting(ProductSortField field, SortDirection direction) {
    setState(() {
      _sortField = field;
      _sortDirection = direction;
    });
    Provider.of<ProductProvider>(context, listen: false).setSorting(field, direction);
  }
  
  void _resetFilters() {
    setState(() {
      _selectedBrandId = null;
      _selectedTypeId = null;
      _selectedTagId = null;
      _searchController.clear();
    });
    Provider.of<ProductProvider>(context, listen: false).resetFilters();
  }
  
  // Phương thức chuyển trang
  void _goToPage(int page) {
    Provider.of<ProductProvider>(context, listen: false).goToPage(page);
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
                _showProductFormDialog(context);
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
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
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
                  // Tìm kiếm tự động khi gõ, không cần nhấn Enter
                  // onSubmitted: (_) => _searchProducts(),
                ),
              ),
              const SizedBox(width: 10),
              Consumer<ProductProvider>(
                builder: (context, provider, child) {
                  return ElevatedButton.icon(
                    onPressed: _resetFilters,
                    icon: const Icon(Icons.refresh),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.indigo.shade500,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    label: Text(provider.currentPage > 0 || 
                                provider.currentBrandId != null || 
                                provider.currentTypeId != null || 
                                provider.currentTagId != null ? 
                                'Làm mới' : 'Tải lại'),
                  );
                }
              ),
            ],
          ),
        ),
        
        // Filters bar
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
          child: _buildFiltersBar(),
        ),
        
        // Sort bar
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
          child: _buildSortBar(),
        ),
        
        // Product list
        Expanded(
          child: _buildBody(),
        ),
        
        // Pagination
        Padding(
          padding: const EdgeInsets.all(16),
          child: _buildPagination(),
        ),
      ],
    );
  }
  
  Widget _buildFiltersBar() {
    // Sử dụng Consumer để truy cập Brand và ProductType Provider
    return Consumer<BrandProvider>(
      builder: (context, brandProvider, _) {
        return Consumer<ProductTypeProvider>(
          builder: (context, typeProvider, _) {
            return Consumer<TagProvider>(
              builder: (context, tagProvider, _) {
                return SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      // Brand filter
                      if (brandProvider.brands.isNotEmpty)
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.grey.shade300),
                            color: Colors.grey.shade50,
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          margin: const EdgeInsets.only(right: 8),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String?>(
                              value: _selectedBrandId,
                              hint: const Text('Thương hiệu'),
                              icon: const Icon(Icons.arrow_drop_down, color: Colors.indigo),
                              items: [
                                const DropdownMenuItem<String?>(
                                  value: null,
                                  child: Text('Tất cả thương hiệu'),
                                ),
                                ...brandProvider.brands.map((brand) => DropdownMenuItem<String?>(
                                  value: brand.id,
                                  child: Text(brand.name),
                                )).toList(),
                              ],
                              onChanged: (value) {
                                if (value != null) {
                                  _filterByBrand(value);
                                } else {
                                  _resetFilters();
                                }
                              },
                            ),
                          ),
                        ),
                      
                      // Product type filter
                      if (typeProvider.productTypes.isNotEmpty)
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.grey.shade300),
                            color: Colors.grey.shade50,
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          margin: const EdgeInsets.only(right: 8),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String?>(
                              value: _selectedTypeId,
                              hint: const Text('Loại sản phẩm'),
                              icon: const Icon(Icons.arrow_drop_down, color: Colors.indigo),
                              items: [
                                const DropdownMenuItem<String?>(
                                  value: null,
                                  child: Text('Tất cả loại'),
                                ),
                                ...typeProvider.productTypes.map((type) => DropdownMenuItem<String?>(
                                  value: type.id,
                                  child: Text(type.name),
                                )).toList(),
                              ],
                              onChanged: (value) {
                                if (value != null) {
                                  _filterByType(value);
                                } else {
                                  _resetFilters();
                                }
                              },
                            ),
                          ),
                        ),
                      
                      // Tag filter
                      if (tagProvider.tags.isNotEmpty)
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.grey.shade300),
                            color: Colors.grey.shade50,
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          margin: const EdgeInsets.only(right: 8),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String?>(
                              value: _selectedTagId,
                              hint: const Text('Nhãn'),
                              icon: const Icon(Icons.arrow_drop_down, color: Colors.indigo),
                              items: [
                                const DropdownMenuItem<String?>(
                                  value: null,
                                  child: Text('Tất cả nhãn'),
                                ),
                                ...tagProvider.tags.map((tag) {
                                  // Chuyển đổi màu từ hex sang Color
                                  Color tagColor;
                                  try {
                                    tagColor = Color(int.parse(tag.color.replaceFirst('#', '0xFF')));
                                  } catch (e) {
                                    tagColor = Colors.grey;
                                  }
                                  
                                  return DropdownMenuItem<String?>(
                                    value: tag.id,
                                    child: Row(
                                      children: [
                                        Container(
                                          width: 12,
                                          height: 12,
                                          decoration: BoxDecoration(
                                            color: tagColor,
                                            shape: BoxShape.circle,
                                          ),
                                          margin: const EdgeInsets.only(right: 8),
                                        ),
                                        Text(tag.name),
                                      ],
                                    ),
                                  );
                                }).toList(),
                              ],
                              onChanged: (value) {
                                if (value != null) {
                                  _filterByTag(value);
                                } else {
                                  _resetFilters();
                                }
                              },
                            ),
                          ),
                        ),
                    ],
                  ),
                );
              }
            );
          }
        );
      }
    );
  }
  
  Widget _buildSortBar() {
    return Row(
      children: [
        Text(
          'Sắp xếp theo:',
          style: TextStyle(
            fontWeight: FontWeight.w500,
            color: Colors.grey.shade700,
          ),
        ),
        const SizedBox(width: 12),
        
        // Dropdown for sort field
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey.shade300),
            color: Colors.grey.shade50,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          margin: const EdgeInsets.only(right: 8),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<ProductSortField>(
              value: _sortField,
              icon: const Icon(Icons.arrow_drop_down, color: Colors.indigo),
              items: [
                DropdownMenuItem(
                  value: ProductSortField.createdAt,
                  child: const Text('Ngày tạo'),
                ),
                DropdownMenuItem(
                  value: ProductSortField.name,
                  child: const Text('Tên sản phẩm'),
                ),
                DropdownMenuItem(
                  value: ProductSortField.price,
                  child: const Text('Giá'),
                ),
                DropdownMenuItem(
                  value: ProductSortField.quantity,
                  child: const Text('Số lượng'),
                ),
                DropdownMenuItem(
                  value: ProductSortField.soldCount,
                  child: const Text('Đã bán'),
                ),
              ],
              onChanged: (value) {
                if (value != null) {
                  _setSorting(value, _sortDirection);
                }
              },
            ),
          ),
        ),
        
        // Sort direction button
        InkWell(
          onTap: () {
            final newDirection = _sortDirection == SortDirection.asc ? SortDirection.desc : SortDirection.asc;
            _setSorting(_sortField, newDirection);
          },
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey.shade300),
              color: Colors.grey.shade50,
            ),
            child: Row(
              children: [
                Icon(
                  _sortDirection == SortDirection.asc ? Icons.arrow_upward : Icons.arrow_downward,
                  size: 16,
                  color: Colors.indigo,
                ),
                const SizedBox(width: 4),
                Text(
                  _sortDirection == SortDirection.asc ? 'Tăng dần' : 'Giảm dần',
                  style: const TextStyle(color: Colors.indigo),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
  
  Widget _buildPagination() {
    return Consumer<ProductProvider>(
      builder: (context, provider, child) {
        if (provider.totalPages <= 1) {
          return const SizedBox.shrink();
        }
        
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Previous page button
            IconButton(
              icon: const Icon(Icons.chevron_left),
              onPressed: provider.currentPage > 0 
                  ? () => _goToPage(provider.currentPage - 1) 
                  : null,
              color: Colors.indigo,
              disabledColor: Colors.grey.shade400,
            ),
            
            // Page numbers
            for (int i = 0; i < provider.totalPages; i++)
              if (i == 0 || i == provider.totalPages - 1 || 
                  (i >= provider.currentPage - 2 && i <= provider.currentPage + 2))
                InkWell(
                  onTap: i != provider.currentPage ? () => _goToPage(i) : null,
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 2),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: i == provider.currentPage ? Colors.indigo : Colors.transparent,
                    ),
                    child: Text(
                      (i + 1).toString(),
                      style: TextStyle(
                        color: i == provider.currentPage ? Colors.white : Colors.indigo,
                        fontWeight: i == provider.currentPage ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  ),
                )
              else if ((i == 1 && provider.currentPage - 2 > 1) || 
                       (i == provider.totalPages - 2 && provider.currentPage + 2 < provider.totalPages - 2))
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Text(
                    '...',
                    style: TextStyle(color: Colors.grey.shade700),
                  ),
                ),
                
            // Next page button
            IconButton(
              icon: const Icon(Icons.chevron_right),
              onPressed: provider.currentPage < provider.totalPages - 1 
                  ? () => _goToPage(provider.currentPage + 1) 
                  : null,
              color: Colors.indigo,
              disabledColor: Colors.grey.shade400,
            ),
          ],
        );
      },
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
      margin: const EdgeInsets.fromLTRB(8, 0, 8, 8),
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
      child: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: ConstrainedBox(
              constraints: BoxConstraints(minWidth: constraints.maxWidth),
              child: SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: DataTable(
                  dataRowMinHeight: 60,
                  dataRowMaxHeight: 100,
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
                        'Ngày tạo',
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
                        'Thẻ',
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
                          Text(
                            product.createdAt != null 
                                ? DateFormat('dd/MM/yyyy').format(product.createdAt!)
                                : 'N/A',
                            style: TextStyle(
                              color: Colors.indigo.shade700,
                              fontSize: 13,
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
                          (product.tags.isEmpty)
                          ? const Text('-', 
                              style: TextStyle(color: Colors.grey),
                            )
                          : Wrap(
                              spacing: 4,
                              runSpacing: 4,
                              children: product.tags.map((tag) {
                                final tagName = tag['name'] ?? 'Không rõ';
                                final tagColor = tag['color'] ?? '#D3D3D3';
                                
                                Color backgroundColor;
                                try {
                                  backgroundColor = Color(int.parse(tagColor.replaceFirst('#', '0xFF')));
                                } catch (e) {
                                  backgroundColor = Colors.grey.shade200;
                                }
                                
                                // Tính màu text dựa vào độ sáng của background
                                final double luminance = backgroundColor.computeLuminance();
                                final Color textColor = luminance > 0.5 ? Colors.black : Colors.white;
                                
                                return Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: backgroundColor,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    tagName,
                                    style: TextStyle(
                                      color: textColor,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                );
                              }).toList(),
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
                                  _showEditProductDialog(context, product);
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

  void _showProductFormDialog(BuildContext context) {
    // Kiểm tra kích thước màn hình để quyết định sử dụng dialog hay full screen
    final size = MediaQuery.of(context).size;
    
    if (size.width > 1000) {
      // Màn hình lớn: hiển thị dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Container(
            constraints: BoxConstraints(
              maxWidth: 900,
              maxHeight: MediaQuery.of(context).size.height * 0.85,
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: const ProductFormScreen(),
            ),
          ),
        ),
      ).then((_) {
        Provider.of<ProductProvider>(context, listen: false).fetchProducts();
      });
    } else {
      // Màn hình nhỏ: hiển thị full screen
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => const ProductFormScreen(),
        ),
      ).then((_) {
        Provider.of<ProductProvider>(context, listen: false).fetchProducts();
      });
    }
  }
  
  void _showEditProductDialog(BuildContext context, Product product) {
    // Kiểm tra kích thước màn hình để quyết định sử dụng dialog hay full screen
    final size = MediaQuery.of(context).size;
    
    if (size.width > 1000) {
      // Màn hình lớn: hiển thị dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Container(
            constraints: BoxConstraints(
              maxWidth: 900,
              maxHeight: MediaQuery.of(context).size.height * 0.85,
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: ProductFormScreen(
                product: product,
                isEditing: true,
              ),
            ),
          ),
        ),
      ).then((_) {
        Provider.of<ProductProvider>(context, listen: false).fetchProducts();
      });
    } else {
      // Màn hình nhỏ: hiển thị full screen
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => ProductFormScreen(
            product: product,
            isEditing: true,
          ),
        ),
      ).then((_) {
        Provider.of<ProductProvider>(context, listen: false).fetchProducts();
      });
    }
  }
}