import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:frontend_admin/core/utils/image_helper.dart' show ImageHelper;
import 'package:frontend_admin/models/brand_model.dart';
import 'package:frontend_admin/models/product_model.dart';
import 'package:frontend_admin/models/product_type_model.dart';
import 'package:frontend_admin/models/tag_model.dart';
import 'package:frontend_admin/providers/brand_provider.dart';
import 'package:frontend_admin/providers/product_provider.dart';
import 'package:frontend_admin/providers/product_type_provider.dart';
import 'package:frontend_admin/providers/tag_provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

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
  
  XFile? _imageFile;
  String _selectedBrandId = '';
  String _selectedProductTypeId = '';
  bool _isLoading = false;
  Uint8List? _imageBytesForWebPreview;
  
  // Thêm các biến cần thiết cho tags
  final List<String> _selectedTagIds = [];
  
  @override
  void initState() {
    super.initState();
    
    // Load brands, product types, và tags
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final brandProvider = Provider.of<BrandProvider>(context, listen: false);
      final typeProvider = Provider.of<ProductTypeProvider>(context, listen: false);
      final tagProvider = Provider.of<TagProvider>(context, listen: false);
      
      brandProvider.fetchBrands();
      typeProvider.fetchProductTypes();
      tagProvider.fetchTags();
      
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
    _priceController.text = NumberFormat('#,###', 'vi_VN').format(product.price);
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
    
    // Điền các tag đã chọn
    if (product.tags.isNotEmpty) {
      for (var tag in product.tags) {
        if (tag['id'] != null) {
          _selectedTagIds.add(tag['id'] as String);
        }
      }
    }
    
    // Hiển thị ảnh hiện tại nếu có
    if (product.primaryImageUrl.isNotEmpty) {
      // Không cần _imagePreviewUrl nữa vì đã đổi logic hiển thị ảnh
    }
  }
  
  Future<void> _pickImage() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? pickedFile = await picker.pickImage(source: ImageSource.gallery);
      
      if (pickedFile != null) {
        setState(() {
          _imageFile = pickedFile;
          if (kIsWeb) {
            // Đọc bytes để preview trên web nếu cần
            pickedFile.readAsBytes().then((bytes) {
              setState(() {
                _imageBytesForWebPreview = bytes;
              });
            });
          } else {
            _imageBytesForWebPreview = null; // Reset nếu không phải web
          }
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
      // Kiểm tra xem ảnh đã được chọn chưa khi tạo mới
      if (!widget.isEditing && _imageFile == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Vui lòng chọn hình ảnh cho sản phẩm')),
        );
        return;
      }
      
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
        final tagProvider = Provider.of<TagProvider>(context, listen: false);
        
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
        
        // Lấy danh sách tags đã chọn
        final selectedTags = tagProvider.tags
            .where((tag) => _selectedTagIds.contains(tag.id))
            .map((tag) => {
              'id': tag.id,
              'name': tag.name,
              'color': tag.color,
            })
            .toList();
        
        // Parse giá từ chuỗi đã định dạng về dạng số
        final priceText = _priceController.text.replaceAll('.', '').replaceAll(',', '').trim();
        final price = double.tryParse(priceText) ?? 0;
        
        // Kiểm tra và giới hạn discount không vượt quá 50%
        final double discount = double.tryParse(_discountController.text) ?? 0;
        if (discount > 50) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Giảm giá không thể vượt quá 50%'),
              backgroundColor: Colors.red,
            ),
          );
          setState(() {
            _isLoading = false;
          });
          return;
        }
        
        // Tạo đối tượng Product
        final product = Product(
          id: widget.isEditing && widget.product != null ? widget.product!.id : '',
          name: _nameController.text,
          price: price,
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
          discountPercent: discount,
          brand: {
            'id': selectedBrand.id,
            'name': selectedBrand.name,
          },
          productType: {
            'id': selectedType.id,
            'name': selectedType.name,
          },
          specifications: specifications,
          tags: selectedTags,
        );
        
        bool success;
        // Lưu sản phẩm
        if (widget.isEditing && widget.product != null) {
          success = await productProvider.updateProduct(
            widget.product!.id,
            product,
            imageFile: _imageFile,
          );
          
          // Cập nhật tags (xóa rồi thêm lại)
          if (success) {
            // Thêm các tag mới
            for (String tagId in _selectedTagIds) {
              final existingTagIds = widget.product!.tags
                  .where((tag) => tag['id'] != null)
                  .map((tag) => tag['id'] as String)
                  .toList();
                  
              if (!existingTagIds.contains(tagId)) {
                await tagProvider.addTagToProduct(widget.product!.id, tagId);
              }
            }
            
            // Xóa các tag đã bỏ chọn
            for (var tag in widget.product!.tags) {
              if (tag['id'] != null && !_selectedTagIds.contains(tag['id'])) {
                await tagProvider.removeTagFromProduct(widget.product!.id, tag['id'] as String);
              }
            }
          }
        } else {
          success = await productProvider.createProduct(
            product,
            imageFile: _imageFile,
          );
          
          // Thêm tags cho sản phẩm mới
          if (success && productProvider.currentProduct != null) {
            final newProductId = productProvider.currentProduct!.id;
            for (String tagId in _selectedTagIds) {
              await tagProvider.addTagToProduct(newProductId, tagId);
            }
          }
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
    final tagProvider = Provider.of<TagProvider>(context);
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
                          if (_imageFile != null) ...[
                            Container(
                              width: 200,
                              height: 200,
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey),
                              ),
                              child: _imageFile != null
                                  ? (kIsWeb 
                                      ? (_imageBytesForWebPreview != null 
                                          ? Image.memory(_imageBytesForWebPreview!, fit: BoxFit.cover) 
                                          : const Center(child: CircularProgressIndicator()))
                                      : Image.file(File(_imageFile!.path), fit: BoxFit.cover))
                                  : (widget.isEditing && widget.product!.primaryImageUrl.isNotEmpty 
                                      ? Image.network(
                                          ImageHelper.getProductImage(widget.product!.primaryImageUrl),
                                          fit: BoxFit.cover,
                                          errorBuilder: (_, __, ___) => const Icon(Icons.image_not_supported, size: 60),
                                        )
                                      : const Icon(Icons.image_not_supported, size: 60, color: Colors.grey)
                                    ),
                            ),
                            const SizedBox(height: 8),
                          ],
                          ElevatedButton.icon(
                            onPressed: _pickImage,
                            icon: const Icon(Icons.photo_camera),
                            label: Text(_imageFile == null && (widget.product?.primaryImageUrl.isEmpty ?? true) ? 'Chọn ảnh' : 'Đổi ảnh'),
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
                              prefixText: 'đ ',
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Nhập giá';
                              }
                              return null;
                            },
                            // Định dạng giá tiền khi người dùng nhập
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                              TextInputFormatter.withFunction((oldValue, newValue) {
                                if (newValue.text.isEmpty) {
                                  return newValue;
                                }
                                
                                final int value = int.parse(newValue.text);
                                final formatter = NumberFormat('#,###', 'vi_VN');
                                final newText = formatter.format(value);
                                
                                return TextEditingValue(
                                  text: newText,
                                  selection: TextSelection.collapsed(offset: newText.length),
                                );
                              }),
                            ],
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
                        helperText: 'Giảm giá tối đa 50%',
                      ),
                      validator: (value) {
                        if (value != null && value.isNotEmpty) {
                          final discount = double.tryParse(value);
                          if (discount == null) {
                            return 'Giá trị không hợp lệ';
                          }
                          if (discount < 0) {
                            return 'Giảm giá không thể âm';
                          }
                          if (discount > 50) {
                            return 'Giảm giá tối đa 50%';
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
                    
                    // Tags section
                    const SizedBox(height: 24),
                    Card(
                      elevation: 2,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Thẻ gắn kèm',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 12),
                            
                            // Hiển thị loading nếu đang tải tags
                            if (tagProvider.status == TagStatus.loading)
                              const Center(
                                child: Padding(
                                  padding: EdgeInsets.all(16.0),
                                  child: CircularProgressIndicator(),
                                ),
                              )
                            // Hiển thị thông báo nếu không có tags
                            else if (tagProvider.tags.isEmpty)
                              Container(
                                padding: const EdgeInsets.all(16),
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade100,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Text(
                                  'Chưa có thẻ nào để chọn.',
                                  style: TextStyle(
                                    color: Colors.grey,
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                              )
                            // Hiển thị danh sách tags để chọn
                            else
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: tagProvider.tags.map((tag) {
                                  final isSelected = _selectedTagIds.contains(tag.id);
                                  
                                  // Chuyển đổi màu từ hex sang Color
                                  Color tagColor;
                                  try {
                                    tagColor = Color(int.parse(tag.color.replaceFirst('#', '0xFF')));
                                  } catch (e) {
                                    tagColor = Colors.grey;
                                  }
                                  
                                  // Tính toán màu chữ dựa vào độ sáng của màu nền
                                  final double luminance = tagColor.computeLuminance();
                                  final Color textColor = luminance > 0.5 ? Colors.black : Colors.white;
                                  
                                  return FilterChip(
                                    label: Text(tag.name),
                                    labelStyle: TextStyle(
                                      color: isSelected ? textColor : Colors.black,
                                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                    ),
                                    selected: isSelected,
                                    selectedColor: tagColor,
                                    checkmarkColor: textColor,
                                    backgroundColor: Colors.grey.shade200,
                                    onSelected: (selected) {
                                      setState(() {
                                        if (selected) {
                                          _selectedTagIds.add(tag.id);
                                        } else {
                                          _selectedTagIds.remove(tag.id);
                                        }
                                      });
                                    },
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20),
                                      side: BorderSide(
                                        color: isSelected ? tagColor : Colors.grey.shade300,
                                      ),
                                    ),
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                                  );
                                }).toList(),
                              ),
                            
                            // Hiển thị lỗi nếu có
                            if (tagProvider.status == TagStatus.error)
                              Padding(
                                padding: const EdgeInsets.only(top: 8),
                                child: Text(
                                  'Lỗi: ${tagProvider.errorMessage}',
                                  style: TextStyle(color: Colors.red.shade700),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                    
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