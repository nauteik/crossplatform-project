import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/product_provider.dart';
import '../../providers/product_type_provider.dart';
import '../widgets/product_card.dart';
import '../widgets/product_type_card.dart';
import 'package:intl/intl.dart';
import '../../../../data/model/product_type_model.dart';
import '../widgets/category_screen/filter_bar_widget.dart';
import '../widgets/category_screen/desktop_filter_bar_widget.dart';
import '../widgets/category_screen/filter_sidebar_widget.dart';
import '../widgets/category_screen/product_type_grid_widget.dart';

class ProductCategoryScreen extends StatefulWidget {
  final String? initialSearchQuery;
  
  const ProductCategoryScreen({
    super.key, 
    this.initialSearchQuery,
  });

  @override
  State<ProductCategoryScreen> createState() => _ProductCategoryScreenState();
}

class _ProductCategoryScreenState extends State<ProductCategoryScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  final Set<String> _selectedProductTypes = {};
  final Set<String> _selectedBrands = {};
  final Set<String> _selectedTags = {};
  RangeValues _priceRange = const RangeValues(0, 100000000);
  String _sortBy = 'relevance';
  final double _minPrice = 0;
  final double _maxPrice = 100000000;
  bool _showProductTypeGrid = true; // Biến để kiểm soát hiển thị lưới loại sản phẩm
  
  // Thêm ScrollController để xử lý phân trang
  final ScrollController _scrollController = ScrollController();
  
  @override
  void initState() {
    super.initState();
    
    // Khởi tạo _searchController với initialSearchQuery nếu có
    if (widget.initialSearchQuery != null && widget.initialSearchQuery!.isNotEmpty) {
      _searchController.text = widget.initialSearchQuery!;
      _searchQuery = widget.initialSearchQuery!;
      _showProductTypeGrid = false; // Ẩn lưới loại sản phẩm nếu có tìm kiếm ban đầu
    }
    
    _initData();
    _searchController.addListener(_onSearchChanged);
    
    // Thêm listener cho ScrollController để xử lý tải thêm sản phẩm
    _scrollController.addListener(_scrollListener);
    
    // Áp dụng tìm kiếm nếu có initialSearchQuery
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.initialSearchQuery != null && widget.initialSearchQuery!.isNotEmpty) {
        _applyFilters();
      }
    });
  }
  
  void _scrollListener() {
    final productProvider = Provider.of<ProductProvider>(context, listen: false);
    
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200 &&
        !productProvider.isLoadingMore &&
        productProvider.hasMoreData &&
        !_showProductTypeGrid) {
      // Sử dụng try-catch để bắt lỗi khi tải thêm sản phẩm
      productProvider.loadMoreProducts().then((_) {
        // Áp dụng bộ lọc và tìm kiếm sau khi đã tải thêm sản phẩm
        _filterAndSearchProducts();
      }).catchError((error) {
        // Hiển thị thông báo lỗi nếu cần
       
      });
    }
  }
  
  Future<void> _initData() async {
    final productProvider = Provider.of<ProductProvider>(context, listen: false);
    final typeProvider = Provider.of<ProductTypeProvider>(context, listen: false);
    
    try {
      if (typeProvider.productTypes.isEmpty) {
        await typeProvider.fetchProductTypes();
      }
      
      if (productProvider.products.isEmpty) {
        // Sử dụng phương thức fetchPagedProducts thay vì fetchProducts
        await productProvider.fetchPagedProducts();
      }
    } catch (e) {
      // Hiển thị thông báo lỗi
      
    }
  }
  
  void _applyFilters() {
    final productProvider = Provider.of<ProductProvider>(context, listen: false);
    
    // Nếu đang ở chế độ hiển thị lưới sản phẩm (không phải lưới loại sản phẩm)
    if (!_showProductTypeGrid) {
      // Chỉ tải lại danh sách sản phẩm nếu chưa có dữ liệu hoặc đang ở trạng thái lỗi
      if (productProvider.products.isEmpty || productProvider.status == ProductStatus.error) {
        productProvider.fetchPagedProducts().then((_) {
          // Áp dụng bộ lọc và tìm kiếm sau khi đã tải danh sách sản phẩm
          _filterAndSearchProducts();
        });
      } else {
        // Nếu đã có dữ liệu, chỉ cần lọc và tìm kiếm trên dữ liệu đã có
        _filterAndSearchProducts();
      }
    }
    
    // Ẩn lưới loại sản phẩm khi đã chọn bộ lọc hoặc đang tìm kiếm
    if (_selectedProductTypes.isNotEmpty || _selectedBrands.isNotEmpty || _searchQuery.isNotEmpty) {
      setState(() {
        _showProductTypeGrid = false;
      });
    }
  }
  
  void _filterAndSearchProducts() {
    final productProvider = Provider.of<ProductProvider>(context, listen: false);
    
    // Nếu không có sản phẩm, không cần lọc
    if (productProvider.products.isEmpty) {
      return;
    }
    
    List<dynamic> filteredProducts = [...productProvider.products];
    
    // Lọc theo loại sản phẩm
    if (_selectedProductTypes.isNotEmpty) {
      filteredProducts = filteredProducts.where((product) => 
        product.productType != null && 
        _selectedProductTypes.contains(product.productType['id'])).toList();
    }
    
    // Lọc theo khoảng giá
    filteredProducts = filteredProducts.where((product) {
      final price = product.price.toDouble();
      return price >= _priceRange.start && price <= _priceRange.end;
    }).toList();
    
    // Lọc theo thương hiệu
    if (_selectedBrands.isNotEmpty) {
      filteredProducts = filteredProducts.where((product) => 
        product.brand != null && 
        _selectedBrands.contains(product.brand['id'])).toList();
    }
    
    // Lọc theo tag - chỉ lấy các sản phẩm có tag được chọn và tag đó phải có active=true
    if (_selectedTags.isNotEmpty) {
      filteredProducts = filteredProducts.where((product) {
        if (product.tags == null || product.tags.isEmpty) {
          return false;
        }
        
        // Kiểm tra xem sản phẩm có chứa ít nhất một tag đã chọn và tag đó phải có active=true
        return product.tags.any((tag) {
          if (tag is Map<String, dynamic> && 
              tag.containsKey('id') && 
              tag.containsKey('active') && 
              tag['active'] == true) {
            return _selectedTags.contains(tag['id'].toString());
          }
          return false;
        });
      }).toList();
    }
    
    // Tìm kiếm theo từ khóa
    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase().trim();
      filteredProducts = filteredProducts.where((product) {
        final name = product.name.toLowerCase();
        final description = product.description != null ? product.description.toLowerCase() : '';
        final brandName = product.brand != null ? product.brand['name'].toLowerCase() : '';
        
        return name.contains(query) || 
               description.contains(query) || 
               brandName.contains(query);
      }).toList();
    }
    
    // Sắp xếp sản phẩm
    switch (_sortBy) {
      case 'price_asc':
        filteredProducts.sort((a, b) => a.price.compareTo(b.price));
        break;
      case 'price_desc':
        filteredProducts.sort((a, b) => b.price.compareTo(a.price));
        break;
      case 'name_asc':
        filteredProducts.sort((a, b) => a.name.compareTo(b.name));
        break;
      case 'name_desc':
        filteredProducts.sort((a, b) => b.name.compareTo(a.name));
        break;
      case 'rating_desc':
        filteredProducts.sort((a, b) {
          final aRating = a.averageRating ?? 0.0;
          final bRating = b.averageRating ?? 0.0;
          return bRating.compareTo(aRating);
        });
        break;
      case 'rating_asc':
        filteredProducts.sort((a, b) {
          final aRating = a.averageRating ?? 0.0;
          final bRating = b.averageRating ?? 0.0;
          return aRating.compareTo(bRating);
        });
        break;
      case 'created_desc':
        filteredProducts.sort((a, b) {
          final aCreated = a.createdAt ?? 0;
          final bCreated = b.createdAt ?? 0;
          return bCreated.compareTo(aCreated);
        });
        break;
      case 'created_asc':
        filteredProducts.sort((a, b) {
          final aCreated = a.createdAt ?? 0;
          final bCreated = b.createdAt ?? 0;
          return aCreated.compareTo(bCreated);
        });
        break;
      case 'relevance':
      default:
        // Giữ nguyên thứ tự
        break;
    }
    
    // Cập nhật danh sách sản phẩm đã lọc
    productProvider.setFilteredProducts(filteredProducts);
  }

  void _onSearchChanged() {
    if (_searchController.text != _searchQuery) {
      setState(() {
        _searchQuery = _searchController.text;
        if (_searchQuery.isNotEmpty) {
          _showProductTypeGrid = false;
        }
      });
      _applyFilters();
    }
  }

  void _handleProductTypeSelection(String typeId) {
    setState(() {
      if (_selectedProductTypes.contains(typeId)) {
        _selectedProductTypes.remove(typeId);
      } else {
        _selectedProductTypes.add(typeId);
      }
      
      if (_selectedProductTypes.isNotEmpty) {
        _showProductTypeGrid = false;
        _applyFilters();
      } else if (_selectedProductTypes.isEmpty && _selectedBrands.isEmpty && _searchQuery.isEmpty && !_showProductTypeGrid) {
        _showProductTypeGrid = true;
      }
    });
  }

  String _getProductTypeName(String typeId, ProductTypeProvider typeProvider) {
    final type = typeProvider.productTypes.firstWhere(
      (type) => type.id == typeId,
      orElse: () => ProductTypeModel(id: typeId, name: 'Unknown'),
    );
    return type.name;
  }

  List<dynamic> _getBrands(List<dynamic> products) {
    if (products.isEmpty) return [];
    
    final brandSet = <String>{};
    final brandMap = <String, dynamic>{};
    
    for (var product in products) {
      if (product.brand != null && product.brand['id'] != null) {
        final brandId = product.brand['id'].toString();
        if (!brandSet.contains(brandId)) {
          brandSet.add(brandId);
          brandMap[brandId] = product.brand;
        }
      }
    }
    
    return brandMap.values.toList();
  }
  
  // Phương thức mới để đảm bảo brands được tải đúng cách
  Future<List<dynamic>> _ensureBrandsLoaded(BuildContext context) async {
    final productProvider = Provider.of<ProductProvider>(context, listen: false);
    
    // Kiểm tra xem products đã được tải chưa
    if (productProvider.products.isEmpty && productProvider.status != ProductStatus.loading) {
      // Nếu chưa, thực hiện fetch products
      await productProvider.fetchPagedProducts();
    }
    
    // Lấy danh sách brands từ products
    return _getBrands(productProvider.products);
  }

  Widget _buildErrorView(String title) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 48, color: Colors.red[300]),
            const SizedBox(height: 16),
            Text(
              title,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
  @override
  Widget build(BuildContext context) {
    final productProvider = Provider.of<ProductProvider>(context);
    final typeProvider = Provider.of<ProductTypeProvider>(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Danh mục sản phẩm'),
        backgroundColor: Colors.blue,
        actions: [
          if (!_showProductTypeGrid)
            IconButton(
              icon: const Icon(Icons.grid_view),
              onPressed: () {
                setState(() {
                  _showProductTypeGrid = true;
                });
              },
              tooltip: 'Xem loại sản phẩm',
            ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              constraints: const BoxConstraints(maxWidth: 1200),
              width: double.infinity,
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Tìm kiếm sản phẩm',
                  filled: true,
                  fillColor: Colors.white,
                  suffixIcon: _searchController.text.isEmpty
                    ? const Icon(Icons.search)
                    : IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          // Xóa nội dung tìm kiếm
                          _searchController.clear();
                        },
                      ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none,
                  ),
                ),
                // Đã loại bỏ onSubmitted vì đã sử dụng listener trong initState
              ),
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final width = constraints.maxWidth;
            
            // Điều chỉnh số cột dựa trên chiều rộng màn hình
            int productColumns;
            int typeColumns;
            
            // Khai báo biến containerWidth để điều chỉnh độ rộng của container
            double containerWidth = width;
            
            if (width >= 1400) {
              productColumns = 6;
              typeColumns = 8;
            } else if (width >= 1100) {
              productColumns = 5;
              typeColumns = 7;
            } else if (width >= 900) {
              productColumns = 4;
              typeColumns = 6;
            } else if (width >= 700) {
              productColumns = 3;
              typeColumns = 5;
              // Điều chỉnh độ rộng container cho 3 cột
              containerWidth = width * 0.9;
            } else if (width >= 500) {
              productColumns = 3;
              typeColumns = 4;
              // Điều chỉnh độ rộng container cho 3 cột
              containerWidth = width * 0.95;
            } else {
              productColumns = 2;
              typeColumns = 2;
              // Không cần điều chỉnh độ rộng container cho 2 cột
            }
            
            final isDesktop = width >= 1200;
            final isTablet = width >= 600 && width < 1200;
            final isMobile = width < 600;
            
            Widget contentWithConstraints(Widget child) {
             return Center(
                child: Container(
                  constraints: BoxConstraints(maxWidth: isDesktop ? 1200 : containerWidth),
                  width: double.infinity,
                  child: child,
                ),
              );
            }
            
            if (isMobile) {
              return contentWithConstraints(
                Column(
                  children: [
                    if (!_showProductTypeGrid) 
                      FilterBarWidget(
                        selectedProductTypes: _selectedProductTypes,
                        selectedBrands: _selectedBrands,
                        priceRange: _priceRange,
                        minPrice: _minPrice,
                        maxPrice: _maxPrice,
                        showProductTypeGrid: _showProductTypeGrid,
                        onClearFilters: () {
                          setState(() {
                            _selectedProductTypes.clear();
                            _selectedBrands.clear();
                            _priceRange = RangeValues(_minPrice, _maxPrice);
                          });
                          _applyFilters();
                        },
                        onRemoveProductType: (typeId) {
                          setState(() {
                            _selectedProductTypes.remove(typeId);
                          });
                          if (_selectedProductTypes.isEmpty && _selectedBrands.isEmpty) {
                            setState(() {
                              _showProductTypeGrid = true;
                            });
                          } else {
                            _applyFilters();
                          }
                        },
                        showFilterDialog: () => _showFilterDialog(context),
                        showSortDialog: () => _showSortDialog(context),
                      ),
                    Expanded(
                      child: _showProductTypeGrid
                          ? ProductTypeGridWidget(
                              typeProvider: typeProvider,
                              crossAxisCount: 2,
                              selectedProductTypes: _selectedProductTypes,
                              onProductTypeSelected: _handleProductTypeSelection,
                            )
                          : productProvider.status == ProductStatus.loading
                              ? const Center(child: CircularProgressIndicator())
                              : productProvider.status == ProductStatus.error
                                  ? _buildErrorView(
                                      'Không thể tải sản phẩm'
                                      )
                                  : _buildProductGrid(productProvider.getFilteredProducts(), crossAxisCount: 2),
                    ),
                  ],
                ),
              );
            } 
            else if (isTablet) {
              return contentWithConstraints(
                Column(
                  children: [
                    if (!_showProductTypeGrid) 
                      FilterBarWidget(
                        selectedProductTypes: _selectedProductTypes,
                        selectedBrands: _selectedBrands,
                        priceRange: _priceRange,
                        minPrice: _minPrice,
                        maxPrice: _maxPrice,
                        showProductTypeGrid: _showProductTypeGrid,
                        onClearFilters: () {
                          setState(() {
                            _selectedProductTypes.clear();
                            _selectedBrands.clear();
                            _priceRange = RangeValues(_minPrice, _maxPrice);
                          });
                          _applyFilters();
                        },
                        onRemoveProductType: (typeId) {
                          setState(() {
                            _selectedProductTypes.remove(typeId);
                          });
                          if (_selectedProductTypes.isEmpty && _selectedBrands.isEmpty) {
                            setState(() {
                              _showProductTypeGrid = true;
                            });
                          } else {
                            _applyFilters();
                          }
                        },
                        showFilterDialog: () => _showFilterDialog(context),
                        showSortDialog: () => _showSortDialog(context),
                      ),
                    Expanded(
                      child: _showProductTypeGrid
                          ? ProductTypeGridWidget(
                              typeProvider: typeProvider,
                              crossAxisCount: 4,
                              selectedProductTypes: _selectedProductTypes,
                              onProductTypeSelected: _handleProductTypeSelection,
                            )
                          : productProvider.status == ProductStatus.loading
                              ? const Center(child: CircularProgressIndicator())
                              : productProvider.status == ProductStatus.error
                                  ? _buildErrorView(
                                      'Không thể tải sản phẩm'
                                      )
                                  : _buildProductGrid(productProvider.getFilteredProducts(), crossAxisCount: 3),
                    ),
                  ],
                ),
              );
            } 
            else {
              return contentWithConstraints(
                Row(
                  children: [
                    if (!_showProductTypeGrid) 
                      Container(
                        width: 280,
                        height: MediaQuery.of(context).size.height - AppBar().preferredSize.height - 56,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              spreadRadius: 1,
                              blurRadius: 5,
                            ),
                          ],
                        ),
                        child: FilterSidebarWidget(
                          selectedProductTypes: _selectedProductTypes,
                          selectedBrands: _selectedBrands,
                          selectedTags: _selectedTags,
                          priceRange: _priceRange,
                          minPrice: _minPrice,
                          maxPrice: _maxPrice,
                          brands: _getBrands(productProvider.products),
                          tags: _getTagsFromProducts(productProvider.products),
                          onPriceRangeChanged: (values) {
                            setState(() {
                              _priceRange = values;
                            });
                            _applyFilters();
                          },
                          onProductTypeChanged: (typeId, selected) {
                            if (selected) {
                              setState(() {
                                _selectedProductTypes.add(typeId);
                                _showProductTypeGrid = false;
                              });
                            } else {
                              setState(() {
                                _selectedProductTypes.remove(typeId);
                              });
                            }
                            _applyFilters();
                          },
                          onBrandChanged: (brandId, selected) {
                            if (selected) {
                              setState(() {
                                _selectedBrands.add(brandId);
                              });
                            } else {
                              setState(() {
                                _selectedBrands.remove(brandId);
                              });
                            }
                            _applyFilters();
                          },
                          onTagChanged: (tagId, selected) {
                            if (selected) {
                              setState(() {
                                _selectedTags.add(tagId);
                              });
                            } else {
                              setState(() {
                                _selectedTags.remove(tagId);
                              });
                            }
                            _applyFilters();
                          },
                          onResetFilters: () {
                            setState(() {
                              _selectedProductTypes.clear();
                              _selectedBrands.clear();
                              _selectedTags.clear();
                              _priceRange = RangeValues(_minPrice, _maxPrice);
                            });
                            _applyFilters();
                          },
                        ),
                      ),
                    Expanded(
                      child: Column(
                        children: [
                          if (!_showProductTypeGrid) 
                            DesktopFilterBarWidget(
                              sortBy: _sortBy,
                              productCount: productProvider.getFilteredProducts().length,
                              onBackToCategories: _showProductTypeGrid ? null : () {
                                setState(() {
                                  _showProductTypeGrid = true;
                                });
                              },
                              onChangeSortBy: (String? newValue) {
                                if (newValue != null) {
                                  setState(() {
                                    _sortBy = newValue;
                                  });
                                  _applyFilters();
                                }
                              },
                            ),
                          Expanded(
                            child: _showProductTypeGrid
                                ? ProductTypeGridWidget(
                                    typeProvider: typeProvider,
                                    crossAxisCount: typeColumns,
                                    selectedProductTypes: _selectedProductTypes,
                                    onProductTypeSelected: _handleProductTypeSelection,
                                  )
                                : productProvider.status == ProductStatus.loading
                                    ? const Center(child: CircularProgressIndicator())
                                    : productProvider.status == ProductStatus.error
                                        ? _buildErrorView(
                                            'Không thể tải sản phẩm'
                                            )
                                        : _buildProductGrid(productProvider.getFilteredProducts(), crossAxisCount: productColumns),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }
          },
        ),
      ),
    );
  }
  
  Widget _buildProductGrid(List<dynamic> products, {int crossAxisCount = 2}) {
    if (products.isEmpty) {
      // Kiểm tra nếu đang trong trạng thái lỗi
      final productProvider = Provider.of<ProductProvider>(context);
      if (productProvider.status == ProductStatus.error) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 60, color: Colors.red),
                const SizedBox(height: 16),
                Text(
                  'Không thể tải sản phẩm',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  // Thử lại tải dữ liệu
                  productProvider.fetchPagedProducts().then((_) {
                    _filterAndSearchProducts();
                  }).catchError((error) {
                   
                  });
                },
                child: const Text('Thử lại'),
              ),
            ],
          ),
        );
      }
      
      return const Center(
        child: Text('Không tìm thấy sản phẩm nào phù hợp với bộ lọc của bạn.'),
      );
    }
    
    final productProvider = Provider.of<ProductProvider>(context);
    final width = MediaQuery.of(context).size.width;
    final isSmallScreen = width < 360;
    final isDesktop = width >= 1200;
    
    // Điều chỉnh mainAxisSpacing và crossAxisSpacing theo số cột
    double mainAxisSpacing = isSmallScreen ? 4.0 : 8.0;
    double crossAxisSpacing = isSmallScreen ? 4.0 : 8.0;
    
    // Điều chỉnh khoảng cách cho trường hợp ít cột
    if (crossAxisCount <= 3 && width >= 500) {
      crossAxisSpacing = 12.0;
    }
    
    // Điều chỉnh childAspectRatio dựa trên số cột
    double childAspectRatio;
    if (crossAxisCount <= 2) {
      childAspectRatio = 0.63; // Cho phép nhiều không gian hơn khi hiển thị 2 cột
    } else if (crossAxisCount == 3) {
      childAspectRatio = 0.65; // Cho trường hợp 3 cột
    } else { // For 4+ columns (Desktop)
      childAspectRatio = 0.61; // GIẢM: Tăng chiều cao cho card trên desktop
    }
    
    Widget buildGridContent() {
      return Column(
        children: [
          Expanded(
            child: GridView.builder(
              controller: _scrollController,
              padding: EdgeInsets.all(isSmallScreen ? 4.0 : 8.0),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCount,
                childAspectRatio: childAspectRatio,
                crossAxisSpacing: crossAxisSpacing,
                mainAxisSpacing: mainAxisSpacing,
              ),
              itemCount: products.length,
              itemBuilder: (context, index) {
                final product = products[index];
                return ProductCard(
                  id: product.id,
                  name: product.name,
                  price: product.price.toDouble(),
                  soldCount: product.soldCount ?? 0,
                  discountPercent: product.discountPercent?.toDouble() ?? 0,
                  primaryImageUrl: product.primaryImageUrl ?? '',
                  rating: product.averageRating,
                  tags: product.tags,
                );
              },
            ),
          ),
          
          // Hiển thị loading indicator khi đang tải thêm sản phẩm
          if (productProvider.isLoadingMore)
            Container(
              padding: const EdgeInsets.all(8.0),
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
        ],
      );
    }
    
    if (isDesktop) {
      // Tạo container với chiều rộng thích hợp dựa trên số cột
      double containerMaxWidth = 1200.0;
      if (crossAxisCount <= 3) {
        containerMaxWidth = crossAxisCount * 280.0; // Điều chỉnh chiều rộng dựa trên số cột
      }
      
      return Center(
        child: Container(
          constraints: BoxConstraints(maxWidth: containerMaxWidth),
          width: double.infinity,
          child: buildGridContent(),
        ),
      );
    }
    
    return buildGridContent();
  }
  
  void _showFilterDialog(BuildContext context) {
    final productProvider = Provider.of<ProductProvider>(context, listen: false);
    final typeProvider = Provider.of<ProductTypeProvider>(context, listen: false);
    
    // Sử dụng FutureBuilder để đảm bảo brands được tải trước khi hiển thị dialog
    Future<List<dynamic>> brandsFuture = _ensureBrandsLoaded(context);
    
    // Lấy tất cả tag từ các sản phẩm
    List<Map<String, dynamic>> tagsList = _getTagsFromProducts(productProvider.products);
    
    final isDesktop = MediaQuery.of(context).size.width >= 1200;
    final isTablet = MediaQuery.of(context).size.width >= 600 && MediaQuery.of(context).size.width < 1200;
    
    if (isDesktop || isTablet) {
      showDialog(
        context: context,
        builder: (context) {
          return FutureBuilder<List<dynamic>>(
            future: brandsFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const AlertDialog(
                  content: Center(child: CircularProgressIndicator()),
                );
              }
              
              final brands = snapshot.data ?? [];
              
              return StatefulBuilder(
                builder: (context, setState) {
                  final currencyFormatter = NumberFormat.currency(locale: 'vi_VN', symbol: '₫', decimalDigits: 0);
                  
                  return AlertDialog(
                    title: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Lọc sản phẩm'),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                    content: SizedBox(
                      width: isDesktop ? 800 : (isTablet ? 500 : double.infinity),
                      height: isDesktop ? 600 : (isTablet ? 500 : double.infinity),
                      child: isDesktop 
                        ? Row( // Desktop: Two columns
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: SingleChildScrollView(
                              physics: const AlwaysScrollableScrollPhysics(),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                      _buildProductTypeFilters(typeProvider, setState),
                                      _buildPriceRangeFilter(currencyFormatter, setState),
                                      _buildTagsFilter(tagsList, setState),
                                    ],
                                  ),
                                ),
                              ),
                              const VerticalDivider(),
                            Expanded(
                              child: SingleChildScrollView(
                                physics: const AlwaysScrollableScrollPhysics(),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                      _buildBrandFilters(brands, setState),
                                  ],
                                ),
                              ),
                            ),
                            ],
                          )
                        : SingleChildScrollView( // Tablet: Single column for all filters
                            physics: const AlwaysScrollableScrollPhysics(),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildProductTypeFilters(typeProvider, setState),
                                _buildPriceRangeFilter(currencyFormatter, setState),
                                _buildBrandFilters(brands, setState), // Brands added here for tablet
                                _buildTagsFilter(tagsList, setState), // Tags after brands for tablet
                              ],
                            ),
                      ),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () {
                          setState(() {
                            _selectedProductTypes.clear();
                            _selectedBrands.clear();
                            _selectedTags.clear(); // Xóa các tags đã chọn
                            _priceRange = RangeValues(_minPrice, _maxPrice);
                          });
                        },
                        child: const Text('Đặt lại'),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                          _applyFilters();
                        },
                        child: const Text('Áp dụng'),
                      ),
                    ],
                  );
                },
              );
            },
          );
        },
      );
    } else {
      // Mobile screen
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        builder: (context) {
          return FutureBuilder<List<dynamic>>(
            future: brandsFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              
              final brands = snapshot.data ?? [];
              
              return StatefulBuilder(
                builder: (context, setState) {
                  final currencyFormatter = NumberFormat.currency(locale: 'vi_VN', symbol: '₫', decimalDigits: 0);
                  
                  return Container(
                    padding: const EdgeInsets.all(16),
                    height: MediaQuery.of(context).size.height * 0.8,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Lọc sản phẩm',
                              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                            ),
                            IconButton(
                              icon: const Icon(Icons.close),
                              onPressed: () => Navigator.pop(context),
                            ),
                          ],
                        ),
                        
                        Expanded(
                          child: ListView(
                            physics: const AlwaysScrollableScrollPhysics(),
                            children: [
                              const Text(
                                'Loại sản phẩm',
                                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 8),
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: typeProvider.productTypes.map((type) {
                                  final isSelected = _selectedProductTypes.contains(type.id);
                                  return FilterChip(
                                    label: Text(type.name),
                                    selected: isSelected,
                                    onSelected: (selected) {
                                      setState(() {
                                        if (selected) {
                                          _selectedProductTypes.add(type.id);
                                        } else {
                                          _selectedProductTypes.remove(type.id);
                                        }
                                      });
                                    },
                                  );
                                }).toList(),
                              ),
                              
                              const SizedBox(height: 16),
                              
                              const Text(
                                'Khoảng giá',
                                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 8),
                              RangeSlider(
                                values: _priceRange,
                                min: _minPrice,
                                max: _maxPrice,
                                divisions: 20,
                                labels: RangeLabels(
                                  currencyFormatter.format(_priceRange.start),
                                  currencyFormatter.format(_priceRange.end),
                                ),
                                onChanged: (RangeValues values) {
                                  setState(() {
                                    _priceRange = values;
                                  });
                                },
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(currencyFormatter.format(_priceRange.start)),
                                  Text(currencyFormatter.format(_priceRange.end)),
                                ],
                              ),
                              
                              // Hiển thị phần thương hiệu cho cả màn hình nhỏ
                              if (brands.isNotEmpty) ...[
                                const SizedBox(height: 16),
                                
                                const Text(
                                  'Thương hiệu',
                                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 8),
                                Wrap(
                                  spacing: 8,
                                  runSpacing: 8,
                                  children: brands.map((brand) {
                                    final brandId = brand['id']?.toString() ?? '';
                                    final isSelected = _selectedBrands.contains(brandId);
                                    return FilterChip(
                                      label: Text(brand['name']?.toString() ?? 'Unknown'),
                                      selected: isSelected,
                                      onSelected: (selected) {
                                        setState(() {
                                          if (selected) {
                                            _selectedBrands.add(brandId);
                                          } else {
                                            _selectedBrands.remove(brandId);
                                          }
                                        });
                                      },
                                    );
                                  }).toList(),
                                ),
                              ],
                              
                              // Thêm phần lọc theo tags cho cả màn hình nhỏ
                              if (tagsList.isNotEmpty) ...[
                                const SizedBox(height: 16),
                                const Text(
                                  'Tags',
                                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 8),
                                Wrap(
                                  spacing: 8,
                                  runSpacing: 8,
                                  children: tagsList.map((tag) {
                                    final tagId = tag['id']?.toString() ?? '';
                                    final tagName = tag['name']?.toString() ?? 'Unknown';
                                    final isSelected = _selectedTags.contains(tagId);
                                    
                                    return FilterChip(
                                      label: Text(tagName),
                                      selected: isSelected,
                                      onSelected: (selected) {
                                        setState(() {
                                          if (selected) {
                                            _selectedTags.add(tagId);
                                          } else {
                                            _selectedTags.remove(tagId);
                                          }
                                        });
                                      },
                                    );
                                  }).toList(),
                                ),
                              ],
                            ],
                          ),
                        ),
                        
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                onPressed: () {
                                  setState(() {
                                    _selectedProductTypes.clear();
                                    _selectedBrands.clear();
                                    _selectedTags.clear(); // Xóa các tags đã chọn
                                    _priceRange = RangeValues(_minPrice, _maxPrice);
                                  });
                                },
                                child: const Text('Đặt lại'),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                  _applyFilters();
                                },
                                child: const Text('Áp dụng'),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          );
        },
      );
    }
  }
  
  // Hàm để lấy tất cả tags từ các sản phẩm
  List<Map<String, dynamic>> _getTagsFromProducts(List<dynamic> products) {
    final Set<String> tagIds = {};
    final List<Map<String, dynamic>> uniqueTags = [];
    
    for (var product in products) {
      if (product.tags != null && product.tags.isNotEmpty) {
        for (var tag in product.tags) {
          if (tag is Map<String, dynamic> && 
              tag.containsKey('id') && 
              tag.containsKey('name') && 
              tag.containsKey('active') && 
              tag['active'] == true) {
            final tagId = tag['id'].toString();
            if (!tagIds.contains(tagId)) {
              tagIds.add(tagId);
              uniqueTags.add(Map<String, dynamic>.from(tag));
            }
          }
        }
      }
    }
    
    return uniqueTags;
  }
  
  // Phương thức xây dựng bộ lọc loại sản phẩm
  Widget _buildProductTypeFilters(ProductTypeProvider typeProvider, StateSetter setState) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Loại sản phẩm',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: typeProvider.productTypes.map((type) {
            final isSelected = _selectedProductTypes.contains(type.id);
            return FilterChip(
              label: Text(type.name),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  if (selected) {
                    _selectedProductTypes.add(type.id);
                  } else {
                    _selectedProductTypes.remove(type.id);
                  }
                });
              },
            );
          }).toList(),
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  // Phương thức xây dựng bộ lọc khoảng giá
  Widget _buildPriceRangeFilter(NumberFormat currencyFormatter, StateSetter setState) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Khoảng giá',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        RangeSlider(
          values: _priceRange,
          min: _minPrice,
          max: _maxPrice,
          divisions: 20,
          labels: RangeLabels(
            currencyFormatter.format(_priceRange.start),
            currencyFormatter.format(_priceRange.end),
          ),
          onChanged: (RangeValues values) {
            setState(() {
              _priceRange = values;
            });
          },
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(currencyFormatter.format(_priceRange.start)),
            Text(currencyFormatter.format(_priceRange.end)),
          ],
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  // Phương thức xây dựng bộ lọc tags
  Widget _buildTagsFilter(List<Map<String, dynamic>> tagsList, StateSetter setState) {
    if (tagsList.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Tags',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: tagsList.map((tag) {
            final tagId = tag['id']?.toString() ?? '';
            final tagName = tag['name']?.toString() ?? 'Unknown';
            final isSelected = _selectedTags.contains(tagId);
            return FilterChip(
              label: Text(tagName),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  if (selected) {
                    _selectedTags.add(tagId);
                  } else {
                    _selectedTags.remove(tagId);
                  }
                });
              },
            );
          }).toList(),
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  // Phương thức xây dựng bộ lọc thương hiệu
  Widget _buildBrandFilters(List<dynamic> brands, StateSetter setState) {
    if (brands.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Thương hiệu',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: brands.map((brand) {
            final brandId = brand['id']?.toString() ?? '';
            final isSelected = _selectedBrands.contains(brandId);
            return FilterChip(
              label: Text(brand['name']?.toString() ?? 'Unknown'),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  if (selected) {
                    _selectedBrands.add(brandId);
                  } else {
                    _selectedBrands.remove(brandId);
                  }
                });
              },
            );
          }).toList(),
        ),
        const SizedBox(height: 24),
      ],
    );
  }
  
  void _showSortDialog(BuildContext context) {
    final isLargeScreen = MediaQuery.of(context).size.width >= 600;
    
    if (isLargeScreen) {
      showDialog(
        context: context,
        builder: (context) {
          return StatefulBuilder(
            builder: (context, setState) {
              return AlertDialog(
                title: const Text('Sắp xếp theo'),
                content: SizedBox(
                  width: 300,
                  height: MediaQuery.of(context).size.height * 0.4,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: _buildSortOptions(setState),
                    ),
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Hủy'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      _applyFilters();
                    },
                    child: const Text('Áp dụng'),
                  ),
                ],
              );
            },
          );
        },
      );
    } else {
      showModalBottomSheet(
        context: context,
        builder: (context) {
          return StatefulBuilder(
            builder: (context, setState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          offset: const Offset(0, 1),
                          blurRadius: 2,
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Sắp xếp theo',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () => Navigator.pop(context),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                      ],
                    ),
                  ),
                  
                  Expanded(
                    child: ListView(
                      padding: EdgeInsets.zero,
                      shrinkWrap: true,
                      physics: const AlwaysScrollableScrollPhysics(),
                      children: _buildSortOptions(setState),
                    ),
                  ),
                  
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          offset: const Offset(0, -1),
                          blurRadius: 2,
                        ),
                      ],
                    ),
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                          _applyFilters();
                        },
                        child: const Text('Áp dụng'),
                      ),
                    ),
                  ),
                ],
              );
            },
          );
        },
      );
    }
  }
  
  List<Widget> _buildSortOptions(StateSetter setState) {
    return [
      RadioListTile<String>(
        title: const Text('Mặc định'),
        value: 'relevance',
        groupValue: _sortBy,
        onChanged: (value) {
          setState(() {
            _sortBy = value!;
          });
        },
      ),
      RadioListTile<String>(
        title: const Text('Giá thấp đến cao'),
        value: 'price_asc',
        groupValue: _sortBy,
        onChanged: (value) {
          setState(() {
            _sortBy = value!;
          });
        },
      ),
      RadioListTile<String>(
        title: const Text('Giá cao đến thấp'),
        value: 'price_desc',
        groupValue: _sortBy,
        onChanged: (value) {
          setState(() {
            _sortBy = value!;
          });
        },
      ),
      RadioListTile<String>(
        title: const Text('Tên A-Z'),
        value: 'name_asc',
        groupValue: _sortBy,
        onChanged: (value) {
          setState(() {
            _sortBy = value!;
          });
        },
      ),
      RadioListTile<String>(
        title: const Text('Tên Z-A'),
        value: 'name_desc',
        groupValue: _sortBy,
        onChanged: (value) {
          setState(() {
            _sortBy = value!;
          });
        },
      ),
      RadioListTile<String>(
        title: const Text('Đánh giá cao nhất'),
        value: 'rating_desc',
        groupValue: _sortBy,
        onChanged: (value) {
          setState(() {
            _sortBy = value!;
          });
        },
      ),
      RadioListTile<String>(
        title: const Text('Đánh giá thấp nhất'),
        value: 'rating_asc',
        groupValue: _sortBy,
        onChanged: (value) {
          setState(() {
            _sortBy = value!;
          });
        },
      ),
      RadioListTile<String>(
        title: const Text('Mới nhất'),
        value: 'created_desc',
        groupValue: _sortBy,
        onChanged: (value) {
          setState(() {
            _sortBy = value!;
          });
        },
      ),
      RadioListTile<String>(
        title: const Text('Cũ nhất'),
        value: 'created_asc',
        groupValue: _sortBy,
        onChanged: (value) {
          setState(() {
            _sortBy = value!;
          });
        },
      ),
    ];
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    super.dispose();
  }
}

class ResponsiveLayout {
  static bool isMobile(BuildContext context) => 
      MediaQuery.of(context).size.width < 600;
      
  static bool isTablet(BuildContext context) => 
      MediaQuery.of(context).size.width >= 600 && MediaQuery.of(context).size.width < 1200;
      
  static bool isDesktop(BuildContext context) => 
      MediaQuery.of(context).size.width >= 1200;
}
