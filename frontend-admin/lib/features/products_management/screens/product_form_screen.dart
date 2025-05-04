import 'dart:io';
import 'package:admin_interface/core/utils/image_helper.dart';
import 'package:admin_interface/models/brand_model.dart';
import 'package:admin_interface/models/product_model.dart';
import 'package:admin_interface/models/product_type_model.dart';
import 'package:admin_interface/providers/brand_provider.dart';
import 'package:admin_interface/providers/product_provider.dart';
import 'package:admin_interface/providers/product_type_provider.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

class ProductFormScreen extends StatefulWidget {
  final Product? product;
  final bool isEditing;

  const ProductFormScreen({
    Key? key,
    this.product,
    this.isEditing = false,
  }) : super(key: key);

  @override
  State<ProductFormScreen> createState() => _ProductFormScreenState();
}

class _ProductFormScreenState extends State<ProductFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  final _quantityController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _discountController = TextEditingController();
  
  // Map để lưu các trường thông số kỹ thuật
  final Map<String, TextEditingController> _specControllers = {};
  
  // Dùng để thêm/xóa các trường thông số kỹ thuật
  final List<String> _specKeys = [];
  
  File? _imageFile;
  String _selectedBrandId = '';
  String _selectedProductTypeId = '';
  bool _isLoading = false;
  String? _imagePreviewUrl;
  
  @override
  void initState() {
    super.initState();
    
    // Load brands and product types
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final brandProvider = Provider.of<BrandProvider>(context, listen: false);
      final typeProvider = Provider.of<ProductTypeProvider>(context, listen: false);
      
      brandProvider.fetchBrands();
      typeProvider.fetchProductTypes();
      
      // Nếu đang chỉnh sửa, điền thông tin sản phẩm vào form
      if (widget.isEditing && widget.product != null) {
        _populateForm(widget.product!);
      }
    });
  }
  
  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _quantityController.dispose();
    _descriptionController.dispose();
    _discountController.dispose();
    
    // Giải phóng các controllers cho specifications
    for (var controller in _specControllers.values) {
      controller.dispose();
    }
    
    super.dispose();
  }
  
  void _populateForm(Product product) {
    _nameController.text = product.name;
    _priceController.text = product.price.toString();
    _quantityController.text = product.quantity.toString();
    _descriptionController.text = product.description;
    _discountController.text = product.discountPercent.toString();
    
    if (product.brand.isNotEmpty && product.brand['id'] != null) {
      _selectedBrandId = product.brand['id'] as String;
    }
    
    if (product.productType.isNotEmpty && product.productType['id'] != null) {
      _selectedProductTypeId = product.productType['id'] as String;
    }
    
    // Điền các thông số kỹ thuật
    product.specifications.forEach((key, value) {
      _addSpecification(key, value);
    });
    
    // Hiển thị ảnh hiện tại nếu có
    if (product.primaryImageUrl.isNotEmpty) {
      _imagePreviewUrl = ImageHelper.getProductImage(product.primaryImageUrl);
    }
  }
  
  Future<void> _pickImage() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? pickedFile = await picker.pickImage(source: ImageSource.gallery);
      
      if (pickedFile != null) {
        setState(() {
          // Trên web không thể truy cập trực tiếp File
          if (!kIsWeb) {
            _imageFile = File(pickedFile.path);
          }
          // Lưu đường dẫn ảnh để hiển thị preview
          _imagePreviewUrl = pickedFile.path;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi khi chọn ảnh: $e')),
      );
    }
  }
  
  void _addSpecification([String? initialKey, String? initialValue]) {
    final key = initialKey ?? '';
    final value = initialValue ?? '';
    
    // Tạo key duy nhất cho trường thông số
    final specKey = key.isEmpty ? DateTime.now().millisecondsSinceEpoch.toString() : key;
    
    // Tạo controllers mới cho key và value
    final keyController = TextEditingController(text: key);
    final valueController = TextEditingController(text: value);
    
    setState(() {
      _specKeys.add(specKey);
      _specControllers['${specKey}_key'] = keyController;
      _specControllers['${specKey}_value'] = valueController;
    });
  }
  
  void _removeSpecification(String specKey) {
    // Xóa controllers
    _specControllers.remove('${specKey}_key')?.dispose();
    _specControllers.remove('${specKey}_value')?.dispose();
    
    setState(() {
      _specKeys.remove(specKey);
    });
  }
  
  Future<void> _saveProduct() async {
    if (_formKey.currentState!.validate()) {
      // Nếu chưa chọn brand hoặc product type thì thông báo lỗi
      if (_selectedBrandId.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Vui lòng chọn thương hiệu')),
        );
        return;
      }
      
      if (_selectedProductTypeId.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Vui lòng chọn loại sản phẩm')),
        );
        return;
      }
      
      setState(() {
        _isLoading = true;
      });
      
      try {
        final productProvider = Provider.of<ProductProvider>(context, listen: false);
        final brandProvider = Provider.of<BrandProvider>(context, listen: false);
        final typeProvider = Provider.of<ProductTypeProvider>(context, listen: false);
        
        // Lấy thông tin brand và product type
        final selectedBrand = brandProvider.brands.firstWhere(
          (brand) => brand.id == _selectedBrandId,
          orElse: () => Brand(id: _selectedBrandId, name: 'Unknown'),
        );
        
        final selectedType = typeProvider.productTypes.firstWhere(
          (type) => type.id == _selectedProductTypeId,
          orElse: () => ProductType(id: _selectedProductTypeId, name: 'Unknown'),
        );
        
        // Lấy thông số kỹ thuật từ form
        final Map<String, String> specifications = {};
        for (final specKey in _specKeys) {
          final keyController = _specControllers['${specKey}_key'];
          final valueController = _specControllers['${specKey}_value'];
          
          if (keyController != null && valueController != null && 
              keyController.text.isNotEmpty && valueController.text.isNotEmpty) {
            specifications[keyController.text] = valueController.text;
          }
        }
        
        // Tạo đối tượng Product
        final product = Product(
          id: widget.isEditing && widget.product != null ? widget.product!.id : '',
          name: _nameController.text,
          price: double.tryParse(_priceController.text) ?? 0,
          quantity: int.tryParse(_quantityController.text) ?? 0,
          description: _descriptionController.text,
          primaryImageUrl: widget.isEditing && widget.product != null && _imageFile == null
              ? widget.product!.primaryImageUrl 
              : '',
          imageUrls: widget.isEditing && widget.product != null
              ? widget.product!.imageUrls 
              : [],
          soldCount: widget.isEditing && widget.product != null
              ? widget.product!.soldCount
              : 0,
          discountPercent: double.tryParse(_discountController.text) ?? 0,
          brand: {
            'id': selectedBrand.id,
            'name': selectedBrand.name,
          },
          productType: {
            'id': selectedType.id,
            'name': selectedType.name,
          },
          specifications: specifications,
        );
        
        bool success;
        // Lưu sản phẩm
        if (widget.isEditing && widget.product != null) {
          success = await productProvider.updateProduct(
            widget.product!.id,
            product,
            imageFile: _imageFile,
          );
        } else {
          success = await productProvider.createProduct(
            product,
            imageFile: _imageFile,
          );
        }
        
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(widget.isEditing
                  ? 'Cập nhật sản phẩm thành công!'
                  : 'Tạo sản phẩm mới thành công!'),
              backgroundColor: Colors.green,
            ),
          );
          
          // Quay lại màn hình danh sách sản phẩm
          if (context.mounted) {
            Navigator.of(context).pop();
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Lỗi: ${productProvider.errorMessage}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Đã xảy ra lỗi: $e'),
            backgroundColor: Colors.red,
          ),
        );
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }
  
  @override
  Widget build(BuildContext context) {
    final brandProvider = Provider.of<BrandProvider>(context);
    final typeProvider = Provider.of<ProductTypeProvider>(context);
    final formatCurrency = NumberFormat.currency(locale: 'vi_VN', symbol: '₫');
    
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isEditing ? 'Chỉnh sửa sản phẩm' : 'Thêm sản phẩm mới'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Hình ảnh sản phẩm
                    Center(
                      child: Column(
                        children: [
                          if (_imagePreviewUrl != null) ...[
                            Container(
                              width: 200,
                              height: 200,
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey),
                              ),
                              child: kIsWeb || _imageFile == null
                                  ? (_imageFile == null && widget.isEditing) 
                                      ? Image.network(
                                          _imagePreviewUrl!,
                                          fit: BoxFit.cover,
                                          errorBuilder: (_, __, ___) => const Icon(Icons.image_not_supported, size: 60),
                                        )
                                      : Image.network(
                                          _imagePreviewUrl!, 
                                          fit: BoxFit.cover,
                                          errorBuilder: (_, __, ___) => const Icon(Icons.image_not_supported, size: 60),
                                        )
                                  : Image.file(
                                      _imageFile!,
                                      fit: BoxFit.cover,
                                    ),
                            ),
                            const SizedBox(height: 8),
                          ],
                          ElevatedButton.icon(
                            onPressed: _pickImage,
                            icon: const Icon(Icons.photo_camera),
                            label: Text(_imagePreviewUrl == null ? 'Chọn ảnh' : 'Đổi ảnh'),
                          ),
                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                    
                    // Thông tin cơ bản
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: 'Tên sản phẩm',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Vui lòng nhập tên sản phẩm';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    
                    Row(
                      children: [
                        // Giá
                        Expanded(
                          child: TextFormField(
                            controller: _priceController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              labelText: 'Giá (VND)',
                              border: OutlineInputBorder(),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Nhập giá';
                              }
                              if (double.tryParse(value) == null) {
                                return 'Giá không hợp lệ';
                              }
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(width: 16),
                        
                        // Số lượng
                        Expanded(
                          child: TextFormField(
                            controller: _quantityController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              labelText: 'Số lượng',
                              border: OutlineInputBorder(),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Nhập số lượng';
                              }
                              if (int.tryParse(value) == null) {
                                return 'Số lượng không hợp lệ';
                              }
                              return null;
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    
                    // Giảm giá
                    TextFormField(
                      controller: _discountController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Giảm giá (%)',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value != null && value.isNotEmpty) {
                          final discount = double.tryParse(value);
                          if (discount == null) {
                            return 'Giá trị không hợp lệ';
                          }
                          if (discount < 0 || discount > 100) {
                            return 'Giảm giá phải từ 0-100%';
                          }
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    
                    // Thương hiệu
                    DropdownButtonFormField<String>(
                      decoration: const InputDecoration(
                        labelText: 'Thương hiệu',
                        border: OutlineInputBorder(),
                      ),
                      value: _selectedBrandId.isNotEmpty ? _selectedBrandId : null,
                      hint: const Text('Chọn thương hiệu'),
                      isExpanded: true,
                      items: brandProvider.brands.map((Brand brand) {
                        return DropdownMenuItem<String>(
                          value: brand.id,
                          child: Text(brand.name),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        setState(() {
                          _selectedBrandId = newValue ?? '';
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    
                    // Loại sản phẩm
                    DropdownButtonFormField<String>(
                      decoration: const InputDecoration(
                        labelText: 'Loại sản phẩm',
                        border: OutlineInputBorder(),
                      ),
                      value: _selectedProductTypeId.isNotEmpty ? _selectedProductTypeId : null,
                      hint: const Text('Chọn loại sản phẩm'),
                      isExpanded: true,
                      items: typeProvider.productTypes.map((ProductType type) {
                        return DropdownMenuItem<String>(
                          value: type.id,
                          child: Text(type.name),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        setState(() {
                          _selectedProductTypeId = newValue ?? '';
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    
                    // Mô tả
                    TextFormField(
                      controller: _descriptionController,
                      maxLines: 5,
                      decoration: const InputDecoration(
                        labelText: 'Mô tả sản phẩm',
                        alignLabelWithHint: true,
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Vui lòng nhập mô tả sản phẩm';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),
                    
                    // Thông số kỹ thuật
                    Card(
                      elevation: 2,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Thông số kỹ thuật',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                ElevatedButton.icon(
                                  onPressed: () => _addSpecification(),
                                  icon: const Icon(Icons.add),
                                  label: const Text('Thêm thông số'),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            
                            // Danh sách các thông số kỹ thuật
                            ..._specKeys.map((specKey) {
                              final keyController = _specControllers['${specKey}_key'];
                              final valueController = _specControllers['${specKey}_value'];
                              
                              return Column(
                                children: [
                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      // Trường tên thông số
                                      Expanded(
                                        child: TextFormField(
                                          controller: keyController,
                                          decoration: const InputDecoration(
                                            labelText: 'Tên thông số',
                                            border: OutlineInputBorder(),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 16),
                                      
                                      // Trường giá trị thông số
                                      Expanded(
                                        child: TextFormField(
                                          controller: valueController,
                                          decoration: const InputDecoration(
                                            labelText: 'Giá trị',
                                            border: OutlineInputBorder(),
                                          ),
                                        ),
                                      ),
                                      
                                      // Nút xóa thông số
                                      IconButton(
                                        icon: const Icon(Icons.delete, color: Colors.red),
                                        onPressed: () => _removeSpecification(specKey),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                ],
                              );
                            }).toList(),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                    
                    // Nút lưu
                    Center(
                      child: SizedBox(
                        width: 200,
                        height: 50,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Theme.of(context).primaryColor,
                            foregroundColor: Colors.white,
                          ),
                          onPressed: _saveProduct,
                          child: Text(
                            widget.isEditing ? 'Cập nhật sản phẩm' : 'Thêm sản phẩm',
                            style: const TextStyle(fontSize: 16),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
    );
  }
}